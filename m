Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:65064 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790Ab0KVRPq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Nov 2010 12:15:46 -0500
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rcsinet10.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id oAMHFieI003465
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 22 Nov 2010 17:15:46 GMT
Received: from acsmt355.oracle.com (acsmt355.oracle.com [141.146.40.155])
	by acsinet15.oracle.com (Switch-3.4.2/Switch-3.4.1) with ESMTP id oAM5vqHD011416
	for <linux-nfs@vger.kernel.org>; Mon, 22 Nov 2010 17:15:43 GMT
Subject: Re: [PATCH] lockd: release memory for non-normal situation
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <201011221243.oAM931FO003822@rcsinet13.oracle.com>
Date: Mon, 22 Nov 2010 12:15:32 -0500
Cc: linux-nfs@vger.kernel.org, greg.marsden@oracle.com, joe.jin@oracle.com
Message-Id: <86295CE6-C2D8-4186-BF51-455A5C190F3A@oracle.com>
References: <201011221243.oAM931FO003822@rcsinet13.oracle.com>
To: Wengang Wang <wen.gang.wang@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi-

On Nov 22, 2010, at 7:40 AM, Wengang Wang wrote:

> nlmclnt_proc() is neither releasing nlm_rqst nor dropping the ref on nlm_host.
> Do the release work though I am not sure if it can really hit the situation.

Based on casual code review, the only case where this is a possibility is the "out_unlock" label in nlmclnt_lock().  Otherwise, this patch introduces a double release in other cases, doesn't it?

Is there a reproducer that can demonstrate a leak?

> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> ---
> fs/lockd/clntproc.c |    4 +++-
> 1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
> index 332c54c..ec9f0f5 100644
> --- a/fs/lockd/clntproc.c
> +++ b/fs/lockd/clntproc.c
> @@ -173,8 +173,10 @@ int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl)
> 			status = nlmclnt_unlock(call, fl);
> 	} else if (IS_GETLK(cmd))
> 		status = nlmclnt_test(call, fl);
> -	else
> +	else {
> +		nlm_release_call(call);
> 		status = -EINVAL;
> +	}
> 	fl->fl_ops->fl_release_private(fl);
> 	fl->fl_ops = NULL;

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




