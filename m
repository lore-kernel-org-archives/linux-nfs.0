Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:12095 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754822Ab2E2TR1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 May 2012 15:17:27 -0400
Message-ID: <4FC5209E.1090306@RedHat.com>
Date: Tue, 29 May 2012 15:16:46 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
Subject: Re: [PATCH v4] statd: drop all capabilities from the bounding set
 as well
References: <1337683270-14260-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1337683270-14260-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/22/2012 06:41 AM, Jeff Layton wrote:
> statd drops all capabilities except for CAP_NET_BIND when it starts. It's
> possible though that if it ever had a compromise that an attacker would be
> able to invoke a setuid process (or something with file capabilities) in
> order to reinstate some caps.
> 
> This could happen as a result of the daemon becoming compromised, or
> possibly as a result of the ha-callout program becoming compromised.
> 
> In order to prevent that, have statd also prune the capability bounding
> set to nothing prior to dropping capabilities. That ensures that the
> process won't be able to reacquire capabilities via any means --
> including exec'ing a setuid program.
> 
> We do however need to be cognizant of the fact that PR_CAPBSET_DROP was
> only added in 2.6.25, so check to make sure that #define exists via
> autoconf before we rely on it. In order to do that, we must add
> ax_check_define.m4 from the GNU autoconf macro archive.
> 
> Furthermore, do a runtime check to see if /proc/sys/kernel/cap-bound
> exists before attempting to clear the bounding set. If it does, then
> don't bother trying since it won't work. In that event though, do
> throw a warning however since the presence of that file indicates that
> there is a disconnect between the build and runtime environments.
> 
> Cc: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
Committed....

steved.
> ---
>  support/nsm/file.c |   57 ++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 files changed, 55 insertions(+), 2 deletions(-)
> 
> diff --git a/support/nsm/file.c b/support/nsm/file.c
> index 5dd52c1..5476446 100644
> --- a/support/nsm/file.c
> +++ b/support/nsm/file.c
> @@ -338,10 +338,10 @@ nsm_is_default_parentdir(void)
>   *
>   * Returns true if successful, or false if some error occurred.
>   */
> +#ifdef HAVE_SYS_CAPABILITY_H
>  static _Bool
>  nsm_clear_capabilities(void)
>  {
> -#ifdef HAVE_SYS_CAPABILITY_H
>  	cap_t caps;
>  
>  	caps = cap_from_text("cap_net_bind_service=ep");
> @@ -357,10 +357,60 @@ nsm_clear_capabilities(void)
>  	}
>  
>  	(void)cap_free(caps);
> -#endif
>  	return true;
>  }
>  
> +#define CAP_BOUND_PROCFILE "/proc/sys/kernel/cap-bound"
> +static _Bool
> +prune_bounding_set(void)
> +{
> +#ifdef PR_CAPBSET_DROP
> +	int ret;
> +	unsigned long i;
> +	struct stat st;
> +
> +	/*
> +	 * Prior to kernel 2.6.25, the capabilities bounding set was a global
> +	 * value. Check to see if /proc/sys/kernel/cap-bound exists and don't
> +	 * bother to clear the bounding set if it does.
> +	 */
> +	ret = stat(CAP_BOUND_PROCFILE, &st);
> +	if (!ret) {
> +		xlog(L_WARNING, "%s exists. Not attempting to clear "
> +				"capabilities bounding set.",
> +				CAP_BOUND_PROCFILE);
> +		return true;
> +	} else if (errno != ENOENT) {
> +		/* Warn, but attempt to clear the bounding set anyway. */
> +		xlog(L_WARNING, "Unable to stat %s: %m", CAP_BOUND_PROCFILE);
> +	}
> +
> +	/* prune the bounding set to nothing */
> +	for (i = 0; i <= CAP_LAST_CAP; ++i) {
> +		ret = prctl(PR_CAPBSET_DROP, i, 0, 0, 0);
> +		if (ret) {
> +			xlog(L_ERROR, "Unable to prune capability %lu from "
> +				      "bounding set: %m", i);
> +			return false;
> +		}
> +	}
> +#endif /* PR_CAPBSET_DROP */
> +	return true;
> +}
> +#else /* !HAVE_SYS_CAPABILITY_H */
> +static _Bool
> +nsm_clear_capabilities(void)
> +{
> +	return true;
> +}
> +
> +static _Bool
> +prune_bounding_set(void)
> +{
> +	return true;
> +}
> +#endif /* HAVE_SYS_CAPABILITY_H */
> +
>  /**
>   * nsm_drop_privileges - drop root privileges
>   * @pidfd: file descriptor of a pid file
> @@ -393,6 +443,9 @@ nsm_drop_privileges(const int pidfd)
>  		return false;
>  	}
>  
> +	if (!prune_bounding_set())
> +		return false;
> +
>  	if (st.st_uid == 0) {
>  		xlog_warn("Running as root.  "
>  			"chown %s to choose different user", nsm_base_dirname);
