Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52817 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751574AbdFGDIQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Jun 2017 23:08:16 -0400
From: NeilBrown <neilb@suse.com>
To: Lutz Vieweg <lvml@5t9.de>, linux-nfs@vger.kernel.org
Date: Wed, 07 Jun 2017 13:08:08 +1000
Subject: Re: PROBLEM: nfs I/O errors with sqlite applications
In-Reply-To: <5936DC7B.8040804@5t9.de>
References: <20151012164846.GA5017@draconx.ca> <20151012192538.GG28755@fieldses.org> <20151012194647.GJ28755@fieldses.org> <20151013030136.GA7081@draconx.ca> <20151013065225.44c5581d@synchrony.poochiereds.net> <CADyTPEyUKNdYuj0LwoX-r6jJJ0tEufwyA_mEKE=OVniX9rXPog@mail.gmail.com> <CADyTPEx=h95ODeG3BixMHc=kxLmkFt+aVyS+V_bK-b=CqK4_6Q@mail.gmail.com> <1469814735.19411.1.camel@poochiereds.net> <5936DC7B.8040804@5t9.de>
Message-ID: <87vao8bilj.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Tue, Jun 06 2017, Lutz Vieweg wrote:

> On 07/29/2016 07:52 PM, Jeff Layton wrote:
>>>>>>>>>    fcntl(7, F_SETLK, {type=F_RDLCK, whence=SEEK_SET,
>>>>>>>>> start=1073741824, len=1}) = -1 EIO (Input/output error)
>>>
>>> Unfortunately I did not manage to perform a network capture last time
>>> due to power loss.  I did not hit this issue again until yesterday (~9
>>> months later), this time after 45 days of uptime.
>>>
>>> Kernel versions now are: 4.5.1 on the server, and 4.4.3 on the client.
>
> I wanted to add that I, too, have one NFS client and server
> (running linux-4.11.0 on both the server and the client)
> currently in the same kind of state:
>
> I can reproduce in 100% of the cases that the following commands:
>
>> rm -f x.sqlite
>> sqlite3 x.sqlite "PRAGMA case_sensitive_like=1;PRAGMA synchronous=OFF;PRAGMA recursive_triggers=ON;PRAGMA foreign_keys=OFF;PRAGMA locking_mode = NORMAL;PRAGMA journal_mode =  TRUNCATE;"
>
> result in:
>
>>  "Error: disk I/O error"
>
> on the client - while working fine on the NFS server - with the same kind
> of strace output:
>
>>  fcntl(3, F_SETLK, {type=F_RDLCK, whence=SEEK_SET, start=1073741824, len=1}) = -1 EIO (Input/output error)
>>  write(2, "Error: disk I/O error\n", 22Error: disk I/O error
>
> But unlike the original reporter, we use the NFS v3 protocol:
>> server:/data on /data type nfs (rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,soft,proto=tcp,timeo=600,retrans=2,sec=sys,mountvers=3,mountport=20048,mountproto=udp,local_lock=none)
>
> If you want me to try or trace something on the client,
> I'm willing to help.

Using "soft" is not a good idea.  It could be the cause, but it isn't very
likely if NFS is otherwise working OK.

It might help to run
  rpcdebug -m nfs -s all; rpcdebug -m nlm -s all ;rpcdebug -m rpc -s all
  #repeat your test
  rpcdebug -m nfs -c all; rpcdebug -m nlm -c all ;rpcdebug -m rpc -c all

then collect the kernel logs (possibly just run "dmesg") and post all
the messages which happened at that time.

It might also help to find the port number that lockd is running on
   rpcinfo -p $SERVER | grep 'tcp.*nlockmgr'

(use the 4th column) and

  tcpdump -s 0 -w /tmp/trace.pcap port 2049 or port $LOCKD_PID &
  # run test
  killall tcpdump

gzip /tmp/trace.pcap and put it somewhere it can be fetched from - or
maybe post as an attachment if it isn't too big.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlk3bhkACgkQOeye3VZi
gbkaaQ/8CH56QijxmfZiGVN2eve4fDe55/p49S96XTO7YNWYlF/rzOBcR4W8VQyh
TWcwWOl90OIBhVOwopeKmCcYCAe6aMRO07oPYFUN4cwVE4MNVj9Hx7aKkINHxF0Y
KkyPKUAFqUr0Fb0HrMWSp2nQC0JtSjxHYdp37TXCUCtq1rw8UiDh5K+4FYedwq0b
8LMUy4cbM90GUgC087IqiWHfxVbQdwPre+BN5wDsCoke8iC5JY5zaLQcAzLlwFJs
tmDpfglNR3C1JtqE8qwzN1fE/l5kE4tYn4FGl3cjxyfJwD6JHK+xrcqoBF+NOxEp
VIGa1WDaUYv/NRa3EddKfqx6c6IzQWQjn6vP+TmbkwTAaoW1qunZszv8kRU12n1L
5UW1qenuISF7/0ZDbHyTaVVhl6L3x6pyDnk1ZkhoYAse+gRxvARsttv58KG8Sh7q
JnzVICbG9uhE/2555cKVwu+1OO0lpBoi4jscIEQnDoa3uwo3rnyJ86Q6vAMMux+N
rNeQuPsYxED4cdg08EpkUe/DBmgopx/PCgbcKrAn+f8r4lxtLHa9mLlE9TWln8hJ
sN0ADoa40jx+kSaR1Pez2vdinDxfTvdIGzJfo0GVM0r6u0JRMzaOf8PMa7joPkW8
1+26RUsND43YRtqLyZ1T8FOtvnyTDvrHmi+P9pkGvO+f6wI03Fg=
=g1hp
-----END PGP SIGNATURE-----
--=-=-=--
