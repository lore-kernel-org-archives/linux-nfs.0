From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 10/22] Add new pipefs file indicating which Kerberos
 enctypes the kernel supports
Date: Mon, 15 Mar 2010 12:28:23 -0400
Message-ID: <1268670503.2993.103.camel@localhost.localdomain>
References: <1268655627-18712-1-git-send-email-steved@redhat.com>
	 <1268655627-18712-11-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:57382 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965330Ab0COQ22 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Mar 2010 12:28:28 -0400
In-Reply-To: <1268655627-18712-11-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2010-03-15 at 08:20 -0400, steved@redhat.com wrote: 
> From: Kevin Coffman <kwc@citi.umich.edu>
> 
> New file, krb5_info, indicates which Kerberos encryption types are
> supported by the kernel rpcsecgss code.  This is used by gssd to
> determine which encryption types it should attempt to negotiate
> when creating a context with a server.
> 
> The server principal's database and keytab encryption types are
> what limits what it should negotiate.  Therefore, its keytab
> should be created with only the enctypes listed by this file.
> 
> From: J. Bruce Fields <bfields@citi.umich.edu>
> Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  net/sunrpc/rpc_pipe.c |   31 +++++++++++++++++++++++++++++++
>  1 files changed, 31 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index 8d63f8f..2230b52 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -397,6 +397,31 @@ static const struct file_operations rpc_info_operations = {
>  	.release	= rpc_info_release,
>  };
>  
> +/*
> + * This really belongs in the gss_krb5 code,
> + * but the info file logically belongs here
> + */

No. We should rather export __rpc_create() to allow this code to be
moved to the gss_krb5 module.



