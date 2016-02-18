Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33803 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424396AbcBRGPS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Feb 2016 01:15:18 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Thu, 18 Feb 2016 17:15:09 +1100
Cc: linux-nfs@vger.kernel.org, Takashi Iwai <tiwai@suse.com>
Subject: Re: Concerns about SO_REUSEPORT usage in NFS client
In-Reply-To: <87y4ct91mu.fsf@notabene.neil.brown.name>
References: <87y4ct91mu.fsf@notabene.neil.brown.name>
Message-ID: <87si0qpms2.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


Hi Trond (or anyone),
 did you get a chance to look at this?
 It really seems that the SO_REUSEPORT solution has problems.

Thanks,
NeilBrown

On Thu, Dec 17 2015, NeilBrown wrote:

> Hi Trond et al.
>
> I have concerns about the new use of SO_REUSEPORT in the NFS client.
> Partly this is a theoretical concern.  The documentation in socket(7)
> talks about using this flag on UDP sockets and on TCP sockets in LISTEN
> mode, but not about using it with connected TCP sockets.  So the NFS
> usage isn't covered by the documentation ... maybe fixing the
> documentation would relieve that concern.
>
> But there is also a practical concern: it seems to sometime cause
> failures.
> This is reported here:
>     https://bugzilla.suse.com/show_bug.cgi?id=959216
>
> I cannot reproduce exactly the same symptoms as described there but I
> can get close. I:
>   - establish an NFSv3 mount to a server
>   - determine the port number used on the client side
>   - write numbers to /proc/sys/sunrpc/{min,max}_resvport which bracket
>     that port number in a range of 10 or so
>   - try to establish NFSv4 mounts in a loop (unmounting each time)
>
> Then the mount will sometimes hang.
> While it is hanging mount.nfs might be in permanently runnable and
> "cat /proc/`pidof mount.nfs`/stack" can show:
>
> [<ffffffff81001012>] ___preempt_schedule+0x12/0x14
> [<ffffffffffffffff>] 0xffffffffffffffff
>
>
> I've also sometime seen the stack trace mentioned in the bugzilla
>
> [<ffffffffa030b469>] xprt_connect+0x119/0x170 [sunrpc]
> [<ffffffffa0308c06>] call_connect+0x56/0xb0 [sunrpc]
> [<ffffffffa0312212>] __rpc_execute+0x82/0x450 [sunrpc]
> [<ffffffffa0314fda>] rpc_execute+0x5a/0xb0 [sunrpc]
> ....
>
> I typically see a 3 minute timeout before the mount fails with
>   mount.nfs: Connection timed out
>
> My guess is that SO_REUSEPORT can allow the NFSv4 mount to use the same
> connection that the NFSv3 mount is using, though over a different socket.
> NFSv4 sends a request, the reply is received by the NFSv3 client's socket
> which rejects it and the NFSv4 client keeps waiting.
>
> I think that we can only continue to use SO_REUSEPORT if we find a way
> to ensure that we don't re-use a currently active connection.
>
> NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWxWFtAAoJEDnsnt1WYoG5IX8P+gPEzFr09adGwjaT0VDILp4f
C5LnDJp1pOvFZyB5pXwCtSmJMHF86hiJ5Ivlu43lLWdKlHuJJCUSxGTlEqmD9qHX
lzdmm0ZYsbtE0sY4pvh0SJuak12NYIG6JCfDQzdpLmCkxeauwpzc01An3gHUU922
+8H0DWAijQZgrwMPmjBXn8aW5qoCgFtgA8qjeXkUNisVqxZegfkyogKTo+RYYzNI
qLG4XZqidKpiLxxDTSo+GAd/4barZi0dUvnwGzE947H/F4El/r/AReNzUSNCiOWs
3qkhQPdlfoFW+AVAtSfU2v8KdgkYA63hP0PBBIVkKLOOe74sD00/SumO3iNa8cKV
KpmzW0vO+cONl/qCwnHZgP7wn5u/78ECPdMZi4MofJRCyqSGJhe4wuhWKzJoKUAs
ecGRMlJgYTGgvjzkcZvM44vIHiHSSZkztikCZ7mWSM6SiuGHI7Ju1dfZTEDq436K
3AdtkYvx610LKAhWMRzZoop0Aj/oKSbz92rX7DH1MkBZ9sEL/ukPuKNzCgz1ETx4
PfMtAzFPRLxM2G06eh3RmeUTChhclwmjBUcFBzyvXemEd73eCY50e6H5ic3wrue0
qHu7hIFNaR+jiu5e82TN6Mg0suR4I0SBKw+NPZezRo9FK6c4GGQ5IafPmcFuXI+j
FzWu3QbFNpPf8+PSCijc
=kwdY
-----END PGP SIGNATURE-----
--=-=-=--
