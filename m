Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.163]:13884 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdFHShC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jun 2017 14:37:02 -0400
Message-ID: <59399945.2020507@5t9.de>
Date: Thu, 08 Jun 2017 20:36:53 +0200
From: Lutz Vieweg <lvml@5t9.de>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.com>, linux-nfs@vger.kernel.org
Subject: Re: PROBLEM: nfs I/O errors with sqlite applications
References: <20151012164846.GA5017@draconx.ca> <20151012192538.GG28755@fieldses.org> <20151012194647.GJ28755@fieldses.org> <20151013030136.GA7081@draconx.ca> <20151013065225.44c5581d@synchrony.poochiereds.net> <CADyTPEyUKNdYuj0LwoX-r6jJJ0tEufwyA_mEKE=OVniX9rXPog@mail.gmail.com> <CADyTPEx=h95ODeG3BixMHc=kxLmkFt+aVyS+V_bK-b=CqK4_6Q@mail.gmail.com> <1469814735.19411.1.camel@poochiereds.net> <5936DC7B.8040804@5t9.de> <87vao8bilj.fsf@notabene.neil.brown.name>
In-Reply-To: <87vao8bilj.fsf@notabene.neil.brown.name>
Content-Type: multipart/mixed;
 boundary="------------060000010303020609050307"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060000010303020609050307
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: quoted-printable

On 06/07/2017 05:08 AM, NeilBrown wrote:
>>>   fcntl(3, F_SETLK, {type=3DF_RDLCK, whence=3DSEEK_SET, start=3D10737=
41824, len=3D1}) =3D -1 EIO (Input/output error)
>>>   write(2, "Error: disk I/O error\n", 22Error: disk I/O error
>>
>> But unlike the original reporter, we use the NFS v3 protocol:
>>> myserver:/data on /data type nfs (rw,relatime,vers=3D3,rsize=3D104857=
6,wsize=3D1048576,namlen=3D255,soft,proto=3Dtcp,timeo=3D600,retrans=3D2,s=
ec=3Dsys,mountvers=3D3,mountport=3D20048,mountproto=3Dudp,local_lock=3Dno=
ne)
>
> Using "soft" is not a good idea.  It could be the cause, but it isn't v=
ery
> likely if NFS is otherwise working OK.

NFS v3 has been working very well for us for many years.
When we upgraded those two servers ~3 years ago, we did try NFS v4 first,=
 but
that had caused frequent occurences of "un-killable processes in D state"=
,
so we had to revert to v3 to allow for stable operation.

> It might help to run
>    rpcdebug -m nfs -s all; rpcdebug -m nlm -s all ;rpcdebug -m rpc -s a=
ll
>    #repeat your test
>    rpcdebug -m nfs -c all; rpcdebug -m nlm -c all ;rpcdebug -m rpc -c a=
ll
>
> then collect the kernel logs (possibly just run "dmesg") and post all
> the messages which happened at that time.

Ok, attaching a log generated like this while running:

sqlite3 x.sqlite "PRAGMA case_sensitive_like=3D1;PRAGMA synchronous=3DOFF=
;PRAGMA=20
recursive_triggers=3DON;PRAGMA foreign_keys=3DOFF;PRAGMA locking_mode =3D=
 NORMAL;PRAGMA journal_mode =3D=20
TRUNCATE;"

> It might also help to find the port number that lockd is running on
>     rpcinfo -p $SERVER | grep 'tcp.*nlockmgr'

None of the ports reported this way contains the string "nlockmgr":
> rpcinfo -p myserver
>    program vers proto   port  service
>     100000    4   tcp    111  portmapper
>     100000    3   tcp    111  portmapper
>     100000    2   tcp    111  portmapper
>     100000    4   udp    111  portmapper
>     100000    3   udp    111  portmapper
>     100000    2   udp    111  portmapper

Regards,

Lutz Vieweg

--------------060000010303020609050307
Content-Type: application/x-xz;
 name="log.txt.xz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="log.txt.xz"

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
--------------060000010303020609050307--
