From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: historical question: nfs_rename()
Date: Tue, 18 Oct 2005 11:11:54 -0700
Message-ID: <1129659114.12268.30.camel@lade.trondhjem.org>
References: <044B81DE141D7443BCE91E8F44B3C1E288E579@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Staubach <staubach@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ERvwc-0007CT-Ld
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 11:12:14 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ERvwZ-000596-PL
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 11:12:14 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <044B81DE141D7443BCE91E8F44B3C1E288E579@exsvl02.hq.netapp.com>
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

ty den 18.10.2005 klokka 10:59 (-0700) skreiv Lever, Charles:
> the specific case i'm whining about today is renaming a directory to an
> empty directory.  the desired semantic is that the empty directory will
> be replaced.  the existing semantic on the Linux NFS client is that
> rename(2) returns -EBUSY.

A well-written testcase speaks louder than 1000 words (and avoids much
confusion on my part). ;-)

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
