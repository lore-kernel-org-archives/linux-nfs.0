From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: strange lock problem
Date: 19 Jun 2003 10:20:09 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs8yryq912.fsf@charged.uio.no>
References: <8147E1B07201DD41B6B9F0D31E07B38444913A@srv-grp-s07.dev.atos.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net,  "'Lever, Charles'" <Charles.Lever@netapp.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19T359-0000hf-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Jun 2003 10:20:19 -0700
To: Brasseur =?iso-8859-1?q?Val=E9ry?= <Valery.Brasseur@atosorigin.com>
In-Reply-To: <8147E1B07201DD41B6B9F0D31E07B38444913A@srv-grp-s07.dev.atos.fr>
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

     > Having investigate more, I know see that sometimes 2 process
     > are able to obtain the same file lock !

If the rpc.statd monitoring is screwing with the filer (telling it
that the client has rebooted and that it must release all locks), then
this is indeed possible.

Is some process on the client perhaps restarting rpc.statd?

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
