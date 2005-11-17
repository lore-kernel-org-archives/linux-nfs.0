From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Funny looking code in __rpc_purge_upcall
Date: Wed, 16 Nov 2005 22:10:00 -0500
Message-ID: <1132197000.8561.1.camel@lade.trondhjem.org>
References: <437BD49A.5070509@google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EcaAH-00036B-HZ
	for nfs@lists.sourceforge.net; Wed, 16 Nov 2005 19:10:21 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EcaAH-0002O2-0h
	for nfs@lists.sourceforge.net; Wed, 16 Nov 2005 19:10:21 -0800
To: Vince Busam <vbusam@google.com>
In-Reply-To: <437BD49A.5070509@google.com>
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

On Wed, 2005-11-16 at 16:53 -0800, Vince Busam wrote:
> In __rpc_purge_upcall (net/sunrpc/rpc_pipe.c), the newer code to clean up the in_upcall 
> list looks bad.  Shouldn't the first argument to list_entry() be rpci->in_upcall.next?

Doh! Well spotted!

That might explain the rpc-pipe related cleanup problem that Steve
Dickson has reported on the list earlier...

Cheers,
  Trond

> --- net/sunrpc/rpc_pipe.c.orig  2005-11-16 16:48:00.000000000 -0800
> +++ net/sunrpc/rpc_pipe.c       2005-11-16 16:52:23.000000000 -0800
> @@ -51,7 +51,7 @@ __rpc_purge_upcall(struct inode *inode,
>                  rpci->ops->destroy_msg(msg);
>          }
>          while (!list_empty(&rpci->in_upcall)) {
> -               msg = list_entry(rpci->pipe.next, struct rpc_pipe_msg, list);
> +               msg = list_entry(rpci->in_upcall.next, struct rpc_pipe_msg, list);
>                  list_del_init(&msg->list);
>                  msg->errno = err;
>                  rpci->ops->destroy_msg(msg);
> 
> Vince
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
> Register for a JBoss Training Course.  Free Certification Exam
> for All Training Attendees Through End of 2005. For more info visit:
> http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
