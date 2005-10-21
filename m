From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: Issue with parallel writes over NFS
Date: Fri, 21 Oct 2005 09:29:05 -0700
Message-ID: <1129912146.9014.24.camel@lade.trondhjem.org>
References: <D821697F08061F4FBB069FA1AAAA92370C4649@hoexmb7.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESzm0-0007D5-8C
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 09:29:40 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ESzly-0003WV-Tn
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 09:29:40 -0700
To: "Weathers, Norman R." <Norman.R.Weathers@conocophillips.com>
In-Reply-To: <D821697F08061F4FBB069FA1AAAA92370C4649@hoexmb7.conoco.net>
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

fr den 21.10.2005 klokka 11:08 (-0500) skreiv Weathers, Norman R.:
> Thanks for the pointer.  We think that the application may be
> able to do this.  Just for reference of mind, when you are saying
> page align block writes, are you meaning basically the page size
> of the vm (in this case, Opteron boxes running 64 bit FC3, which I
> am hoping is still 4k)?

I mean that we align the writes to the VM pages so that we write out
complete pages (much like we have always done with mmap()).

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
