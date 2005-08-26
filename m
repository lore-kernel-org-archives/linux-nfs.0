From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: diskless linux client device permissions problem
Date: Fri, 26 Aug 2005 15:48:11 -0700
Message-ID: <1125096491.8042.62.camel@lade.trondhjem.org>
References: <430F8D14.9050904@x-iss.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, Deepak Khosla <dkhosla@x-iss.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E8mzu-0003GG-9x
	for nfs@lists.sourceforge.net; Fri, 26 Aug 2005 15:48:30 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1E8mzt-0005Mh-3D
	for nfs@lists.sourceforge.net; Fri, 26 Aug 2005 15:48:30 -0700
To: Alex Cresswell <acresswell@x-iss.com>
In-Reply-To: <430F8D14.9050904@x-iss.com>
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

fr den 26.08.2005 Klokka 16:43 (-0500) skreiv Alex Cresswell:
> On the NFS client I'm running 2.4.21-4.ELsmp, and the NFS server is
> running 2.4.21-20.ELsmp.  The export file has the flags rw and
> no_root_squash, but I've also tried the sync flag to no effect.  On
> the client I've tried the actimeo=0 flag, which also had no effect on
> the issue.  

As far as I can see from Chuck's copy of the 2.4.21-4.EL source code,
there is a bug in the way RedHat have patched the special inode
operations in order to add ACL support: for reasons best known to
themselves, they appear to have thought it is a good idea to turn off
basic NFS operations like permission checking, setattr, and
revalidation.

I suggest you take this up on their bugzilla site. This is not something
that needs fixing in the mainline tree.

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
