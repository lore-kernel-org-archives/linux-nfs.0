From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,
	PATCH 3/15] knfsd: initialize RDMA transport in sunrpc
Date: Fri, 18 May 2007 15:09:20 -0400
Message-ID: <464DF9E0.3050104@oracle.com>
References: <1179510296.23385.116.camel@trinity.ogc.int>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080404090707060206060709"
Cc: Neil Brown <neilb@suse.de>,
	Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp7qm-0001mv-2Z
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 12:10:52 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hp7qn-0000Ke-HS
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 12:10:55 -0700
In-Reply-To: <1179510296.23385.116.camel@trinity.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------080404090707060206060709
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

As part of the client side transport switch, I constructed a transport 
"register" and "unregister" interface so that when a transport module is 
loaded, it's init routine is invoked automatically, and likewise when it 
is unloaded its cleanup routine is automatically invoked.

I'd like to see the same here.  I don't think we want to create a 
situation where you have to make source code changes in order to add new 
transport capabilities.  Especially the distributors would be allergic 
to such a constraint.

Please consider this change while going about the process of integrating 
the server-side transport switch with your RDMA transport.

Tom Tucker wrote:
> Add calls to the svc_rdma initialization and cleanup routines to the
> sunrpc module init logic.
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  net/sunrpc/sunrpc_syms.c |   10 +++++++++-
>  1 files changed, 9 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
> index 43ecf62..16a50c9 100644
> --- a/net/sunrpc/sunrpc_syms.c
> +++ b/net/sunrpc/sunrpc_syms.c
> @@ -20,7 +20,9 @@ #include <linux/sunrpc/svcsock.h>
>  #include <linux/sunrpc/auth.h>
>  #include <linux/workqueue.h>
>  #include <linux/sunrpc/rpc_pipe_fs.h>
> -
> +#ifdef CONFIG_NFSD_RDMA
> +#include <linux/sunrpc/svc_rdma.h>
> +#endif
>  
>  /* RPC scheduler */
>  EXPORT_SYMBOL(rpc_execute);
> @@ -158,6 +160,9 @@ #endif
>  	cache_register(&ip_map_cache);
>  	cache_register(&unix_gid_cache);
>  	init_socket_xprt();
> +#ifdef CONFIG_NFSD_RDMA
> +	err = svc_rdma_init();
> +#endif
>  out:
>  	return err;
>  }
> @@ -175,6 +180,9 @@ cleanup_sunrpc(void)
>  #ifdef RPC_DEBUG
>  	rpc_unregister_sysctl();
>  #endif
> +#ifdef CONFIG_NFSD_RDMA
> +	svc_rdma_cleanup();
> +#endif
>  #ifdef CONFIG_PROC_FS
>  	rpc_proc_exit();
>  #endif
> 
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


--------------080404090707060206060709
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel/
version:2.1
end:vcard


--------------080404090707060206060709
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------080404090707060206060709
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080404090707060206060709--
