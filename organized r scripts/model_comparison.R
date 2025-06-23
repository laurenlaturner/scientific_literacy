# Model comparison of m_mixed_beta and m_mixed_ols

# Smaller AIC means better consideration of model complexity
AIC(m_mixed_beta, m_mixed_ols)

# Smaller BIC means better consideration of model complexity
BIC(m_mixed_beta, m_mixed_ols)

# Larger R squared means more error accounted for in model
r.squaredGLMM(m_mixed_ols)
r2(m_mixed_beta)