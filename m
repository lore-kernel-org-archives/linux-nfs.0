From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS changement between 2.6.9 and 2.6.10?
Date: Wed, 26 Jan 2005 11:50:53 -0800
Message-ID: <1106769053.15132.29.camel@lade.trondhjem.org>
References: <41F77473.70501@zaide.org>
	 <1106768614.15132.27.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CttCG-0007VV-MK
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 11:51:24 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CttCF-0007k1-3Z
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 11:51:24 -0800
To: "Damien \"Zaide\"" <list@zaide.org>
In-Reply-To: <1106768614.15132.27.camel@lade.trondhjem.org>
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

on den 26.01.2005 Klokka 11:43 (-0800) skreiv Trond Myklebust:
> on den 26.01.2005 Klokka 11:44 (+0100) skreiv Damien "Zaide":
> > hi,
> > I have a nfsV3 server running linux 2.6.9, all is good when I "ls -alR" 
> > my nfs exported directory on my client after I chroot() in this 
> > directory and ls -alR too that well.
> > But when i update my server to linux 2.6.10 and "ls -alR" my nfs 
> > directory is allways good but when I chroot() inside, my chroot command 
> > is locked and I can't ls my nfs directory.
> > I have launch a sniffer and the packet seams to be send.
> > Do you have any informations about this? a changement beetwen 2.6.9 and 
> > 2.6.10? a patch? a bug?
> 
> I don't see how an NFS change could do this. The VFS is the part of the
> kernel that handles the actual details of chroot. NFS neither knows nor
> cares.

The other thing is that there were no NFS client changes that went in
between 2.6.9 and 2.6.10. 8-)

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
