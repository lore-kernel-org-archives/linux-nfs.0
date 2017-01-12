Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59978 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750957AbdALUr3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 12 Jan 2017 15:47:29 -0500
Date: Thu, 12 Jan 2017 15:47:22 -0500
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, Andreas Gruenbacher <agruenba@redhat.com>,
        Matthieu Herrb <matthieu.herrb@laas.fr>
Subject: Re: [PATCH] NFSv4.2: Fix file creating with O_EXCL get a bad mode
Message-ID: <20170112204722.GC10501@fieldses.org>
References: <a76cec59-f007-5c26-dc26-4cc8a6e4daef@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <a76cec59-f007-5c26-dc26-4cc8a6e4daef@gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jan 07, 2017 at 10:45:47PM +0800, Kinglong Mee wrote:
> Acorrding to Matthieu Herrb's test cases, a new created file will
> get a bad mode as 0666 (expected 0644) after commit dff25ddb4808
> "nfs: add support for the umask attribute".
> 
> It is caused by missing check of FATTR4_WORD2_MODE_UMASK
> in nfs4_exclusive_attrset.

I don't understand:

> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 6dcbc5d..a3e9ef1 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2697,7 +2697,8 @@ static inline void nfs4_exclusive_attrset(struct nfs4_opendata *opendata,
>  		sattr->ia_valid |= ATTR_MTIME;
>  
>  	/* Except MODE, it seems harmless of setting twice. */
> -	if ((attrset[1] & FATTR4_WORD1_MODE))
> +	if ((attrset[1] & FATTR4_WORD1_MODE) ||
> +	    (attrset[2] & FATTR4_WORD2_MODE_UMASK))
>  		sattr->ia_valid &= ~ATTR_MODE;

If I'm understanding this function correctly, attrset is the set of
attributes which the server tells us were used to store the verifier.

But mode_umask would never be a sensible place to store the
verifier, so if the server's response really says that then something's
wrong.

We should probably look at a network trace.

--b.

>  
>  	if (attrset[2] & FATTR4_WORD2_SECURITY_LABEL)
> -- 
> 2.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
