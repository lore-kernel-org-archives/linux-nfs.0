Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:49144 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965584AbbBEA0u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Feb 2015 19:26:50 -0500
Date: Thu, 5 Feb 2015 11:26:41 +1100
From: NeilBrown <neilb@suse.de>
To: Nix <nix@esperi.org.uk>
Cc: bfields@fieldses.org (J. Bruce Fields),
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: what on earth is going on here? paths above mountpoints turn
 into "(unreachable)"
Message-ID: <20150205112641.60340f71@notabene.brown>
In-Reply-To: <87r3u58df2.fsf@spindle.srvr.nix>
References: <87iofju9ht.fsf@spindle.srvr.nix>
	<20150203195333.GQ22301@fieldses.org>
	<87egq6lqdj.fsf@spindle.srvr.nix>
	<87r3u58df2.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/IpU=HLld6siC+fjRzT3FxGG"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/IpU=HLld6siC+fjRzT3FxGG
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 04 Feb 2015 23:28:17 +0000 Nix <nix@esperi.org.uk> wrote:

> On 3 Feb 2015, nix@esperi.org.uk outgrape:
>=20
> > On 3 Feb 2015, J. Bruce Fields spake thusly:
> >
> >> On Tue, Feb 03, 2015 at 12:25:18AM +0000, Nix wrote:
> >>> I'm seeing this bizarre output after a long delay (memory pressure not
> >>> required: vapoursynth, which was running here, is using a couple of g=
ig
> >>> out of 16GiB, and the machine has 12GiB in buffers/cache):
> >>>=20
> >>> FileNotFoundError: [Errno 2] No such file or directory: '(unreachable=
)/Orphan-Black/1'
> >>
> >> Haven't really read this carefully, just noticed the ENOENT.  There was
> >> 49a068f82a "rpc: fix xdr_truncate_encode to handle buffer ending on pa=
ge
> >> boundary" recently, fixing a problem introduced in 3.16 that could I
> >> think cause an enoent if Orphan-Black/ was a large-ish directory.
> >
> > It's got three files in it. Orphan-Black/1 has fifteen. Way under, say,
> > a page.
> >
> > The problem hasn't recurred since I mounted /usr/archive and
> > /usr/archive/series explicitly rather than relying on nohide, so I'd
> > guess the problem lies there: it is, after all, evil.
>=20
> It doesn't. It still recurs.

Is /usr/archive still exported to mutilate with crossmnt?
If it is, can you change to not do that (it is quite possible to have
different export options for different clients).

I think that if crossmnt is enabled on the server, then explicitly
mounting /usr/archive/series will have the same net effect as not doing so
(though I'm not 100% certain).

Also, can you try changing
   /proc/sys/fs/nfs/nfs_mountpoint_timeout

It defaults to 500 (seconds - time for light from Sun to reach Earth).
If you make it smaller and the problem gets worse, or make it much bigger
and the problem goes away, that would be interesting.
If it makes no difference, that also would be interesting.

NeilBrown

>=20
> If I cd out of the tree entirely (say, to /tmp) then back in, the
> mountpoint often reconnects for all its users: if I do things in there
> (e.g. an ls) it always seems to. If I cd within the disconnected subtree
> via a relative path, it doesn't.
>=20
> So running this often helps:
>=20
> while sleep 300; do cd /usr/archive/series/Orphan-Black/2; ls > /dev/null=
; cd /tmp; done
>=20
> but not always -- if the thing vanishes <300s before the last problem,
> we're still in for it.
>=20


--Sig_/IpU=HLld6siC+fjRzT3FxGG
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVNK4wTnsnt1WYoG5AQJFPQ//QnJFyrbVTbm/mByV/C+kAznmwyb6yUtu
3oP35No9Nk9BZKafOw5mIeAURUo0LiG+oCXMpzVsjIwWuyeticScfWfOlNM5vXee
pmhEMynzdz2WQnBNhjYbC1rOjOfkCn9C2WtbAa4jQqhgUBLdgZT2VWgUJKhDHhTT
zjkOfRHNeWrhrRdlc4/AS6Tt2KbFK33h7nZiX9GEpRbsOCVb3O6kDzDuBdmhLZOo
GToFKPSL9bTxpA52kyXWcfJyfmlVFd1StOX4n5195aJJoP3tARvHohQjl7I+4HJO
Re1TNcg7+iZCMgIgzkQQbhJQPUSl/+rPsJsBhyYPDDemRQ1a2Hw1MjC8iady9Bcq
VGuSGv79SydGKGbMJxQfcQIM7GdXHI+SkB03JIIBwvnTFczue5OarTx5n7C8hLWQ
+5o3HPYZeKKmEIFVzmDxOCMwiH9nHu0wSrUCNSX8CdPY2xuYfJB5PljvslpjchZ0
XRsClnMDgKCpztiRQeNXvgFpRVzJiPIxMnoO+QJ97WHJ3vchInw4l1SmnGxscceZ
2ahdD2ksw0rBkmsEhJBYjc7l0SGhRSM/m2AhCCnhzFdOF2SPcdd/6okcOBg2DLjG
3eAFpkuHSWhoUiTVjU1C8ODi1FYveuFP0DGnD8QWVCT1rmFGY4pY0loxxtWmxeMf
UvCQlljaiSs=
=ug5v
-----END PGP SIGNATURE-----

--Sig_/IpU=HLld6siC+fjRzT3FxGG--
