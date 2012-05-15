Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:32047 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755672Ab2EOPAP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 11:00:15 -0400
Subject: Re: [PATCH] statd: drop all capabilities from the bounding set as well
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1337091151-3385-1-git-send-email-jlayton@redhat.com>
Date: Tue, 15 May 2012 11:00:10 -0400
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Message-Id: <AD2C2C58-2CB4-43A1-A21E-EB8D83D084F9@oracle.com>
References: <1337091151-3385-1-git-send-email-jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'll summarize our conversation on IRC:

  o  This fix probably won't add any new vulnerabilities, but:

  o  We don't have an existing exploit to see if this patch closes it

  o  We don't have any unit tests for this daemon anyway to see if we're breaking something else

  o  An interesting test case is to try invoking a setuid callout and see if capabilities are dropped

  o  statd probably needs to know when it's running on a pre-2.6.25 kernel (which has a system-wide bounding set)

  o  statd probably needs to know when CONFIG_SECURITY_FILE_CAPABILITIES is not set on the system where it's running

So this fix needs a little more built-in cleverness.  NAK to this version, and let's see if the concerns above can be addressed.

On May 15, 2012, at 10:12 AM, Jeff Layton wrote:

> statd drops all capabilities except for CAP_NET_BIND when it starts. It's
> possible though that if it ever had a compromise that an attacker would be
> able to invoke a setuid process (or something with file capabilities) in
> order to reinstate some caps.
> 
> In order to prevent that, have statd also prune the bounding set to nothing
> prior to dropping capabilities.
> 
> Cc: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> support/nsm/file.c |   12 ++++++++++++
> 1 files changed, 12 insertions(+), 0 deletions(-)
> 
> diff --git a/support/nsm/file.c b/support/nsm/file.c
> index 5dd52c1..2d86f95 100644
> --- a/support/nsm/file.c
> +++ b/support/nsm/file.c
> @@ -342,8 +342,20 @@ static _Bool
> nsm_clear_capabilities(void)
> {
> #ifdef HAVE_SYS_CAPABILITY_H
> +	int ret;
> +	unsigned long i;
> 	cap_t caps;
> 
> +	/* prune the bounding set to nothing */
> +	for (i = 0; i <= CAP_LAST_CAP; ++i) {
> +		ret = prctl(PR_CAPBSET_DROP, i);
> +		if (ret) {
> +			xlog(L_ERROR, "Unable to prune capability %lu from "
> +				      "bounding set: %m", i);
> +			return false;
> +		}
> +	}
> +
> 	caps = cap_from_text("cap_net_bind_service=ep");
> 	if (caps == NULL) {
> 		xlog(L_ERROR, "Failed to allocate capability: %m");
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




