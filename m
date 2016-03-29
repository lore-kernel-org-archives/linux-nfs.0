Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38794 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753916AbcC2Wrn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Mar 2016 18:47:43 -0400
From: NeilBrown <neilb@suse.com>
To: Chuck Lever <chuck.lever@oracle.com>
Date: Wed, 30 Mar 2016 09:47:36 +1100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Should NLM resends change the xid ??
In-Reply-To: <9E0C02EA-2A3C-4B88-8557-B17D8864ED78@oracle.com>
References: <877fgnwkuv.fsf@notabene.neil.brown.name> <9E0C02EA-2A3C-4B88-8557-B17D8864ED78@oracle.com>
Message-ID: <877fgkvr3r.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 30 2016, Chuck Lever wrote:

> Hi Neil-
>
> Ramblings inline.
>
>
>> On Mar 27, 2016, at 7:40 PM, NeilBrown <neilb@suse.com> wrote:
>>=20
>>=20
>> I've always thought that NLM was a less-than-perfect locking protocol,
>> but I recently discovered as aspect of it that is worse than I imagined.
>>=20
>> Suppose client-A holds a lock on some region of a file, and client-B
>> makes a non-blocking lock request for that region.
>> Now suppose as just before handling that request the lockd thread
>> on the server stalls - for example due to excessive memory pressure
>> causing a kmalloc to take 11 seconds (rare, but possible.  Such
>> allocations never fail, they just block until they can be served).
>>=20
>> During this 11 seconds (say, at the 5 second mark), client-A releases
>> the lock - the UNLOCK request to the server queues up behind the
>> non-blocking LOCK from client-B
>>=20
>> The default retry time for NLM in Linux is 10 seconds (even for TCP!) so
>> NLM on client-B resends the non-blocking LOCK request, and it queues up
>> behind the UNLOCK request.
>>=20
>> Now finally the lockd thread gets some memory/CPU time and starts
>> handling requests:
>> LOCK from client-B  - DENIED
>> UNLOCK from client-A - OK
>> LOCK from client-B - OK
>>=20
>> Both replies to client-B have the same XID so client-B will believe
>> whichever one it gets first - DENIED.
>>=20
>> So now we have the situation where client-B doesn't think it holds a
>> lock, but the server thinks it does.  This is not good.
>>=20
>> I think this explains a locking problem that a customer is seeing.  The
>> application seems to busy-wait for the lock using non-blocking LOCK
>> requests.  Each LOCK request has a different 'svid' so I assume each
>> comes from a different process. If you busy-wait from the one process
>> this problem won't occur.
>>=20
>> Having a reply-cache on the server lockd might help, but such things
>> easily fill up and cannot provide a guarantee.
>
> What would happen if the client serialized non-blocking
> lock operations for each inode? Or, if a non-blocking
> lock request is outstanding on an inode when another
> such request is made, can EAGAIN be returned to the
> application?

I cannot quite see how this is relevant.
I imagine one app on one client is using non-blocking requests to try to
get a lock, and a different app on a different client holds, and then
drops, the lock.
I don't see how serialization on any one client will change that.

>
>
>> Having a longer timeout on the client would probably help too.  At the
>> very least we should increase the maximum timeout beyond 20 seconds.
>> (assuming I reading the code correctly, the client resend timeout is
>> based on nlmsvc_timeout which is set from nlm_timeout which is
>> restricted to the range 3-20).
>
> A longer timeout means the client is slower to respond to
> slow or lost replies (ie, adjusting the timeout is not
> consequence free).

True.  But for NFS/TCP the default timeout is 60 seconds.
For NLM/TCP the default is 10 seconds and a hard upper limit is 20
seconds.
This, at least, can be changed without fearing consequences.

>
> Making the RTT slightly longer than this particular server
> needs to recharge its batteries seems like a very local
> tuning adjustment.

This is exactly what I've ask out partner to experiment with.  No
results yet.

>
>
>> Forcing the xid to change on every retransmit (for NLM) would ensure
>> that we only accept the last reply, which I think is safe.
>
> To make this work, then, you'd make client-side NLM
> RPCs soft, and the upper layer (NLM) would handle
> the retries. When a soft RPC times out, that would
> "cancel" that XID and the client would ignore
> subsequent replies for it.

Soft, with zero retransmits I assume.  The NLM client already assumes
"hard" (it doesn't pay attention to the "soft" NFS option).  Moving that
indefinite retry from sunrpc to lockd would probably be easy enough.


>
> The problem is what happens when the server has
> received and processed the original RPC, but the
> reply itself is lost (say, because the TCP
> connection closed due to a network partition).
>
> Seems like there is similar capacity for the client
> and server to disagree about the state of the lock.

I think that as long as the client sees the reply to the *last* request,
they will end up agreeing.
So if requests can be re-order you could have problems, but tcp protects
us again that.

I'll have a look at what it would take to get NLM to re-issue requests.

Thanks,
NeilBrown


>
>
> --
> Chuck Lever
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW+wYIAAoJEDnsnt1WYoG5WEUP/0tKjhDmvSqceAAd132iKgjG
RPXV0/ZxDuet3l4y+S5CWHrRzqOBbzjF4omKjG/WENHUOVbwUYdncr3gu46flgGD
TDX/1ip0hXHdQwVmZg83w23CiwE8NI0E/QfbJIuRIlsGMPoTp8I/6hdRgEBwhg33
w8ndNWlmHfxFyESHWVKCdtU8wsVrt0QBY1g1A6p+JDfelfnMy9pwpXiCtMgchbJU
EpGyZd2zVYzKbyzxbx1TxZa75s13wd6ASycTSPMJqYvreAgjbPm/zLeGKsOn9i7Z
r8YLgp1LMlxLU+VQVXosmyWLaDhqhXHyMnvVNqrKi5zmN2AvY18N1vFHwSIhRMFT
Q+JwoKjpp5nGy/+C5+AFvqAMynbjvqxzScG7I9OCHr+QhGr0v6Xjx+/6fY1m4xBL
pNc74uIg3p4fOESgkH6lmdfSzWmyv/E87qIOMIjcflUhtTgxwr5lK3RuHhqAT45q
BRqNVj1pFLXiU6kJHrTUuIk5WySM5MojGnWpxTfIrFAaArs4+XfM6qTTQLyFb6sr
jKhuRNLJe2sKU+mcHKI9an228VI1VGS7yNm6Y7lhJ3DpIECl5pufKpKvDU09/315
tX3XFhKe2fyKS+mVC29ff1mTKPmQIyEenhVNdeCd6ZcwoZeLIdYL0iZc9HtOm7bh
oriXnO1yenszYxKyOVjf
=EmlX
-----END PGP SIGNATURE-----
--=-=-=--
