From: <trond.myklebust@fys.uio.no>
Subject: 2.6.0 -- nfs client runs 15x faster if client app runs as root.
Date: Wed, 7 Jan 2004 22:54:38 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <34280.141.211.133.197.1073512478.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AeLdY-0007xJ-1s
	for nfs@lists.sourceforge.net; Wed, 07 Jan 2004 13:54:48 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AeLdX-0004xu-JQ
	for nfs@lists.sourceforge.net; Wed, 07 Jan 2004 13:54:47 -0800
To: <ewhiting@amis.com>
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

> My 2.6.0 nfs clients to a netapps 940 NFS server run very differently
depending
> on who the user is. Both tcp and udp mounts seem to show the same behavior.
> This is very apparent when doing the bonnie putc() tests.
> nfsstat and tcpdump show a lot of extra setattr calls when running as a
normal
> user. I assume this is the reason for the slowdown. Is there a fix? Or
is this the
> way it is supposed to be?

Huh?
I'm certainly not seeing one setattr call per write on my 2.6 clients. Is
this stock
2.6.0 or is it patched? Does 2.6.1-rc2 change anything?

If not, can you capture a binary tcpdump of these setattr calls, so we can
have a
look at what they are trying to do? "tcpdump -w dump.out -s 9000" should
suffice.

Cheers,
  Trond




-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
