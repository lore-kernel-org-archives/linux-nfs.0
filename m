From: "Chris Croswhite" <csc@cadence.com>
Subject: RE: Re: [NFS client] NFS locks not released on abnormal process termination
Date: Tue, 9 Dec 2003 10:54:08 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <EE335453C5C57840823404C684F9F61702417581@exmbx01sj.cadence.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Cc: "Kenny Simpson" <theonetruekenny@yahoo.com>,
        <linux-kernel@vger.kernel.org>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ATmzy-0003we-BU
	for nfs@lists.sourceforge.net; Tue, 09 Dec 2003 10:54:18 -0800
Received: from mailgate2.cadence.com ([158.140.2.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1ATmzx-00072t-Fb
	for nfs@lists.sourceforge.net; Tue, 09 Dec 2003 10:54:17 -0800
To: "Philippe Troin" <phil@fifi.org>,
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

Philippe,

What patches are you refering to?

TIA,
Chris


-----Original Message-----
From:	Philippe Troin [mailto:phil@fifi.org]
Sent:	Tue 09-Dec-03 10:46
To:	Trond Myklebust
Cc:	Kenny Simpson; linux-kernel@vger.kernel.org; =
nfs@lists.sourceforge.net
Subject:	[NFS] Re: [NFS client] NFS locks not released on abnormal =
process termination
Trond Myklebust <trond.myklebust@fys.uio.no> writes:

> >>>>> " " =3D=3D Philippe Troin <phil@fifi.org> writes:
>=20
>      > From my reading of the patch, it supersedes the old patch, and
>      > is only
>      > necessary on the client. Is also does not compile :-)
>=20
> Yeah, I admit I didn't test it out...
>=20
>      > Here's an updated patch which does compile.
>=20
> Thanks.
>=20
>      > I am still running tests, but so far it looks good (that is all
>      > locks are freed when a process with locks running on a NFS
>      > client is killed).
>=20
> Good...

I've ran test overnight on four boxen, and no locks were lost.
I guess you can send this patch to Marcello now.

I've tested with the enclosed program.

=20
> There are still 2 other issues with the generic POSIX locking code.
> Both issues have to do with CLONE_VM and have been raised on
> linux-kernel & linux-fsdevel. Unfortunately they met with no response,
> so I'm unable to pursue...

Can we help? Pointers?

Phil.





-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
