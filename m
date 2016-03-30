Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45358 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752569AbcC3BCQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Mar 2016 21:02:16 -0400
From: NeilBrown <neilb@suse.com>
To: Chuck Lever <chuck.lever@oracle.com>
Date: Wed, 30 Mar 2016 12:02:03 +1100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Should NLM resends change the xid ??
In-Reply-To: <1BABF7B1-0EFB-4208-8D53-59C3FA25C7FB@oracle.com>
References: <877fgnwkuv.fsf@notabene.neil.brown.name> <9E0C02EA-2A3C-4B88-8557-B17D8864ED78@oracle.com> <877fgkvr3r.fsf@notabene.neil.brown.name> <1BABF7B1-0EFB-4208-8D53-59C3FA25C7FB@oracle.com>
Message-ID: <871t6svkvo.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 30 2016, Chuck Lever wrote:

>> On Mar 29, 2016, at 6:47 PM, NeilBrown <neilb@suse.com> wrote:
>>=20
>> On Wed, Mar 30 2016, Chuck Lever wrote:
>>=20
>>> Hi Neil-
>>>=20
>>> Ramblings inline.
>>>=20
>>>=20
>>>> On Mar 27, 2016, at 7:40 PM, NeilBrown <neilb@suse.com> wrote:
>>>>=20
>>>>=20
>>>> I've always thought that NLM was a less-than-perfect locking protocol,
>>>> but I recently discovered as aspect of it that is worse than I imagine=
d.
>>>>=20
>>>> Suppose client-A holds a lock on some region of a file, and client-B
>>>> makes a non-blocking lock request for that region.
>>>> Now suppose as just before handling that request the lockd thread
>>>> on the server stalls - for example due to excessive memory pressure
>>>> causing a kmalloc to take 11 seconds (rare, but possible.  Such
>>>> allocations never fail, they just block until they can be served).
>>>>=20
>>>> During this 11 seconds (say, at the 5 second mark), client-A releases
>>>> the lock - the UNLOCK request to the server queues up behind the
>>>> non-blocking LOCK from client-B
>>>>=20
>>>> The default retry time for NLM in Linux is 10 seconds (even for TCP!) =
so
>>>> NLM on client-B resends the non-blocking LOCK request, and it queues up
>>>> behind the UNLOCK request.
>>>>=20
>>>> Now finally the lockd thread gets some memory/CPU time and starts
>>>> handling requests:
>>>> LOCK from client-B  - DENIED
>>>> UNLOCK from client-A - OK
>>>> LOCK from client-B - OK
>>>>=20
>>>> Both replies to client-B have the same XID so client-B will believe
>>>> whichever one it gets first - DENIED.
>>>>=20
>>>> So now we have the situation where client-B doesn't think it holds a
>>>> lock, but the server thinks it does.  This is not good.
>>>>=20
>>>> I think this explains a locking problem that a customer is seeing.  The
>>>> application seems to busy-wait for the lock using non-blocking LOCK
>>>> requests.  Each LOCK request has a different 'svid' so I assume each
>>>> comes from a different process. If you busy-wait from the one process
>>>> this problem won't occur.
>>>>=20
>>>> Having a reply-cache on the server lockd might help, but such things
>>>> easily fill up and cannot provide a guarantee.
>>>=20
>>> What would happen if the client serialized non-blocking
>>> lock operations for each inode? Or, if a non-blocking
>>> lock request is outstanding on an inode when another
>>> such request is made, can EAGAIN be returned to the
>>> application?
>>=20
>> I cannot quite see how this is relevant.
>> I imagine one app on one client is using non-blocking requests to try to
>> get a lock, and a different app on a different client holds, and then
>> drops, the lock.
>> I don't see how serialization on any one client will change that.
>
> Each client and the server need to agree on the state of
> a lock. If the client can send more than one non-blocking
> request at the same time, it will surely be confused when
> the requests or replies are misordered. IIUC this is
> exactly what sequence IDs are for in NFSv4.
>

If a client sends two different non-blocking requests they will have
different "svid" (aka client-side pid) values.  Providing the client
gets replies to both requests it shouldn't be confused about the
outcome.

Except... if two threads in the same process try non-blocking locks at
the same time....  That is probably a recipe for confusion, but I don't
think NLM makes it more confusing.
If the lock gets granted on the server, then it is quite possible that
either or both threads will think that they got the lock (as a lock held
by one thread does not conflict with a lock held by the other).  But at
least one thread will think it owns it.
If the lock doesn't get granted, neither threads will think they have it.

>
>>>> Having a longer timeout on the client would probably help too.  At the
>>>> very least we should increase the maximum timeout beyond 20 seconds.
>>>> (assuming I reading the code correctly, the client resend timeout is
>>>> based on nlmsvc_timeout which is set from nlm_timeout which is
>>>> restricted to the range 3-20).
>>>=20
>>> A longer timeout means the client is slower to respond to
>>> slow or lost replies (ie, adjusting the timeout is not
>>> consequence free).
>>=20
>> True.  But for NFS/TCP the default timeout is 60 seconds.
>> For NLM/TCP the default is 10 seconds and a hard upper limit is 20
>> seconds.
>> This, at least, can be changed without fearing consequences.
>
> The consequences are slower recovery from dropped requests.

Is NLM more likely to drop requests than NFS?

