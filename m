Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:63671 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892Ab1LDMZJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 07:25:09 -0500
Received: by eeaq14 with SMTP id q14so1482893eea.19
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2011 04:25:08 -0800 (PST)
Message-ID: <4EDB66A1.6010301@tonian.com>
Date: Sun, 04 Dec 2011 14:25:05 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: tigran.mkrtchyan@desy.de
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsv41: add current stateid into compound_state
References: <1323000237-13565-1-git-send-email-tigran.mkrtchyan@desy.de> <1323000237-13565-2-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1323000237-13565-2-git-send-email-tigran.mkrtchyan@desy.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-12-04 14:03, tigran.mkrtchyan@desy.de wrote:
> From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> 
> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  fs/nfsd/xdr4.h |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index 2364747..7f26edd 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -54,6 +54,7 @@ struct nfsd4_compound_state {
>  	size_t			iovlen;
>  	u32			minorversion;
>  	u32			status;
> +	stateid_t		current_stateid;
>  };
>  
>  static inline bool nfsd4_has_session(struct nfsd4_compound_state *cs)

nit: since the new member gets to be used only in the next patch
they might as well be squashed together...

Thanks,

Benny
