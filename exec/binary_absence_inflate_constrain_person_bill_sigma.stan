

data {
  int N;
  int Y[N];
  int<lower=1> num_legis;
  int<lower=1> num_bills;
  int ll[N];
  int bb[N];
  int restrict_l;
  int restrict_b;
    vector[num_legis] particip;
  
}

transformed data {
	int absence[N];
	int Y_new[N];
	// Put a logical catch for any binary-coded values that are not 0/1
	if(max(Y)>1) {
	  for(n in 1:N)
	    Y_new[n] = Y[n] - min(Y);
	} else {
	  Y_new=Y;
	}
  for(n in 1:N) {
    if(Y[n]>1) {
      absence[n]=1;
    } else {
      absence[n]=0;
    }
  }
}

parameters {
  vector[num_legis-restrict_l] L_free;
  vector<upper=0>[restrict_l] L_restrict;
  vector[num_bills] B_yes;
  vector[num_bills-restrict_b] sigma_free;
  vector<upper=0>[restrict_b] sigma_restrict;
  vector [num_bills] B_abs;
  vector [num_bills] sigma_abs_open;
  real avg_particip;
}

transformed parameters {
vector[num_bills] sigma_full;
vector[num_legis] L_full;
sigma_full = append_row(sigma_free,sigma_restrict);
L_full = append_row(L_free,L_restrict);
}

model {	
  vector[N] pi1;
  vector[N] pi2;
  sigma_free ~ normal(0,5);
  sigma_restrict ~normal(0,5);
  L_free ~ normal(0,1);
  L_restrict ~ normal(0,1);
  sigma_abs_open ~normal(0,5);
  avg_particip ~ normal(0,5);
	
  B_yes ~ normal(0,5);
  B_abs ~ normal(0,5);

  //model
  for(n in 1:N) {
      pi1[n] = sigma_full[bb[n]] *  L_full[ll[n]] - B_yes[bb[n]];
      pi2[n] = sigma_abs_open[bb[n]] * L_full[ll[n]] - B_abs[bb[n]] + avg_particip * particip[ll[n]];
  if(absence[n]==1) {
	  1 ~ bernoulli_logit(pi2[n]);
  } else {
    0 ~ bernoulli_logit(pi2[n]);
    Y_new[n] ~ bernoulli_logit(pi1[n]);
  }
  }


  
}
