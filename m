From: Martynas Buozis <martynas@ti.com>
Subject: Re: nfsroot problems on RedHat 8 with kernel linux-2.4.18-27.8.0
Date: Mon, 26 May 2003 13:47:22 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3ED1FECA.2030105@ti.com>
References: <3ECE0EF3.5080004@ti.com>	<shs4r3lx1ux.fsf@charged.uio.no>	<3ECE2479.3000706@ti.com>	<16078.12509.988134.109974@charged.uio.no>	<003401c321ad$9a438180$6464a8c0@foxie> <16081.15177.472767.206769@charged.uio.no>
Reply-To: martynas@ti.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from go4.ext.ti.com ([192.91.75.132])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19KGRs-0006We-00
	for <nfs@lists.sourceforge.net>; Mon, 26 May 2003 04:47:28 -0700
To: trond.myklebust@fys.uio.no
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Trond


Great ! Wonderful ! It is working now ! Thank you very much for your 
kind help.

Linux specialist from EMC support is still investigating this question ...


With best regards
Martynas


Trond Myklebust wrote:
>>>>>>" " == Martynas Buozis <martynas@ti.com> writes:
>>>>>
> 
>      > informtion as required by Celerra, so mount request is
>      > denied. When I use mount from command line on booted RedHat 8
>      > system to mount same file system - it sends all required
>      > information and Celerra accepts mount request.
> 
> OK. I misunderstood you (sorry). You were talking about the mount
> protocol, and I was thinking about the NFS protocol itself.
> 
> The following patch ought to suffice...
> 
> Cheers,
>   Trond
> 
> --- linux-2.4.21-up/fs/nfs/mount_clnt.c.orig	2002-10-15 18:32:18.000000000 +0200
> +++ linux-2.4.21-up/fs/nfs/mount_clnt.c	2003-05-25 23:50:12.000000000 +0200
> @@ -75,7 +75,7 @@
>  
>  	clnt = rpc_create_client(xprt, hostname,
>  				&mnt_program, version,
> -				RPC_AUTH_NULL);
> +				RPC_AUTH_UNIX);
>  	if (!clnt) {
>  		xprt_destroy(xprt);
>  	} else {
> 



-- 

With best regards
Martynas Buozis
UNIX Systems Administrator
FFAB Computer Engineering



-------------------------------------------------------------
Martynas Buozis            Texas Instruments Deutschland GmbH
Mail:  martynas@ti.com     Haggertystrasse 1
Phone: +49 8161 80 4506    85356 Freising
Fax:   +49 8161 80 3191    Germany



-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
