From: "Ogden, Aaron A." <aogden@unocal.com>
Subject: RE: ~800 mountpoint limitation
Date: Mon, 15 Dec 2003 09:46:11 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6AB920CC10586340BE1674976E0A991D0C6BD1@slexch2.sugarland.unocal.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Ogden, Aaron A." <aogden@unocal.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AVuva-0000Ce-VQ
	for nfs@lists.sourceforge.net; Mon, 15 Dec 2003 07:46:34 -0800
Received: from unogate.unocal.com ([192.94.3.1])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AVuvY-00069I-4r
	for nfs@lists.sourceforge.net; Mon, 15 Dec 2003 07:46:32 -0800
To: "Ian Kent" <raven@themaw.net>,
        "Trond Myklebust" <trond.myklebust@fys.uio.no>
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



> -----Original Message-----
> From: Ian Kent [mailto:raven@themaw.net]=20
> Sent: Monday, December 15, 2003 7:34 AM
> To: Trond Myklebust
> Cc: Ogden, Aaron A.; nfs@lists.sourceforge.net
> Subject: RE: [NFS] ~800 mountpoint limitation
>=20
> [---snip---]
>=20
> If the patch is OK with you then I will have a go at back porting it
to=20
> 2.4. If Aaron is able to, we can have him hammer it to death and
perhaps=20
> collect some performance data.
>=20
> Comments please?
> Ian

Sounds great, I am running autofs-4.1.0 on two test machines and have
not encountered any problems yet.  The test machines are RH 7.3 with
kernel 2.4.20-24 + autofs4-20031201.  The patch discussed in this thread
is intended to correct the RPC problems yes? (limit of ~800 mountpoints,
etc.)  If it works I feel that it would be a welcome addition to linux
even if it isn't strictly necessary for most people.

I have other machines I can run the new code on, so yes, I can test it
out.  We have more than 800 users so I can break the old code just by
walking down the auto_home map.  Hopefully the new code will be able to
handle more mounts and at greater speed without failing... =20

-A


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
