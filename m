From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [NFS PATCH] 2.6.0-test10 Invalidate cached inode attributes after rename
Date: Wed, 3 Dec 2003 20:25:25 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113020AC80D@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARlAJ-0005GD-Po
	for nfs@lists.sourceforge.net; Wed, 03 Dec 2003 20:32:35 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1ARlAJ-0003lD-Iv
	for nfs@lists.sourceforge.net; Wed, 03 Dec 2003 20:32:35 -0800
To: "Paul Smith" <pausmith@nortelnetworks.com>,
        "Shantanu Goel" <Shantanu.Goel@lehman.com>
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

> %% "Shantanu Goel" <Shantanu.Goel@lehman.com> writes:
>=20
>   sg> 1. Check out a CVS repository into an NFS mounted directory.
>   sg> 2. Move files from CVS working directory into another=20
> directory in the
>   sg> same filesystem.
>   sg> 3. Tar up the resultant directory.
>   sg> 4. Tar prints lots of "file changed after we read it" messages.
>=20
> Interesting: I see this exact same message when taring up the contents
> of a ClearCase view (in 2.4.20-x)... even though I'm 100%=20
> positive that
> no one but me is touching those files.  Is this scenario relevant to a
> kernel that old as well?

yes, steve dickson at red hat also found this problem in 2.4.21.


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
