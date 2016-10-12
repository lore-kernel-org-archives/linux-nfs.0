Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39267 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753768AbcJLGnu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Oct 2016 02:43:50 -0400
From: NeilBrown <neilb@suse.com>
To: james harvey <jamespharvey20@gmail.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Wed, 12 Oct 2016 17:25:23 +1100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: nfs-server (v4.x only) takes extra 6 minutes to start without rpcbind
In-Reply-To: <CA+X5Wn7CFa9uCZPQZbB0aNs+gXf-CHaaEg5pNpTxWv=iVS+QkQ@mail.gmail.com>
References: <CA+X5Wn7oiaPyO+dN4ARb+Y4JuOqR90283par7-2NQvOtO_HOiQ@mail.gmail.com> <CA+X5Wn48mD-2hVwFsBSWhExmaMxL1HUAcB8MhXtnoVuFSWBBgQ@mail.gmail.com> <74a1f425-5ed2-2558-3233-558458fa69f2@RedHat.com> <CA+X5Wn7CFa9uCZPQZbB0aNs+gXf-CHaaEg5pNpTxWv=iVS+QkQ@mail.gmail.com>
Message-ID: <87lgxu13u4.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Sat, Sep 03 2016, james harvey wrote:

>
> FWIW, after nfs-server eventually starts, systemctl still shows
> rpcbind.socket (and rpcbind.service) as masked, inactive, and dead.

I think this is a kernel bug.  You can fix it by reverting

Commit: 4b0ab51db32e ("SUNRPC: xs_sock_mark_closed() does not need to trigger socket autoclose")

See also http://www.spinics.net/lists/linux-nfs/msg59264.html and
follow-ups.


>>>
>>> # rpc.mountd --foreground -N 2 -N 3
>>>
>>> {{{ another tty }}}
>>> # strace rpc.nfsd --debug -N 2 -N 3 8
>>>
>>> Gives the attached strace output, which shows the same two really long
>>> delays when reading or writing /proc/fs/nfsd/portlist.
>>>
>> I don't see the attachment...
>>
>> steved.
>
> Strange, wonder if the list removed it - I do see it on my sent message.
>
> Anyways, I just uploaded it here: http://pastebin.ca/3709748
>
> The delays happen at lines 145-149, which print as one line, I just
> broke it apart showing the characters that show on the line before and
> after the delay.

The delay at 'read' is waiting for nfsd_mutex.  Probably something else
was trying to start up nfsd and hit the 3 minute wait while writing the
threads.  Maybe you interrupted that or backgrounded it or something.

>
> Same at lines 166-170.

This one is the real problem.  Starting nfsd tries to register with
rpcbind (even for v4-only) and (due to the bug) it takes 3 minutes to
timeout.

NeilBrown

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJX/ddTAAoJEDnsnt1WYoG5VkUQAL0Dfw2SYV9bKckH0mMwWGXF
9BMywpcxdv6kBJEHc0ef3NNLbmY2twq7BkzP5ly0E4427p8O0PKH9KPSyOIb1ewm
hBD30c7XeRgvmSi7Jzi5SfoZa5ebWMkDgX3TTPkexYZgdNCMdJdDMVoJvE9VSAvc
DMqB/H7HhhbeS+Q9O5Mm/Eub2hlbHpFq58yPi6R5NMgkAkooH2odFcwTZVlI3fnh
lx+8FkrtaSJFSCU7OqWkUkSYeGzX1hgNDIGE6r+F28QTdfgST2U15x7tlYA8BcXa
GjATgOva5U+Fxk19UTC1Elng88HKDVnoNcVDT6HxEzK7lriPjUjlS5L7q2sajVKA
r63k60XVELNtUQEEQMQ0uJJdoJ2vlIJTUCb/hgo0+9WzaRQwXOXgYAL8wCrbvbwo
WXhxEceajwtWU/wGYopnM+b8BfQAyXyl0yfi/wA0FnCzBvSY4zvPh/KEJQdHXYV9
7LENJ4kQdtb/8ZBqxnEeKGvRqsVbz4zDKEeB8WGKbxiDJpMT6rDqGYMy/Omc6UBX
wwYN0Miuf45q+M5xuuVliyyEOeYMHHRjObImSnF9sfhUqbqT8ob7na5W6hiStApb
UTHVllVIPUwxeqzPS4vH7qE6rS3CsL1KeHxCyilPY2zQ85E1n4P0oD/tquEtu+yO
7y4Q7A0/+4JW6IWR+mnc
=Gwb1
-----END PGP SIGNATURE-----
--=-=-=--
