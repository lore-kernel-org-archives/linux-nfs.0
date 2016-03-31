Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59574 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751183AbcCaFLc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Mar 2016 01:11:32 -0400
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@poochierds.net>,
        Christian Robottom Reis <kiko@acm.org>
Date: Thu, 31 Mar 2016 16:11:23 +1100
Cc: NFS List <linux-nfs@vger.kernel.org>
Subject: Re: Finding and breaking client locks
In-Reply-To: <20160321172735.7936f1f0@tlielax.poochiereds.net>
References: <20160321143914.GA6397@anthem.async.com.br> <20160321131906.05ec478b@tlielax.poochiereds.net> <20160321175500.GA5118@async.com.br> <20160321205637.GB5118@async.com.br> <20160321172735.7936f1f0@tlielax.poochiereds.net>
Message-ID: <87h9fns03o.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 22 2016, Jeff Layton wrote:

> On Mon, 21 Mar 2016 17:56:38 -0300
> Christian Robottom Reis <kiko-HInyCGIudOg@public.gmane.org> wrote:
>
>> On Mon, Mar 21, 2016 at 02:55:00PM -0300, Christian Robottom Reis wrote:
>> > > Alternately, there is the /proc/fs/nfsd/unlock_ip interface. Suppose=
dly
>> > > you can echo an address into there and it'll forcibly drop all of the
>> > > locks that that that client holds. I've not used that so YMMV there.=
=20=20
>> >=20
>> > Oh! That's a very interesting, and I now see it documented here:
>> >=20
>> >     http://people.redhat.com/rpeterso/Patches/NFS/NLM/004.txt=20=20
>>=20
>> On second look, I don't think that interface is meant to take a client
>> IP, but rather a server IP:
>>=20
>>   "They are intended to allow admin or user mode script to release NLM
>>    locks based on either a path name or a server in-bound ip address[...=
]"
>>=20
>> That's why echoing the client IP makes no difference.
>>=20
>> I'm surprised -- so far I've found no facility for lock management
>> server-side other than restarting the server.
>
> Ahh that's exactly right -- my bad. I had forgotten that the idea there
> was to use that for clustering.
>
> And you're also correct that there is currently no facility for
> administratively revoking locks. That's something that would be a nice
> to have, if someone wanted to propose a sane interface and mechanism
> for it.

I was all set to give you an answer until I saw that word
"sane"... nearly scared me off, but I chose to persist.

You know this, but let me remind you and inform Christian.

When an NFS client ("bob") asks the NFS server ("jane") to lock a
file (the first time), the kernel says to statd "Hey, Bob wants a lock.
Can you keep and eye on him and let me know when he reboots - when he
does I want to discard his locks".

So statd on Jane talks to statd on Bob saying "Hey Bob, tell me if you
ever reboot - OK"?  Bob takes note of this request by writing "Jane" in
/var/lib/nfs/sm.

When Bob reboots, sm-notify sees "Jane" in /var/lib/nfs/sm and sends a
message to statd on Jane "Hey Jane, Bob just rebooted.  You're welcome".

statd on Jane then tells the kernel "Bob rebooted" and the kernel drops
all those locks.

And there, in that last step, we see the key.  It is already possible to
tell the kernel "drop all the locks held by Bob", you just have to say
"Hey, I'm statd - Bob rebooted".  Or maybe we could stay to statd "Hi
Jane, this is Bob, I just rebooted" - even though we aren't really Bob.

(Or we could just reboot Bob and let it do the talking).

I'd have to hunt through the statd code to figure out what is possible
and what is best.  It can't be too hard though.

Christian:  If the problem client actually comes back up (instead of
staying down) do the locks get drops as they should?

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW/LF8AAoJEDnsnt1WYoG5Y/sP/07xNPYFxf2XdrJO2Ek7L5lW
2naNf22rrMt67lKR02r59K5FqkvQqHMuecj+TmHCH+ihPJH597lYLvCG2JVBtLtd
bAJAk8BasB0Su6lpikc25tlGxdBB4bX644IEhT+JupstX57Hchnz4o0jmuudc4Q0
CHv7y05ZCjVRyuEd9LOz1Cw5fXUQGzMIkiGx7vdZLr/PVrtTAAV3BeFVtwOA88AZ
/Dsf5ynP2Qf25yDLe02v+O6wic+a7zlAIHlRZKv5M0XffBe7wl1SlFEtPC3oHd4W
LAzPbwreKsNQ0IBCdEJ2DVLeAp0Y4BKHYfcGC1ofDxBHTXo501N+HxU4ysNFpoP2
ltvTGWaw8j4ew9r8jfNzYBdj8tLfkNUJEObk8QfBswOYApIiMLyK1B7Hnl5e7RmZ
vUbbPPHJTQMXOpPEISOPAvZsFllIDPRyJCanmo0Z74zL9Lfqpydd6BGAzQ9QcY6H
8ooRDyG1fk4eWOW6ZQ+saDCG2jK8MzhG0PN1+AOfLkpt7zXfAHuDH/GS0uMj8EEO
9WzDoncOz8C+ADXpJcu3bvz3SnvYwoSQqLlHWu+ryZ/QeviVdb/Smf/4W+IQRXPl
LfUk6/cqAQa4KmfGcMpXMWvukO2/OEuOyM7Decz5GgE8I3I6EgSHVf+h7sXikal1
VxQ9iJ72EgMm8CQqtPNR
=8r6h
-----END PGP SIGNATURE-----
--=-=-=--
