From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfsroot clients hang while mounting second NFS server
Date: Fri, 11 Jul 2003 21:27:04 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16143.3976.461700.641401@charged.uio.no>
References: <shsvfu976gd.fsf@charged.uio.no>
	<EDE12792-B3D2-11D7-A405-000A95703418@improbable.org>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19b3Y4-0002oq-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Jul 2003 12:27:16 -0700
To: Chris Adams <chris@improbable.org>
In-Reply-To: <EDE12792-B3D2-11D7-A405-000A95703418@improbable.org>
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


The program is asking for NFSv3, but the reply gives a port for NFSv2.
Is your server supposed to support NFSv3 and, if not, have you tried
specifying the 'v2' mount option?

cheers,
  Trond


-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
