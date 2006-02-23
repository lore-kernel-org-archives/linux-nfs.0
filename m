From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] more verbose output for rpc auth weak error
Date: Thu, 23 Feb 2006 14:10:18 -0500
Message-ID: <1140721818.7874.35.camel@lade.trondhjem.org>
References: <2c1942a70602100150q630758eqda2565831ccd7d81@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, Olaf Kirch <okir@suse.de>,
	NeilBrown <neilb@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCLrF-0007aL-NY
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 11:10:33 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FCLrE-0008DI-2J
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 11:10:33 -0800
To: Levent Serinol <lserinol@gmail.com>
In-Reply-To: <2c1942a70602100150q630758eqda2565831ccd7d81@mail.gmail.com>
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

On Fri, 2006-02-10 at 11:50 +0200, Levent Serinol wrote:
> Summary: more verbose output for rpc auth weak error
> 
> This patch adds server ip address to be printed out when "server
> requires stronger authentication" error occured.


Your email program managed to badly mangle the patch itself, but I've
fixed it up and included it in the latest NFS_ALL.

Cheers,
  Trond

> Signed-off-by: Levent Serinol <lserinol@gmail.com>
> 
> ==============================================
> --- linux-2.6.16-rc2/net/sunrpc/clnt.c.org      2006-02-10
> 10:17:01.000000000 +0200
> +++ linux-2.6.16-rc2/net/sunrpc/clnt.c  2006-02-10 10:23:53.000000000 +0200
> @@ -1193,8 +1193,8 @@ call_verify(struct rpc_task *task)
>                         task->tk_action = call_bind;
>                         goto out_retry;
>                 case RPC_AUTH_TOOWEAK:
> -                       printk(KERN_NOTICE "call_verify: server
> requires stronger "
> -                              "authentication.\n");
> +                       printk(KERN_NOTICE "call_verify: server %s
> requires stronger "
> +                              "authentication.\n",task->tk_client->cl_server);
>                         break;
>                 default:
>                         printk(KERN_WARNING "call_verify: unknown auth
> error: %x\n", n);
> ==============================================
> 
> 
> 
> 
> --
> 
> Stay out of the road, if you want to grow old.
> ~ Pink Floyd ~.



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
