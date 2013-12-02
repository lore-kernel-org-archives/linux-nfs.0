Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55749 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752355Ab3LBQzG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Dec 2013 11:55:06 -0500
Date: Mon, 2 Dec 2013 11:55:05 -0500
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Add missing recording of back channel attrs in
 nfsd4_session
Message-ID: <20131202165505.GL1960@fieldses.org>
References: <2BCCA4EF-9FCC-4320-85E1-AD500467C95D@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2BCCA4EF-9FCC-4320-85E1-AD500467C95D@gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 26, 2013 at 10:25:20PM +0800, Kinglong Mee wrote:
> commit 5b6feee9608dce7afd2646f457c93e612526d1d8 forgot
> recording the back channel attrs in nfsd4_session.
> 
> nfsd just check the back channel attars by check_backchannel_attrs,
> but do not  record it in nfsd4_session in the latest kernel.

Whoops.  So the current server is returning random uninitialized data in
those fields, or all zeros?

It would be easy enough to write a pynfs test for this, I think.

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4state.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 105d6fa..1aed9be 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -999,6 +999,8 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
>  	spin_unlock(&nn->client_lock);
>  	memcpy(&new->se_fchannel, &cses->fore_channel,
>  			sizeof(struct nfsd4_channel_attrs));
> +	memcpy(&new->se_bchannel, &cses->back_channel,
> +			sizeof(struct nfsd4_channel_attrs));
>  	if (cses->flags & SESSION4_BACK_CHAN) {
>  		struct sockaddr *sa = svc_addr(rqstp);
>  		/*
> -- 
> 1.8.1.4
> 
