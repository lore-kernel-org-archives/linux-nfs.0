From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: nfs: server X not responding, still trying
Date: Tue, 4 Nov 2003 08:08:24 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113020AC618@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AH3nl-0003FD-00
	for <nfs@lists.sourceforge.net>; Tue, 04 Nov 2003 08:13:05 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AH3nk-00067j-Ri
	for nfs@lists.sourceforge.net; Tue, 04 Nov 2003 08:13:04 -0800
To: "Timothy G. Wesemann" <timwese@voicenet.com>
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

> The client mount/fstab options are:
> "rw,async,intr,vers=3D3,rsize=3D32768,wsize=3D32768" and the=20
> server's exports
> options are: "rw,no_root_squash,async,no_subtree_check".

i am obligated to provide a friendly warning about using
the "async" export option.  see the Linux NFS FAQ
(http://nfs.sourceforge.net) for details.

the async mount option is not needed, as async is the default.

with UDP, we usually recommend using a smaller rsize and wsize,
say, 8192, because large requests are more likely to overrun
switch port buffers and socket buffers.

> After digging through the archives, I found some references to Trond's
> patches for 2.4.22 (which didn't seem to help in this=20
> situation) as well as
> suggestions to revert back to 2.4.20 which seem to have helped the
> situation. I also tried using TCP which worked great, but the=20
> performance hit was too great.

what was the performance difference between UDP and TCP?

> These error accumulations now are much more rare with 2.4.20,=20
> however they
> still exist and performance is still not what it should be.=20
> Also, we really
> would prefer to run current release-quality kernel revs.

what you describe sounds like a networking problem.  since
your client and server are both linux systems, you can do
some end-to-end network performance testing.  i recommend
iperf (google) with both UDP and TCP.  you may find that
your switch is dropping packets even though your network
is not congested.


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
