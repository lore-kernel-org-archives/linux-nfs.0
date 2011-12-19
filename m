Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2669 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751497Ab1LSOV7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Dec 2011 09:21:59 -0500
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH] [Trivial]: nfs : Fix typo in dir.c
Date: Mon, 19 Dec 2011 06:21:42 -0800
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C863B42@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <1324304223-10047-1-git-send-email-standby24x7@gmail.com>
References: <1324304223-10047-1-git-send-email-standby24x7@gmail.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Masanari Iida" <standby24x7@gmail.com>, <linux-kernel@vger.kernel.org>,
        <jkosina@suse.cz>
Cc: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Masanari Iida [mailto:standby24x7@gmail.com]
> Sent: Monday, December 19, 2011 9:17 AM
> To: linux-kernel@vger.kernel.org; jkosina@suse.cz; Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org; Masanari Iida
> Subject: [PATCH] [Trivial]: nfs : Fix typo in dir.c
> 
> Fix typo "iff" -> "if" in dir.c
> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>
> To: Jiri Kosina <jkosina@suse.cz>
> To: Trond Myklebust <Trond.Myklebust@netapp.com>
> To: linux-nfs@vger.kernel.org
> ---
>  fs/nfs/dir.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c index ac28990..ad32d4e 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1127,7 +1127,7 @@ static int nfs_lookup_revalidate(struct dentry
> *dentry, struct nameidata *nd)
>  	if (nfs_have_delegation(inode, FMODE_READ))
>  		goto out_set_verifier;
> 
> -	/* Force a full look up iff the parent directory has changed */
> +	/* Force a full look up if the parent directory has changed */
>  	if (!nfs_is_exclusive_create(dir, nd) && nfs_check_verifier(dir,
> dentry)) {
>  		if (nfs_lookup_verify_inode(inode, nd))
>  			goto out_zap_parent;
> --
> 1.7.6.4

That's not a typo. Iff is a common abbreviation for "if and only if".
Google it...

Cheers
  Trond
