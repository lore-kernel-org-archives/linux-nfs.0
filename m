From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: [PATCH] Auto-load RPC authentication kernel modules (client-side)
Date: Tue, 31 Jan 2006 11:00:48 -0500
Message-ID: <43DF89B0.4070600@citi.umich.edu>
References: <20060131101337.GF1462@suse.de>
Reply-To: cel@citi.umich.edu
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080105070203000901010900"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F3xw8-0008Iy-R4
	for nfs@lists.sourceforge.net; Tue, 31 Jan 2006 08:00:56 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F3xw4-0005rC-Kj
	for nfs@lists.sourceforge.net; Tue, 31 Jan 2006 08:00:54 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20060131101337.GF1462@suse.de>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------080105070203000901010900
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

i like it.  i suppose i should add similar logic to load transport 
modules automatically.

Olaf Kirch wrote:
> Summary: Auto-load RPC authentication kernel modules (client-side)
> 
> This patch adds a request_module call to rpcauth_create which will try
> to auto-load the kernel module for the requested authentication flavor.
> For kernels with modular sunrpc, this reduces the admin overhead for
> the user.
> 
> Signed-off-by: Olaf Kirch <okir@suse.de>
> 
>  net/sunrpc/auth.c |   16 ++++++++++++++--
>  1 files changed, 14 insertions(+), 2 deletions(-)
> 
> Index: build/net/sunrpc/auth.c
> ===================================================================
> --- build.orig/net/sunrpc/auth.c
> +++ build/net/sunrpc/auth.c
> @@ -64,14 +64,26 @@ rpcauth_create(rpc_authflavor_t pseudofl
>  	struct rpc_authops	*ops;
>  	u32			flavor = pseudoflavor_to_flavor(pseudoflavor);
>  
> -	if (flavor >= RPC_AUTH_MAXFLAVOR || !(ops = auth_flavors[flavor]))
> -		return ERR_PTR(-EINVAL);
> +	auth = ERR_PTR(-EINVAL);
> +	if (flavor >= RPC_AUTH_MAXFLAVOR)
> +		goto out;
> +
> +	/* FIXME - auth_flavors[] really needs an rw lock,
> +	 * and module refcounting. */
> +#ifdef CONFIG_KMOD
> +	if ((ops = auth_flavors[flavor]) == NULL)
> +		request_module("rpc-auth-%u", flavor);
> +#endif
> +	if ((ops = auth_flavors[flavor]) == NULL)
> +		goto out;
>  	auth = ops->create(clnt, pseudoflavor);
>  	if (IS_ERR(auth))
>  		return auth;
>  	if (clnt->cl_auth)
>  		rpcauth_destroy(clnt->cl_auth);
>  	clnt->cl_auth = auth;
> +
> +out:
>  	return auth;
>  }
>  


--------------080105070203000901010900
Content-Type: text/x-vcard; charset=utf-8;
 name="cel.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="cel.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Charles
org:Network Appliance, Incorporated;Open Source NFS Client Development
adr:535 West William Street, Suite 3100;;Center for Information Technology Integration;Ann Arbor;MI;48103-4943;USA
email;internet:cel@citi.umich.edu
title:Member of Technical Staff
tel;work:+1 734 763 4415
tel;fax:+1 734 763 4434
tel;home:+1 734 668 1089
x-mozilla-html:FALSE
url:http://troy.citi.umich.edu/u/cel/
version:2.1
end:vcard


--------------080105070203000901010900--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
