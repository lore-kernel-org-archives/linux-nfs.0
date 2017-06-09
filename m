Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47644 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751479AbdFIDRX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Jun 2017 23:17:23 -0400
From: NeilBrown <neilb@suse.com>
To: devzero@web.de, linux-nfs@vger.kernel.org
Date: Fri, 09 Jun 2017 13:17:12 +1000
Cc: pf@artcom-gmbh.de, rnews@altium.nl, jlayton@redhat.com,
        bfields@fieldses.org
Subject: Re: How to avoid rebooting Linux NFS-client when NFS-server is not available?
In-Reply-To: <trinity-f2c19596-3afe-4a3f-ad07-78e6cfda9cb5-1496911790012@3capp-webde-bap34>
References: <trinity-f2c19596-3afe-4a3f-ad07-78e6cfda9cb5-1496911790012@3capp-webde-bap34>
Message-ID: <87mv9halzb.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 08 2017, devzero@web.de wrote:

>>Indeed: This workaround seems to work!
>
> Unfortunately not in every situation.
>
> We have differnt XEN servers (Citrix XS7) at remote location which have h=
ung/stale NFS mount problems at regular intervals (.ISO storage repo is mou=
nted via WAN) and i always need to reboot, which really really(!) sucks.
>
> At least a fake NFS server as described below releases the stuck mount, i=
.e. df -h and other processes touching do not hang anymore, so at least thi=
s workaround helps to some degree...=20
>
> BUT:
>
> # umount /run/sr-mount/2b5c5c60-3744-c860-28a7-eb106d3a339e
> umount.nfs: /run/sr-mount/2b5c5c60-3744-c860-28a7-eb106d3a339e: Stale fil=
e handle
>
> # mount|grep xen-sr-iso
> 172.16.28.10:/mnt/S2V2/xen-sr-iso on /run/sr-mount/2b5c5c60-3744-c860-28a=
7-eb106d3a339e type nfs (rw,relatime,vers=3D3,rsize=3D131072,wsize=3D131072=
,namlen=3D255,acdirmin=3D0,acdirmax=3D0,soft,proto=3Dtcp,timeo=3D600,retran=
s=3D2147483647,sec=3Dsys,mountaddr=3D172.16.28.10,mountvers=3D3,mountport=
=3D680,mountproto=3Dtcp,local_lock=3Dnone,addr=3D172.16.28.10)
>
> # umount -l -f /run/sr-mount/2b5c5c60-3744-c860-28a7-eb106d3a339e
> umount.nfs: /run/sr-mount/2b5c5c60-3744-c860-28a7-eb106d3a339e: Stale fil=
e handle

This really shouldn't happen.
Since Linux 3.12 (commit 8033426e6bdb) it has been possible to
umount an NFS filesystem, no matter what state it is in.

Since util-linux 2.23 (commit 6d5d2b5fd342308), umount -l or umount -f
should have avoided statting the filesystem.

If you have a new util-linux (mount -V) and new kernel (uname -a),
then I'd be interested to see
  strace -o /tmp/strace -f umount -f /run/......



>
> # mount|grep xen-sr-iso
> 172.16.28.10:/mnt/S2V2/xen-sr-iso on /run/sr-mount/2b5c5c60-3744-c860-28a=
7-eb106d3a339e type nfs (rw,relatime,vers=3D3,rsize=3D131072,wsize=3D131072=
,namlen=3D255,acdirmin=3D0,acdirmax=3D0,soft,proto=3Dtcp,timeo=3D600,retran=
s=3D2147483647,sec=3Dsys,mountaddr=3D172.16.28.10,mountvers=3D3,mountport=
=3D680,mountproto=3Dtcp,local_lock=3Dnone,addr=3D172.16.28.10)
>
> # ls -la
> ls: cannot access 2b5c5c60-3744-c860-28a7-eb106d3a339e: Stale file handle
> total 0
> drwx------  3 root root   60 Feb 18 17:43 .
> drwxr-xr-x 36 root root 1660 Jun  7 18:45 ..
> d?????????  ? ?    ?       ?            ? 2b5c5c60-3744-c860-28a7-eb106d3=
a339e
>
> Any hint on how to circumvent rebooting to remount the nfs share or proac=
tively avoid stale NFS mounts would be very appreciated. (disabling NFS by =
module unload/load is no option, as our XEN servers do have other NFS mount=
s for shared storage)
>
> regards
> Roland
>
> ps:
> I`m not sure if linux-nfs ML will allow anonymous posts (probably not), s=
o maybe someone subscribed be so kind to reply with list cc=C2=B4ed. I`d li=
ke to avoid subscribing to a list because of a single post...
>

