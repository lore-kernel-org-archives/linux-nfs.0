Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:47470 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752731Ab2AZPfs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2012 10:35:48 -0500
Subject: Re: [PATCH 3.3.0-rc1 1/2] do_mounts: Change the nfs-mount retry min max delays.
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1327588962-16441-1-git-send-email-srinivas.kandagatla@st.com>
Date: Thu, 26 Jan 2012 10:35:31 -0500
Cc: linux-nfs@vger.kernel.org, akpm@linux-foundation.org, mingo@redhat.com,
        neilb@suse.de, stuart.menefy@st.com, bharrosh@panasas.com,
        rees@umich.edu
Message-Id: <EBFEB6A8-4943-4D9E-9139-73D14ACB32DD@oracle.com>
References: <1327588962-16441-1-git-send-email-srinivas.kandagatla@st.com>
To: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 26, 2012, at 9:42 AM, Srinivas KANDAGATLA wrote:

> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> 
> This patch attempts to minimize the delay in nfs root mount, which
> happens as side effect of nfs-root mount retry by changing the
> NFSROOT_TIMEOUT_MIN and NFSROOT_TIMEOUT_MAX values.
> 
> Current strategy is, if do_mount_root fails, sleep for 5 seconds for the
> second attempt followed by a 5<<1 seconds delay for each loop with a
> maximum of 30 seconds delay.
> For 5 retries it would take.
> 
> 	5 + 10 + 20 + 30 + 30 = 95 Seconds
> with
> 	each do_mount_root timeout @ 3-4 seconds x 5 = 15 seconds.
> 
> Which means Kernel can only attempt the succession root-mounts or panic
> after 110 seconds.
> 
> So changing min and max timeouts will have the below delays.
> 	0  + 1 + 3 + 7 + 15	= 26 Seconds.
> and with
> 	each do_mount_root timeout @ 3-4 seconds x 5 = 15 seconds.
> Which means Kernel can only attempt the succession root-mounts or panic
> after 41 seconds
> 
> As, do_mount_root timesout in 3-4 seconds which should be sufficient
> delay to start of the second nfs mount attempt and increasing delay
> after that makes more sense.
> 
> I clearly see an advantange in changing these values because, Without
> this patch my board mounts nfs in 9-10 seconds, however with this patch
> can mount nfs in 4-5 seconds.

This feels like tuning the default settings for a very specific set up.  In the original thread for this work, 41 seconds would probably not be long enough for the network switch to enable the port.

I don't have a better solution at this time, but I think the current defaults will work (possibly with added delay) on most systems, whereas the proposed settings will probably result in more panics.  I prefer to keep the current settings until we have a solution that doesn't break other systems.

> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> ---
> Hello All,
> With latest kernel I can see that my nfs-root mounts with big delay
> of 5 seconds when compared to 2.6.32. It took 9-10 seconds, where as in 2.6.32 it took 4-5 seconds.
> 
> However with modifications to NFSROOT_TIMEOUT_MIN and NFSROOT_TIMEOUT_MAX,  nfs root mounts as it used to do it in 2.6.32.
> As first nfs mount timeout itself introduces sufficient delay to start the second retry.
> I think changing the min-max values will help people to nfs boot there boards faster than it is in 3.3 kernel.
> 
> Comments ?
> 
> Thanks.
> srini
> 
> 
> 
> init/do_mounts.c |    6 +++---
> 1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/init/do_mounts.c b/init/do_mounts.c
> index ef6478f..b8214ce 100644
> --- a/init/do_mounts.c
> +++ b/init/do_mounts.c
> @@ -361,8 +361,8 @@ out:
> 
> #ifdef CONFIG_ROOT_NFS
> 
> -#define NFSROOT_TIMEOUT_MIN	5
> -#define NFSROOT_TIMEOUT_MAX	30
> +#define NFSROOT_TIMEOUT_MIN	1
> +#define NFSROOT_TIMEOUT_MAX	32
> #define NFSROOT_RETRY_MAX	5
> 
> static int __init mount_nfs_root(void)
> @@ -390,7 +390,7 @@ static int __init mount_nfs_root(void)
> 			break;
> 
> 		/* Wait, in case the server refused us immediately */
> -		ssleep(timeout);
> +		ssleep(timeout - 1);
> 		timeout <<= 1;
> 		if (timeout > NFSROOT_TIMEOUT_MAX)
> 			timeout = NFSROOT_TIMEOUT_MAX;
> -- 
> 1.6.3.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




