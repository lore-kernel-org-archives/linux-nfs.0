From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfsroot clients hang while mounting second NFS server
Date: 11 Jul 2003 11:34:10 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsvfu976gd.fsf@charged.uio.no>
References: <57BDE604-B33E-11D7-A405-000A95703418@improbable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19auIJ-00025L-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Jul 2003 02:34:23 -0700
To: Chris Adams <chris@improbable.org>
In-Reply-To: <57BDE604-B33E-11D7-A405-000A95703418@improbable.org>
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


Looks like it hangs just after a GETPORT call. Any info on what that
GETPORT call is for (i.e. what the arguments are)? Ethereal should be
able to decode that information for you...

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
