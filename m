From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: historical question: nfs_rename()
Date: Tue, 18 Oct 2005 11:36:40 -0700
Message-ID: <1129660600.12268.38.camel@lade.trondhjem.org>
References: <044B81DE141D7443BCE91E8F44B3C1E288E57B@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ERwL7-0008VE-Sw
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 11:37:34 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ERwL4-0004H0-J5
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 11:37:33 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <044B81DE141D7443BCE91E8F44B3C1E288E57B@exsvl02.hq.netapp.com>
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

ty den 18.10.2005 klokka 11:15 (-0700) skreiv Lever, Charles:
> this is going in the right direction.
> 
> should we quickly look at other test cases?  what return code should/do
> you get when you try to rename a directory onto a target directory that
> still has stuff in it?

I think the server is going to have to handle that. There is no way for
the client to atomically check the directory for emptiness and rename.

> have you tested both the file onto directory and directory onto file
> cases?

Still untested, but the check I introduced should ensure that
file-onto-directory works as expected. The directory-onto-file behaviour
is unchanged.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
