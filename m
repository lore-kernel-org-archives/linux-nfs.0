Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50194 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753015AbaAVS37 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jan 2014 13:29:59 -0500
Date: Wed, 22 Jan 2014 13:29:58 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs4.1: add basic SECINFO_NO_NAME support
Message-ID: <20140122182958.GE13704@fieldses.org>
References: <1389716850-1260-1-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1389716850-1260-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 14, 2014 at 11:27:30AM -0500, Weston Andros Adamson wrote:
> only returns AUTH_SYS for now

Thanks, applied.

--b.

> 
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
> ---
>  nfs4.1/nfs4server.py | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/nfs4.1/nfs4server.py b/nfs4.1/nfs4server.py
> index b279292..65fb9af 100755
> --- a/nfs4.1/nfs4server.py
> +++ b/nfs4.1/nfs4server.py
> @@ -1161,6 +1161,13 @@ class NFS4Server(rpc.Server):
>          env.set_cfh(self.root)
>          return encode_status(NFS4_OK)
>  
> +    def op_secinfo_no_name(self, arg, env):
> +        check_session(env)
> +        # xxx add gss support
> +        secinfo4_list = [ secinfo4(rpc.AUTH_SYS) ]
> +        res = SECINFO_NO_NAME4res(NFS4_OK, secinfo4_list)
> +        return encode_status(NFS4_OK, res)
> +
>      # op_putpubfh SHOULD be the same as op_putrootfh
>      # See draft23, section 18.20.3, line 25005
>      op_putpubfh = op_putrootfh
> -- 
> 1.8.3.4 (Apple Git-47)
> 