>
>
>>> Making the RTT slightly longer than this particular server
>>> needs to recharge its batteries seems like a very local
>>> tuning adjustment.
>>=20
>> This is exactly what I've ask out partner to experiment with.  No
>> results yet.
>
> It may indeed help this customer, but my point is this is
> not a reason to make a change to the shrink-wrap defaults.
>

Even if those defaults are inconsistent? Treating NLM very differently
From=20NFS?

>
>>>> Forcing the xid to change on every retransmit (for NLM) would ensure
>>>> that we only accept the last reply, which I think is safe.
>>>=20
>>> To make this work, then, you'd make client-side NLM
>>> RPCs soft, and the upper layer (NLM) would handle
>>> the retries. When a soft RPC times out, that would
>>> "cancel" that XID and the client would ignore
>>> subsequent replies for it.
>>=20
>> Soft, with zero retransmits I assume.  The NLM client already assumes
>> "hard" (it doesn't pay attention to the "soft" NFS option).  Moving that
>> indefinite retry from sunrpc to lockd would probably be easy enough.
>>=20
>>=20
>>>=20
>>> The problem is what happens when the server has
>>> received and processed the original RPC, but the
>>> reply itself is lost (say, because the TCP
>>> connection closed due to a network partition).
>>>=20
>>> Seems like there is similar capacity for the client
>>> and server to disagree about the state of the lock.
>>=20
>> I think that as long as the client sees the reply to the *last* request,
>> they will end up agreeing.
>
> Can you show how you proved this to be the case?

Ahhh... It's "proof" you want is it.  Where is that envelope....

I'm assuming that a single process will be single-threaded with respect
to any given lock, so it can only race with other processes/clients.

If a process sends an arbitrary number of non-blocking LOCK requests,
then either none of them will be granted, or one will be granted and the
others will acknowledge that the lock is already in place.  There is no
difference in the NLM response between "You have just been granted this
lock" and "You already had this lock, why you ask again".  So the reply
to the last request will indicate if the lock is held or not.

For UNLOCK requests, the lock - if there was one - will be dropped on
the first request processed so multiple consecutive UNLOCK requests will
all return the same result, including particularly the last one.

For blocking LOCK requests the situation is much the same as non-blocking
locks except that the lock is granted pre-emptively (as soon as
something else unlocks it) and there is a GRANT callback.  Providing the
client continues to make LOCK requests until it is granted (as you would
expect), or makes an UNLOCK request repeatedly until that is acknowledged
(as you would expect if the lock attempt is aborted), one of the above
two cases applies.

Is that woffle enough of a proof?

>
>
>> So if requests can be re-order you could have problems, but tcp protects
>> us again that.
>
> No, it doesn't. The server is free to put RPC replies
> on a TCP socket in any order, and the TCP connection
> can be lost at any time due to network partition.

Re-ordering of replies isn't a problem - providing they don't have the
same 'xid' which is what I'm proposing.  The client can tell which reply
matches which request and will only attend to the reply to the *last*
request.

Re-ordering *requests* can be a problem.  But the client will put them
on the connection in the correct order.

If the client closes a TCP connection, opens a new one, and sends a
request, can the server still process requests that arrived on the first
connection after requests on the second?
I would hope that the "close connection" would wait for FIN+ACK from the
server, after which the server would not read anything more??

Thanks,
NeilBrown

>
> (Note connection loss forces the server to drop the
> reply, and the client is forced to retransmit, no matter
> what the timeout may be).
>
> NLM has to order these requests itself, somehow.
>
>
>> I'll have a look at what it would take to get NLM to re-issue requests.
>
> Easy to do, I would think, but with all the problems
> guaranteeing idempotency that "soft" brings to the
> table.
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

iQIcBAEBCAAGBQJW+yWLAAoJEDnsnt1WYoG5oWoP/AuupYM6aBRhNBWit8IhmAQc
QDiHLrJ8A5JBPRvSteHwaeZ9ds44iiy59+mDU1kpDqx/EsU7hO/R8xYhDcg78z0U
LWoieq8qxHoEvzmA97mk5WlKnu1TmFGHZC0FwO+vW+rjOMZJcag2o+PE+DldM1Jf
XgfxGustfWgGS5IuQ/j1ri7j8CcS9IUnoHuvzrNZ/cc0FjQfrcEXMLW+reeA0oFv
xIpJDfRKANl3nRasC6x7pIJeyfNIkxPYjlX9pxZVWCW6JRMxxFmEdHN37vVCHFBP
KUjG1AZXcBoknCVLRQiiQ5HAk3Ag5DgeGCkQzzvn7lqNO4HLbdmQCDZyQyll55VB
8TOjx5A4IiUZQetZWOx8dYXqD/Rr44Q40QVWEZP7GAD9GnRIU+v8Y1akm0ozNTs8
au/D4D/vHCCpOPVVmdOCY1RHcMY/HpnDi1Oz6j0zlx2htehbKEStp7oM6HmMcVyg
+OsWg7Ar3YlFhY1Gtl1zBBuRNZo7+KJ+afLee+jFycvxC0i22ZN97wuJIncbrzXa
xaghJoTitse60hEXMXpxX4thUiu2YsUjdsW083hYLafN+OcI99CzbrCkpLnT49yb
Gj1qK5a0FEfNR54CfLpO5Zssk/o1hC1DSqap+OzObWfacrN0P31R4M6pUBcVsBAl
UNurBpYJ0t6iIU6RO4qq
=z+m5
-----END PGP SIGNATURE-----
--=-=-=--
