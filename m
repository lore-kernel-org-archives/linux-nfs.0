From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs lock question...
Date: 24 Jun 2003 20:59:44 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsllvrti73.fsf@charged.uio.no>
References: <8147E1B07201DD41B6B9F0D31E07B384449147@srv-grp-s07.dev.atos.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Ut1H-0001w9-00
	for <nfs@lists.sourceforge.net>; Tue, 24 Jun 2003 11:59:55 -0700
To: Brasseur =?iso-8859-1?q?Val=E9ry?= <Valery.Brasseur@atosorigin.com>
In-Reply-To: <8147E1B07201DD41B6B9F0D31E07B384449147@srv-grp-s07.dev.atos.fr>
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

>>>>> " " =3D=3D Brasseur Val=E9ry <Valery.Brasseur@atosorigin.com> writes:

     > is it normal that when a process is stoppped (ctrl-z ;-) and he
     > has locks on a nfs-server

Yes. ctrl-z will normally suspend the process. It does nothing to kill
it...

     > if this nfs server reboot the stopped process does'nt reclaim
     > it's locks ?!!!

Why not? That's a separate thread...

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
