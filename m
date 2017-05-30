Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50371 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750902AbdE3Lvh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 May 2017 07:51:37 -0400
From: NeilBrown <neilb@suse.com>
To: Jason Vas Dias <jason.vas.dias@gmail.com>,
        linux-nfs@vger.kernel.org
Date: Tue, 30 May 2017 21:51:28 +1000
Subject: Re: mount.nfs needs to accept 'addr' option / parse its target string better
In-Reply-To: <CALyZvKwXQew+t69BiQ4UXX+7=bYMPWxXdUbFepzWmrX_9_d=Qw@mail.gmail.com>
References: <CALyZvKwXQew+t69BiQ4UXX+7=bYMPWxXdUbFepzWmrX_9_d=Qw@mail.gmail.com>
Message-ID: <8760giftq7.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Mon, May 29 2017, Jason Vas Dias wrote:

> Good day -
>
> I just built & installed the latest nfs-utils-2.1.1 , and noticed a
> number of issues
> with mount.nfs .
>
>
> 1. It does not seem to be possible to specify a literal IPv6 address in a target
>     (not "URL"! ) <host>:<share> string:


Please read the "nfs" man page.

  man 5 nfs

particularly the second last para of the "DESCRIPTION" which starts

  The server's hostname can be ...

NeilBrown

>
>     $ mount -t nfs4 ::1:/mnt/disk /mnt/disk2
>     mount.nfs4: Failed to resolve server : Name or service not known
>     ( so it does not work for the loopback IPv6 address; try link local
>       IPv6 address:
>      $ strace -f -s8192 -v -e trace=mount mount -t nfs4  \
>         fe80::fa16:54ff:fef7:d66d:/mnt/disk /mnt/disk2
>      mount.nfs4: Failed to resolve server fe80: Name or service not known
>    )
>
>   Yet it DOES work for the literal IPv4 loopback address:
>      $  mount -t nfs4 127.0.0.1:/mnt/disk /mnt/disk2
>      $ echo $?
>      0
>    But not if a port is specified :
>    $ strace -f -s8192 -v -e trace=mount mount -t nfs4 \
>       127.0.0.1:2049:/mnt/disk /mnt/disk2
>      strace: Process 2265 attached
> [pid  2265] mount("127.0.0.1:2049:/mnt/disk", "/mnt/disk2", "nfs4", 0,
> "vers=4.2,addr=127.0.0.1,clientaddr=127.0.0.1"May 29 20:16:13 jvdlux
> kernel: [40029.874234] device: '0:43': device_add
> May 29 20:16:13 jvdlux kernel: [40029.874283] PM: Adding info for No Bus:0:43
> ) = -1 ENOENT (No such file or directory)
> May 29 20:16:13 jvdlux kernel: [40029.922459] device: '0:43': device_unregister
> May 29 20:16:13 jvdlux kernel: [40029.922496] PM: Removing info for No Bus:0:43
> May 29 20:16:13 jvdlux kernel: [40029.922533] device: '0:43':
> device_create_release
> [pid  2265] mount("127.0.0.1:2049:/mnt/disk", "/mnt/disk2", "nfs4", 0,
> "addr=127.0.0.1,vers=3,proto=tcp,mountvers=3,mountproto=udp,mountport=49831"May
> 29 20:16:13 jvdlux rpc.mountd[1001]: Bad path in mount request from
> 127.0.0.1: "2049:/mnt/disk"
> ) = -1 EACCES (Permission denied)
> mount.nfs4: access denied by server while mounting 127.0.0.1:2049:/mnt/disk
>
> (the above output includes the syslog messages from a 'tail -f
> /var/log/messages'
>  running in the background ).  It is strange that the mount is tried
> twice here ,
> once with version 4, and once with version 3, even though I had requested
> a filesystem type of 'nfs4' , not 'nfs3' .
>
> So it seems that mount.nfs is treating the FIRST colon as unconditionally
> starting the 'share name' portion of the URL . I think it would make more
> sense to make it find the LAST colon (use rindex(3) instead of index(3)) -
> then it should check if what follows is a number - then it has found the
> port , or the last octet of an IPv6 address .
>
> And why doesn't mount.nfs support NFS URLs ? :
>   $ mount.nfs4 nfs://127.0.0.1/mnt/disk /mnt/disk2
>   mount.nfs4: NFS URLs are not supported
>
> Then at least it would be simpler to separate out the host name,
> regardless of whether a literal IPv6 address is used or not.
>
> And it appears to be really impossible to specify a literal IPv6 address
> in the colon-separated octet ASCII format in the 'target' string.
>
> Why doesn't mount.nfs support parsing the 'addr' option ?  :
>
>   $ mount -t nfs4 -o 'addr=fe80::fa16:54ff:fef7:d66d' /mnt/disk /mnt/disk2
>   mount.nfs4: remote share not in 'host:dir' format
>
> If mount.nfs supports literal IPv4 addresses, it should support
> literal IPv6 addresses.
>
> I think mount.nfs should support NFS URLs, including ones with a
> ':<port>' suffix
> ( or a '#<port>' suffix for IPv6 addresses) ,  and that it should also
> support specifying the 'addr=' option directly, and then not require
> the address to be
> prefixed to the share name with a separating colon .
>
> Just my two cents worth / some observations ...
>
> Regards,
> Jason
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlktXMIACgkQOeye3VZi
gbk9lg//d21MihEaMv/1TUW8EARPkYyAoJ1+LkSg9epgTtxzWX/pJJ/kComM5Pr7
rzZmZUIRRnhd26f+FrDd/Ok0OrK5DM69AffjbU5wbxe+zQ7gttfAlR9E1YHWD/iK
xsGQ9Xkak1LDbVT0JNf+1FGhuOI+Ury3lSEG2b+ifSYJ79D9cs3VrDiDyW0ekpwG
kQGKlsrW9XzgQLTZG4wHsRzX7qV+QP6BbFfvj1+QPurrMVGoD8QdFcUlqjl3Kfbc
axzA4YkuMTVLoUKR64sCJ4ti5+V5vEHrHEy/qdhOmJJmTJo60U2+x80MvwqBwiaF
uURuiOzlheafrrwAY3AwLWdCZiHN9s8pHa6pgNHTmiKyvhBsHLhLvW9qtNdi87ag
I0NUan8ZfHBnhxptPjpAj4GRbXNkIKNfN0P3FXTZLluyXJMKV4SmqZLuM5O0RZ/p
zaRf6iJtyB0g/OfM+pogSZyS1N8rTZfcCeszP3x2kupARrc8kuIza/qClRhthgqa
DNNxt6M9GFcTUX8RHLlka5ERoCsq7M0dVNOzI0Tr+tjd9ENYhXguzOjUWp2E9MZk
bu9LkXGcUABkafYIxtR88PLeHacFBzgLoWdR3Bbbt2mdgKoeaze6nHLD+4yfRWdx
+87unGW2y+mXe3UNe9WhQRqXu8vsQcTUefVw0PhiOmwnMtlPZOk=
=YhU6
-----END PGP SIGNATURE-----
--=-=-=--
