Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57083 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754710AbcCRGF1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Mar 2016 02:05:27 -0400
From: NeilBrown <neilb@suse.com>
To: William Dauchy <wdauchy@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Date: Fri, 18 Mar 2016 17:05:18 +1100
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc/cache: drop reference when sunrpc_cache_pipe_upcall() detects a race
In-Reply-To: <CAJ75kXZkt1rqZ9e9gBC1Feywr9w7Cuqscgd+6yWU5oqOmQvU+Q@mail.gmail.com>
References: <87y49ylq76.fsf@notabene.neil.brown.name> <20160314203846.GA22276@fieldses.org> <CAJ75kXbNjwaf-QWQPq1=ooUxAPmA5qBEH9jGv+k92NEr-4eJXQ@mail.gmail.com> <20160315131959.GA419@fieldses.org> <87vb4nh406.fsf@notabene.neil.brown.name> <CAJ75kXaWqMSgjp4U=M5Jz7VUXt_yJTo31MTQV0fh1R1TV9_W7Q@mail.gmail.com> <20160316150510.GE11520@fieldses.org> <CAJ75kXZkt1rqZ9e9gBC1Feywr9w7Cuqscgd+6yWU5oqOmQvU+Q@mail.gmail.com>
Message-ID: <87wpp0e2xt.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 17 2016, William Dauchy wrote:

> Hi Bruce,
>
> Thank your for your reply.
>
> On Wed, Mar 16, 2016 at 4:05 PM, J. Bruce Fields <bfields@fieldses.org> w=
rote:
>> Why is that?
>
> It's indeed not really based on actual proof but based on the experience =
we had.
> Faced several bugs, and it appears we had less issues by backporting a
> few commits; e.g related to races, leaks, performances regressions. We
> did not spent enough time on it to actually show this commit was
> actually fixing an issue hit.
>
>> Do you have a list?
>
> I am currently trying to switch from v3.14 to v4.1 (nfs client). So
> even know it is off topic, those I have in mind:
> 0d2a970 SUNRPC: Fix a backchannel race
> 6851447 SUNRPC: Fix a backchannel deadlock
> 0993920 SUNRPC: Prevent SYN+SYNACK+RST storms
> 03c78827 SUNRPC: Fix races between socket connection and destroy code
> a41cbe8 Failing to send a CLOSE if file is opened WRONLY and server
> reboots on a 4.x mount
> 39d0d3b NFS: Fix a tracepoint NULL-pointer dereference
> 5e99b53 nfs4: reset states to use open_stateid when returning
> delegation voluntarily
> e92c1e0 NFSv4: Fix a nograce recovery hang
> 6b55970 nfs: Fix a memory leak when meeting an unsupported state protect

Commit: 7632e465feb1 ("dcache: use IS_ROOT to decide where dentry is hashed=
")

is my most recent complaint - it really should have been tagged for
=2Dstable.  It is now in 3.12-stable, over 2 years later :-(

NeilBrown


>
> I am probably wrong on most of them but we had better stability after
> applying them and I probably forgot some.
>
>> I don't expect *proof*, necessarily, but some sort of argument would be
>> helpful.
>
> In my environment, if I hit this race, it is not acceptable to not
> being able to unmount the filesystem.
>
> Thanks,
> --=20
> William

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW65qeAAoJEDnsnt1WYoG5rfoQAMQMj1uspYRZYbfUpV4kpRnK
eji9ne8jTvooNBk2pnEuBuLYr57qHHXm1WrB9wwCVVfuEM0vnJ2YzvbWBwbk2gT2
r+6z4nItkNpk9meLy4kfWYeaoaBDvgzrVpipYBXLaIolzwGAEzSOfyZy8/til/Dw
YnfiUoYTEazNz9vx98XMGb+0MLu7IHyAI2ZlVPj21wsZfn4VFl8UQzRzx57xKdLQ
0tRLi8R2qHKjD82Wq7zLgywnzvG7vFVnBmPMxa+1FTTFPLWu8uYIwY/ktQ4Z1QIl
75V4fy0FGeDB2IQpdXCi7v11tImnIKiqEac7VGdQcJLvqR5OqnMi31yHDHP3/ydB
L7+4eZjq5Lba5iLnixwzrSBOzpJ29qzE3NLmkm/T2D83s+6r/kM5L/hbxGm3aucg
2ls/0UBX0ylxpA2ZejncoEM2XXChI8bEgdDkFRaBZ9U8TWiC3d05YyEiiu5zkeUT
kUJzv6402YHq/rHpwWzdfVqVQkIJSv/agIV7MqY7TLBaanWtS8b+IZpFL/fwIxPa
mSgZgnFWgnn+A4gRKrqJHGkJVb7MkUM75P/qoxg0QMPBYkuQ9NJbDbGFOynb4jgV
PqwebZBj6Zo6kOKrEJeN82rmxJjrDmzS4B4emmG/T2e/8C9FE3uI3MRxPb7d/djJ
YoGbymO7I3Dl1U6SBiri
=c4IC
-----END PGP SIGNATURE-----
--=-=-=--
