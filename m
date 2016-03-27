Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33861 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754238AbcC0Xkc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Mar 2016 19:40:32 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
	by mx2.suse.de (Postfix) with ESMTP id 7758BAC13
	for <linux-nfs@vger.kernel.org>; Sun, 27 Mar 2016 23:40:30 +0000 (UTC)
From: NeilBrown <neilb@suse.com>
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Date: Mon, 28 Mar 2016 10:40:24 +1100
Subject: Should NLM resends change the xid ??
Message-ID: <877fgnwkuv.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


I've always thought that NLM was a less-than-perfect locking protocol,
but I recently discovered as aspect of it that is worse than I imagined.

Suppose client-A holds a lock on some region of a file, and client-B
makes a non-blocking lock request for that region.
Now suppose as just before handling that request the lockd thread
on the server stalls - for example due to excessive memory pressure
causing a kmalloc to take 11 seconds (rare, but possible.  Such
allocations never fail, they just block until they can be served).

During this 11 seconds (say, at the 5 second mark), client-A releases
the lock - the UNLOCK request to the server queues up behind the
non-blocking LOCK from client-B

The default retry time for NLM in Linux is 10 seconds (even for TCP!) so
NLM on client-B resends the non-blocking LOCK request, and it queues up
behind the UNLOCK request.

Now finally the lockd thread gets some memory/CPU time and starts
handling requests:
 LOCK from client-B  - DENIED
 UNLOCK from client-A - OK
 LOCK from client-B - OK

Both replies to client-B have the same XID so client-B will believe
whichever one it gets first - DENIED.

So now we have the situation where client-B doesn't think it holds a
lock, but the server thinks it does.  This is not good.

I think this explains a locking problem that a customer is seeing.  The
application seems to busy-wait for the lock using non-blocking LOCK
requests.  Each LOCK request has a different 'svid' so I assume each
comes from a different process. If you busy-wait from the one process
this problem won't occur.

Having a reply-cache on the server lockd might help, but such things
easily fill up and cannot provide a guarantee.

Having a longer timeout on the client would probably help too.  At the
very least we should increase the maximum timeout beyond 20 seconds.
(assuming I reading the code correctly, the client resend timeout is
based on nlmsvc_timeout which is set from nlm_timeout which is
restricted to the range 3-20).

Forcing the xid to change on every retransmit (for NLM) would ensure
that we only accept the last reply, which I think is safe.

Thoughts?

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW+G9oAAoJEDnsnt1WYoG53DMP/RVYzjE9Y15TFSSzgpsUdySm
pMdHTpB7QEZ9bH32seBZhgcIQwChpHZekb669uBPYtdQhvPmZCFu9RGR8JqYmHEK
rVF/WuxJFiJcram+fhcDFoM0TVJsHxgcsbFQVfJPzoAlZallXxo6RH8ZCAFgf77q
Ofb2YPNWr3YE9t9utp666ya8+zxj5EOOOZKTFMcn8+aYPP3PvSSXMwnX1onkQIvl
AXXgYNCltp1bJYJ8WUi3gwEiEmlpCwuFPwgVjCJuU6VT/8pZ/4k5I0RGcd4piJph
LFrnJb1K+Xwwc20bLXdym+HxnbHvZzlFoe0EE3aul3OUnA/ooYbaLkeOPll9BBUw
2FmV+w9TSzCorZYlQ/BwWPhjjv7io3ADb7llqnr6ht/opqzbqYmAuGr1zFWosMOw
GhwbOuuWIa0riaqZ8+CDSYV1HeB2nOj6rfb3MV/1vM3UiFlx9afEhebws/COoWTJ
SPL+65jUZHo1bPm0yOYEad57776L3nt3Z9LxE4zBq+n9g17vz5EG1Kc/J6xbbfQs
0+3uEZPE5QS+Xw6Wthtj8vmAiWdIl2D9o8Wnhna2Xc/3TdhOgdlcfFXtgz5fB4RJ
5FEf2to1rEcmoRPyIYx2Xpa/MYLe6/fJ1LZaCJnaz2bjCLv4mGKsm6AJsONRuUQv
UpoKPnz5qVhmb8oBcJaj
=MrOL
-----END PGP SIGNATURE-----
--=-=-=--
