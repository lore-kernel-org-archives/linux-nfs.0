From: Jeff Garzik <jeff@garzik.org>
Subject: Re: A new NFSv4 server...
Date: Fri, 04 Jan 2008 11:41:55 -0500
Message-ID: <477E61D3.4030408@garzik.org>
References: <477CD231.30603@garzik.org> <20080103163200.GB30029@fieldses.org> <477DC501.3060104@garzik.org> <477DD11B.40909@melbourne.sgi.com> <477DDA86.6020100@garzik.org> <Pine.LNX.4.64.0801040954070.5004@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org
To: =?UTF-8?B?UGV0ZXIgw4VzdHJhbmQ=?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52150 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752129AbYADQl6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2008 11:41:58 -0500
In-Reply-To: <Pine.LNX.4.64.0801040954070.5004-K9BqGu7AvB3wj5YHdwD3Ga2PxDmRETKR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Peter =C3=85strand wrote:
> Many years ago, before NFSv4 was finished, I felt the same. I was wai=
ting=20
> for v4 and thought that everything would be so much better. I wanted =
to=20
> help and started the "pynfs" project. Today, I have a different opini=
on. I=20

<grin>


> think v3 is a fairly good protocol, if you use it correctly. For exam=
ple,=20
> many people don't realize that you don't need the portmapper, that yo=
u can=20
> use a single well-known TCP port, that you can use RPCSEC_GSS and so=20
> forth, even with v3.=20

Absolutely...  But still, I think integrated mount protocol (aka pseudo=
=20
filesystem namespace) and integrated locking were big steps forward.=20
You really shouldn't need more than one protocol.



Speaking of RPCSEC_GSS: I would love to see a much more straightforward=
=20
authentication process, something /not/ buried inside special behaviors=
=20
triggered by opcodes found in an opaque cred struct :/  RPCSEC_GSS=20
context creation, the special casing around the 'null' procedure, and=20
the overloading of the RPC data portion of things is a huge pain to=20
implement.


Authentication and security should be simple, tough to screw up.  I=20
would tend to prefer an ASCII-based authentication/security negotiation=
=20
at the start of a [SCTP|TCP] stream.

Use TLS to give most people what they want:  AUTH_SYS with encryption.=20
GSSAPI is fine as a "required option" but you shouldn't need GSSAPI to=20
do simple wire encryption between IP-authenticated hosts.


> I think v4 has a few valuable improvements, but it comes with a very =
high=20
> price. v3 has a minimalistic beauty which v4 lacks. For example, take=
 a=20
> look at the OPEN operation with 7 arguments, of which many are comple=
x=20
> data structures:
>=20
>     (cfh), seqid, share_access, share_deny, owner, openhow, claim ->
>     (cfh), stateid, cinfo, rflags, open_confirm, attrset delegation
>=20
> Not pretty... =20

heh, tell me about it.  First I started out using rpcgen, then rewrote=20
everything to do raw XDR decoding.  OPEN is huge.

IMO, OPEN should be split into multiple operations, probably one for=20
each "OPEN arm".  It's not like new opcode numbers are expensive.

Or, hope of hopes, simplify OPEN in some other manner, like delegating=20
tasks to other operations.


>> Oh, certainly.  I was mainly thinking a replacement of the wire prot=
ocol would
>> be an easier step for people to swallow than a new protocol.
>=20
> I've been thinking of trying to put together something like NFS v3.5.=
 Some=20
> parts of v4 are nice, but the complexity is too high.=20

Agreed that's it's quite complex.

One of my personal desires is for a high level of cache coherence=20
throughout the system for all clients (though perhaps an admin could=20
optionally relax this requirement).  I'm a fan of Google's "Chubby", a=20
distributed reliable filesystem that stalls client writes until cache=20
invalidations for the associated byte range are processed for all=20
interested clients.

And anything approaching cache coherence requires some complexity :/

Another thing I like about NFSv4 is that batching sequences into chunks=
=20
of fine-grained operations is generally a useful practice.  So while th=
e=20
end result (COMPOUND) is a bit of a pain, bundling a sequence of=20
operations into a single unit is useful.

	Jeff



