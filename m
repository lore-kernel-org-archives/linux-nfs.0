Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39794 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754832AbdGJXv3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Jul 2017 19:51:29 -0400
From: NeilBrown <neilb@suse.com>
To: Phil Kauffman <kauffman@cs.uchicago.edu>, linux-nfs@vger.kernel.org
Date: Tue, 11 Jul 2017 09:51:20 +1000
Subject: Re: /etc/mtab read ~900 times by rpc.mountd
In-Reply-To: <4ec2a8fc-3ca5-d26b-7742-be4e2f749c21@cs.uchicago.edu>
References: <f9dcc371-cd94-6b39-dd6a-b412bdf03df4@cs.uchicago.edu> <8737a9x9ky.fsf@notabene.neil.brown.name> <595F1A3A.7070405@cs.uchicago.edu> <87efto69rs.fsf@notabene.neil.brown.name> <4ec2a8fc-3ca5-d26b-7742-be4e2f749c21@cs.uchicago.edu>
Message-ID: <87y3rv4zrb.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Mon, Jul 10 2017, Phil Kauffman wrote:

> On 07/10/2017 02:17 AM, NeilBrown wrote:
>> Another is to move the code around.  In your case there are really just
>> 3 exports to each of 300+ clients (I assume "client.cs.uchicago.edu" in
>> the combined exports file is really different in different files).
>> So any one client only needs to consider 3 exports, not 300.
> This assumption is correct. We have ~300 clients and growing (slowly).
>
>> Could you test with this patch applied and see what
>> difference it makes?
> After being confused by conflicting test results and determining that the service nfs-server takes a bit longer to start than 'systemctl' will let you believe, I believe Niel's patch works.
>
>
> The new cache.c file I am using to test with: http://people.cs.uchicago.edu/~kauffman/nfs-kernel-server/test_with_patch/cache.c
>   It also contains the official patch from this thread: http://marc.info/?l=linux-nfs&m=138900709311582&w=2
>
> Building the new deb packages: http://people.cs.uchicago.edu/~kauffman/nfs-kernel-server/test_with_patch/build_deb.txt
>
> Install nfs-kernel-server and nfs-common debs on server and nfs-common on client.
>
>
> I reboot everything: client and server
>
> Run ssh for loop (no stracing) with the result that every user was able to ssh in under a second (I consider this to be a success).

This does look encouraging ... but I'm not sure we are comparing apples
with apples.

In the original strace we see.

 read(4, ....)
 check on etab
 statfs(some path)
 write(4,....

which is exactly like the new strace.
But then the old strace also has

 read(5, ...)
 check on etab
 read /etc/mtab hundreds of times.
 write(5, ...)

which is completely missing in the new strace.  So the new code which
doesn't read /etc/mtab as much, isn't being run at all.

file desc 4 is /proc/1926/net/rpc/nfsd.export/channel
file desc 5 is /proc/1926/net/rpc/nfsd.fh/channel

If the nfs server kernel has nothing cached, then when a request arrives
you should first see a transaction of fd 3
(/proc/1926/net/rpc/auth.unix.ip/channel) to map the IP address to a
"domain".
Then a transaction on fd 5 (nfsd.fh) to map the domain + a filehandle
fragment to an export point.
Then a transaction on fd 4 (nfsd.export) to map the domain + export
point to some export options.

If the request is a "LOOKUP", you might see another "fd 5" lookup after
the "fd 4" to find out if a sub-mountpoint is exported.  That is what
the old strace showed.

If you don't see all of those, then something is cached.

Could you repeat your experiments after first running "exportfs -f" on
the nfs server?  That should cause worst-case load on mountd.

Until we see the "read(5).... write(5)" sequence completing quickly, I
cannot be sure that we have fixed anything.  Actually.. for future
traces, please add "-tt" so I can see where the delays are, and how much
they are.

(and thanks for providing all the tracing details - I love getting
unambiguous data!!)

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAllkEvkACgkQOeye3VZi
gblIJA/7BNL6tyoOyiMxXUbJ0LFfIU0CbY7GzHrZzNvaxtPkrFuh7YytlWDr7WxH
+TQ48fVLlBndCdiqtTt8Red3wQeIZMXxqyIPBcXKP/8+9+Iq6syWyxPQymqXpkbP
ewLsbS2V+9nRFlk4Yo8czj+zFeYABwqmGOLQCM2iJfNRa7+q3KxS6qgcZQPb86P+
j51CxCJTRfvFLaYDa7x3kG6V7A97hkB3PXyCIkRRtarX1NPVS9KMt3Mob2+0sdmo
3esDpSN6TfUyutz4y3Jm6jdbOvDh2RLvkkEXNMFuOXvEPkG4BFhk/oQKd/uptaHZ
+xQaXLSA4Wmb2xYP6jlg08OPo/7/BA4aDJvenzax3vJBr44eS/oVu8rZukcgS1My
D/u4BVTbmzP3A3s5qW/AmYZ/8DCKReuva9Kl5JWH7nKYhPArXBfzn2nPRpYXVmsg
h6bYnYiV2lYcZ9/1xYi3lCH9r/mscEBLsnjVidS5YWFPBCVzuAB6ZIR/KNH7tGsd
OlfGHqMJSEWUCSG+lccP2PKjl+L0mcsmQ9P8Usn/zGxmhAdzyQ0plyRIV8Oh6PP1
4IQy43vJF4IdzJwChMqT0D4mAR6MneBBUSe3pnxKG+owsucG3u7C8y3KSMDqn6lf
auM73HHkjo8Jtox4oFSqi5zfITQQcYTxQFBLM8QUXzaZggWRVfY=
=8iJB
-----END PGP SIGNATURE-----
--=-=-=--
