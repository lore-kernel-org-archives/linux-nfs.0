Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35784 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933239AbbLQDsR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Dec 2015 22:48:17 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Thu, 17 Dec 2015 14:48:09 +1100
Cc: linux-nfs@vger.kernel.org, Takashi Iwai <tiwai@suse.com>
Subject: Concerns about SO_REUSEPORT usage in NFS client
Message-ID: <87y4ct91mu.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


Hi Trond et al.

I have concerns about the new use of SO_REUSEPORT in the NFS client.
Partly this is a theoretical concern.  The documentation in socket(7)
talks about using this flag on UDP sockets and on TCP sockets in LISTEN
mode, but not about using it with connected TCP sockets.  So the NFS
usage isn't covered by the documentation ... maybe fixing the
documentation would relieve that concern.

But there is also a practical concern: it seems to sometime cause
failures.
This is reported here:
    https://bugzilla.suse.com/show_bug.cgi?id=959216

I cannot reproduce exactly the same symptoms as described there but I
can get close. I:
  - establish an NFSv3 mount to a server
  - determine the port number used on the client side
  - write numbers to /proc/sys/sunrpc/{min,max}_resvport which bracket
    that port number in a range of 10 or so
  - try to establish NFSv4 mounts in a loop (unmounting each time)

Then the mount will sometimes hang.
While it is hanging mount.nfs might be in permanently runnable and
"cat /proc/`pidof mount.nfs`/stack" can show:

[<ffffffff81001012>] ___preempt_schedule+0x12/0x14
[<ffffffffffffffff>] 0xffffffffffffffff


I've also sometime seen the stack trace mentioned in the bugzilla

[<ffffffffa030b469>] xprt_connect+0x119/0x170 [sunrpc]
[<ffffffffa0308c06>] call_connect+0x56/0xb0 [sunrpc]
[<ffffffffa0312212>] __rpc_execute+0x82/0x450 [sunrpc]
[<ffffffffa0314fda>] rpc_execute+0x5a/0xb0 [sunrpc]
....

I typically see a 3 minute timeout before the mount fails with
  mount.nfs: Connection timed out

My guess is that SO_REUSEPORT can allow the NFSv4 mount to use the same
connection that the NFSv3 mount is using, though over a different socket.
NFSv4 sends a request, the reply is received by the NFSv3 client's socket
which rejects it and the NFSv4 client keeps waiting.

I think that we can only continue to use SO_REUSEPORT if we find a way
to ensure that we don't re-use a currently active connection.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWcjB5AAoJEDnsnt1WYoG59IUP/2uy5nO61M8NRTs2g2ixyXkr
nU81MXmn4eBbR8HER1aN7YIcFqclPg/5BrCezt45cLvDogh11irT00CSEqauRIim
jVbxecSERVvfkXk1021UZ6xWJ/ULfCfW4jmQwDDJMQ5+KU39uWhAizsjmzCvMdIB
t83JERp5Z+POtjegKDIwPltmUL6njgKCVIfD3B2hjTMr+EyfYeh9tnkgJHYhgYT6
HgQANM0gU2pMznnkTvevaTn/EJgbDELlShfZ96gSuQxRpS3207NIkf9nb+QegXcM
nZw7TrNi4MHRfzKLxi5cI6vHoACRhY/17nMDNIIhqWQb54saYZbWWZpaNL4jmyUc
xSR7WaBIv67uubV5rX1eI5jLS1+/PBnoHK7U5eWtSX2SUrTzqHp34BG0djVTd8Bh
OO7UpFNtDn5mpCx/pGKigMe6GQ/lD0kmqFBXwYSMIz/JueTQvJHbATfAWCcFzF0v
aUqQJeEzJQ0Ed3OSSl9+SiNl5yqyy4j24ZKjFchyVM9ruNhvmkKqPNMVoXf7V8UD
nZanNTOrKrd4Ffma4y+K1YcskpVfyDwBu3kHf20eCCEoAqsPT29YV1KbR5ccrtpL
GRSpMhiIWun8d10zP23WqvGkCq7Pn0orXPCfCwAmqrsZ97a13AZm0cvcI8pOWU5u
1g4qSGeek66ETFXMXZtu
=ZPpe
-----END PGP SIGNATURE-----
--=-=-=--