We aren't that closed-minded ;-)  Your message went to the list.

NeilBrown

>
>
>
>>List:       linux-nfs
>>Subject:    Re: How to avoid rebooting Linux NFS-client when NFS-server i=
s not available?
>>From:       Peter Funk <pf () artcom-gmbh ! de>
>>Date:       2013-07-26 12:08:49
>>Message-ID: 20130726120849.GA12584 () pfmaster
>>[Download message RAW]
>
>>Dick Streefland wrote 24.07.2013 13:03:
>>> Peter Funk <pf@artcom-gmbh.de> wrote:
>>> | We've researched this question for quite a while now and nobody here
>>> | found a solution to the following problem:
>>> |=20
>>> |  1: A Linux computer is NFS client of some other Linux NFS server
>>> |     and has some active mounts and some processes working with files=
=20
>>> |     on that NFS server.=20=20
>>> |=20
>>> |  2: Now the NFS server becomes unavailable and a system administrator=
=20
>>> |     wants to clean up the situation on the NFS client computer withou=
t=20
>>> |     having to reboot this client computer.
>>> |=20
>>> | Is this possible?  And if how exactly?
>>>=20
>>> What you could try is temporarily add the IP number of the dead NFS
>>> server to another NFS server. The other NFS server should reject any
>>> request for the dead mount, and the client can continue with an error.
>>
>>Indeed: This workaround seems to work!
>>
>>Assume example: The NFS-server has IP 192.168.123.45 and the client
>>has also the nfs-kernel-server package installed and it is running.
>>Then this sequence on the client did the trick::
>>
>>    ifconfig eth0:fakesrv 192.168.123.45 up
>>    umount -f -l ....
>>    umount -f -l ....
>>    ....
>>    ifconfig eth0:fakesrv down
>>
>>Best Regards and many thanks for your suggestion,
>>Peter Funk
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlk6EzkACgkQOeye3VZi
gbn3bQ/+NS6QfBueiqAq/uW4mzABKSeh+jUfDutenR7TX+bYKBf9r1Ze0oqbIlYY
CJgqPN3X/odpBbwOmD3gU5Qx+XIgAmgYBZPfz3sjR5nAml+tRCEVgsAvKC27BOz2
VJipKt9ZuOnw065Or/RDCcuxEXZgZAdaO3l4Co5t33sQadlAOiZ8R9OMdtihAbdh
zmZjers6krU5bE5bm25upuJuDPWNQPRXCmE7aVsEVT/vyeYpQF5bPkJ6Z4lrIniE
J//os0TPUHinxoZpdxHSraLLPMEZzaUBLKixwInTzHsa3g2YqcFPbfuPZi5zLdgU
41+2tfuzpYSp8k4RG4fQRFQ77ul5X7xki3CE23ZrTnfe/BKIeSb0XUX9dwz2V6Zj
P0nqcJJnCYt655OYEXlJljUKwmycI1JsOm0i0jlzBZDCgDOrio6DVDs1RfIlbBbs
k4U7d36MxyaoftFL/6A7z9G1q2KeennccR7b5LzvEmcSql0QeXpBCRoKd80rND+T
Duny6zHOLUPSBaEz7+uq9QK1qwKfpb/uoedBAbab+pOgpy2LexJea/uLZfa6k1cx
eZTD2bcUuk694byvVtCjzDcCuYSyGWuXD0OpIevZU1ce5A9AdnwbDcbzrQXKZ0iZ
7jgK+rpzn44sUBdY8FmwN6n5TE96ZbF7qPSArU/4NAqCm4Ey64s=
=SiHz
-----END PGP SIGNATURE-----
--=-=-=--
