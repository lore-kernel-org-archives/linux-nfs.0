From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: IOStat with NFS
Date: Tue, 9 Dec 2003 07:18:04 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07ACE@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <jeremymc@sce.carleton.ca>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ATjcq-0000b3-WD
	for nfs@lists.sourceforge.net; Tue, 09 Dec 2003 07:18:12 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1ATjcq-0003vo-OF
	for nfs@lists.sourceforge.net; Tue, 09 Dec 2003 07:18:12 -0800
To: <jeremy@mcnicoll.ca>
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

hi jeremy-

iostat for NFS is a good idea, thanks for pursuing it.

some general comments.

1.  as you noted, 2.4 is more or less closed for new features,
    so it would be better to start looking closely at 2.6.

2.  instead of an NFS only solution, you might want to consider
    a more general solution for all network file systems, like
    AFS, coda, samba, and so on.

3.  instead of simulating block device statistics for file systems
    that don't use blocks, why not invent a different paradigm for
    network file systems, and teach iostat to use that?

4.  you will bump into the minor device limitation with your
    design, allowing only 250 or so mounts to appear; you should
    consider how to scale your solution to thousands of mounts.

5.  i've only glanced at your code, but you appear to have some
    layering violations, like putting NFS-specific code in the
    generic file system layers.  see if you can find a way of
    implementing this without violating the interface
    architecture.

6.  you need to worry about the mounts changing in the background,
    mostly by automounter, while iostat gathers statistics...
    maybe you have worried about that, and this is why you have
    violated the architecture as you did.  some discussion of
    how your solution handles such races would be illuminating
    for us poor reviewers.

> -----Original Message-----
> From: jeremy@mcnicoll.ca [mailto:jeremy@mcnicoll.ca]=20
> Sent: Sunday, December 07, 2003 3:37 PM
> To: nfs@lists.sourceforge.net
> Cc: jeremymc@sce.carleton.ca
> Subject: [NFS] IOStat with NFS
>=20
>=20
> As a project for school (engineering) I modified IOStat on a=20
> 2.4.22 or 23=20
> series kernel to allow for NFS data output.  This may be=20
> useful for some people=20
> here.  I am in the middle of exams, so I cant get back to=20
> anyone too quickly on=20
> this but if any one is interested in what I did the patches are here.=20
>=20
http://www.mcnicoll.ca/iostatnfs/iostats.html

Hopefully people can give me constructive criticism on this work since
its=20
getting marked and I would like to see community acceptance.=20

Any pointers, tips, useful info to help towards the report that I have
to write=20
would be greatly appreciated.=20

Some of the things to be done when I finish exams are:=20
  -clean up code.
  -look at getting it working on 2.6 since there are no more changes to
2.4
  -report bug on the disk stats that  I found while doing the work.
  -try to get this worked into the kernel.=20
  -Use the feedback that I get to help with the documenation.=20

Thank you.=20




-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
