From: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
Subject: RE: 2.4.19 NFSALL performance oddity
Date: Sat, 5 Oct 2002 20:56:44 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B9160C772C@poexmb3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail1.conoco.com ([12.31.208.226])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17y0f1-0002PY-00
	for <nfs@lists.sourceforge.net>; Sat, 05 Oct 2002 18:56:47 -0700
To: "Bryan O'Sullivan" <bos@serpentine.com>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


The only extra patches to 2.4.19 are the NFS patches, so
I don't believe so unless it was included in 2.4.19.

We are using config_himem, because at least some of the
machines we have will have a bit too much memory.

I will try turning that off and see if it makes a difference, is
this on the client or the server or both?   I am pretty sure
we have it enabled on all of the nfsall patched 2.4.19 builts.

				Roger

> -----Original Message-----
> From:	Bryan O'Sullivan [SMTP:bos@serpentine.com]
> Sent:	Saturday, October 05, 2002 3:55 PM
> To:	Trond Myklebust
> Cc:	Heflin, Roger A.; nfs@lists.sourceforge.net
> Subject:	Re: [NFS] 2.4.19 NFSALL performance oddity
>=20
> On Sat, 2002-10-05 at 09:18, Trond Myklebust wrote:
>=20
> > I'm seeing major slowdowns, mainly on NFS reads, when I enable
> > CONFIG_HIGHMEM. I haven't yet had time to investigate this.
>=20
> I'll try to take a look on a local system in the next few days.  Are =
you
> or Roger using Jens Axboe's block-highmem patch or any of the drivers =
it
> touches?  Knowing this should help control for at least one variable.
>=20
> 	<b
>=20


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
