From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [NFS PATCH] 2.6.0-test10 Invalidate cached inode attributes after rename
Date: Thu, 4 Dec 2003 07:34:16 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113020AC815@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "Paul Smith" <pausmith@nortelnetworks.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARvUv-0008Bu-3n
	for nfs@lists.sourceforge.net; Thu, 04 Dec 2003 07:34:33 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1ARvUu-000161-OS
	for nfs@lists.sourceforge.net; Thu, 04 Dec 2003 07:34:32 -0800
To: "Shantanu Goel" <Shantanu.Goel@lehman.com>
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

i'll state this more carefully --

the problem is exposed after trond's readdirplus patch is
applied to 2.4.2x.

> -----Original Message-----
> From: Shantanu Goel [mailto:Shantanu.Goel@lehman.com]
> Sent: Thursday, December 04, 2003 10:27 AM
> To: Lever, Charles
> Cc: Paul Smith; nfs@lists.sourceforge.net
> Subject: Re: [NFS] [NFS PATCH] 2.6.0-test10 Invalidate cached inode
> attributes after rename
>=20
>=20
> Stock 2.4 kernels don't exhibit this behaviour because they always=20
> invalidate attributes for the last component of the path if CTO is=20
> enabled, see fs/nfs/dir.c:nfs_lookup_verify_inode().  In 2.6 and 2.4=20
> kernels such as AS3's 2.4.21, with the newer CTO patches,=20
> this code was=20
> changed to only do so when the file is being opened.  I am=20
> surprised you=20
> are seeing this on 2.4.20 since I can't replicate it on 2.4.22.
>=20
> Shantanu
>=20
> Lever, Charles wrote:
>=20
> >>%% "Shantanu Goel" <Shantanu.Goel@lehman.com> writes:
> >>
> >>  sg> 1. Check out a CVS repository into an NFS mounted directory.
> >>  sg> 2. Move files from CVS working directory into another=20
> >>directory in the
> >>  sg> same filesystem.
> >>  sg> 3. Tar up the resultant directory.
> >>  sg> 4. Tar prints lots of "file changed after we read it"=20
> messages.
> >>
> >>Interesting: I see this exact same message when taring up=20
> the contents
> >>of a ClearCase view (in 2.4.20-x)... even though I'm 100%=20
> >>positive that
> >>no one but me is touching those files.  Is this scenario=20
> relevant to a
> >>kernel that old as well?
> >>   =20
> >>
> >
> >yes, steve dickson at red hat also found this problem in 2.4.21.
> >
> > =20
> >
>=20
>=20
>=20
> --------------------------------------------------------------
> ----------------
> This message is intended only for the personal and=20
> confidential use of the
> designated recipient(s) named above.  If you are not the=20
> intended recipient of
> this message you are hereby notified that any review, dissemination,
> distribution or copying of this message is strictly prohibited.  This
> communication is for information purposes only and should not=20
> be regarded as
> an offer to sell or as a solicitation of an offer to buy any financial
> product, an official confirmation of any transaction, or as=20
> an official
> statement of Lehman Brothers.  Email transmission cannot be=20
> guaranteed to be
> secure or error-free.  Therefore, we do not represent that=20
> this information is
> complete or accurate and it should not be relied upon as such.  All
> information is subject to change without notice.
>=20
>=20


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
