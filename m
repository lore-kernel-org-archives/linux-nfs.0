Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53192 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751475AbdFHWHc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Jun 2017 18:07:32 -0400
From: NeilBrown <neilb@suse.com>
To: Lutz Vieweg <lvml@5t9.de>, linux-nfs@vger.kernel.org
Date: Fri, 09 Jun 2017 08:07:23 +1000
Subject: Re: PROBLEM: nfs I/O errors with sqlite applications
In-Reply-To: <59399945.2020507@5t9.de>
References: <20151012164846.GA5017@draconx.ca> <20151012192538.GG28755@fieldses.org> <20151012194647.GJ28755@fieldses.org> <20151013030136.GA7081@draconx.ca> <20151013065225.44c5581d@synchrony.poochiereds.net> <CADyTPEyUKNdYuj0LwoX-r6jJJ0tEufwyA_mEKE=OVniX9rXPog@mail.gmail.com> <CADyTPEx=h95ODeG3BixMHc=kxLmkFt+aVyS+V_bK-b=CqK4_6Q@mail.gmail.com> <1469814735.19411.1.camel@poochiereds.net> <5936DC7B.8040804@5t9.de> <87vao8bilj.fsf@notabene.neil.brown.name> <59399945.2020507@5t9.de>
Message-ID: <871squb0bo.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 08 2017, Lutz Vieweg wrote:

> On 06/07/2017 05:08 AM, NeilBrown wrote:
>>>>   fcntl(3, F_SETLK, {type=3DF_RDLCK, whence=3DSEEK_SET, start=3D107374=
1824, len=3D1}) =3D -1 EIO (Input/output error)
>>>>   write(2, "Error: disk I/O error\n", 22Error: disk I/O error
>>>
>>> But unlike the original reporter, we use the NFS v3 protocol:
>>>> myserver:/data on /data type nfs (rw,relatime,vers=3D3,rsize=3D1048576=
,wsize=3D1048576,namlen=3D255,soft,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=
=3Dsys,mountvers=3D3,mountport=3D20048,mountproto=3Dudp,local_lock=3Dnone)
>>
>> Using "soft" is not a good idea.  It could be the cause, but it isn't ve=
ry
>> likely if NFS is otherwise working OK.
>
> NFS v3 has been working very well for us for many years.
> When we upgraded those two servers ~3 years ago, we did try NFS v4 first,=
 but
> that had caused frequent occurences of "un-killable processes in D state",
> so we had to revert to v3 to allow for stable operation.

I queried the use of "soft" - as opposed to "hard".
You defend the use of v3 as opposed to v4.
I think there is some miscommunication happening here.

If v3 works better for you than v4, then certainly use it.
You could try reporting details of the problems with v4, but I cannot
promise a helpful response, so it is totally up to you.

But "soft" is generally a bad idea.  It can lead to data corruption in
various way as it ports errors to user-space which user-space is often
not expecting.

These days, the processes in D state are (usually) killable.

>
>> It might help to run
>>    rpcdebug -m nfs -s all; rpcdebug -m nlm -s all ;rpcdebug -m rpc -s all
>>    #repeat your test
>>    rpcdebug -m nfs -c all; rpcdebug -m nlm -c all ;rpcdebug -m rpc -c all
>>
>> then collect the kernel logs (possibly just run "dmesg") and post all
>> the messages which happened at that time.
>
> Ok, attaching a log generated like this while running:
>
> sqlite3 x.sqlite "PRAGMA case_sensitive_like=3D1;PRAGMA synchronous=3DOFF=
;PRAGMA=20
> recursive_triggers=3DON;PRAGMA foreign_keys=3DOFF;PRAGMA locking_mode =3D=
 NORMAL;PRAGMA journal_mode =3D=20
> TRUNCATE;"

Thanks. Probably the key line is

[2339904.695240] RPC: 46702 remote rpcbind: RPC program/version unavailable

The client is trying to talk to lockd on the server, and lockd doesn't
seem to be there.


>
>> It might also help to find the port number that lockd is running on
>>     rpcinfo -p $SERVER | grep 'tcp.*nlockmgr'
>
> None of the ports reported this way contains the string "nlockmgr":

This agrees with the line from the log.  If nlockmgr isn't listed, then
locking cannot work.  This is the cause of your problem.

>> rpcinfo -p myserver
>>    program vers proto   port  service
>>     100000    4   tcp    111  portmapper
>>     100000    3   tcp    111  portmapper
>>     100000    2   tcp    111  portmapper
>>     100000    4   udp    111  portmapper
>>     100000    3   udp    111  portmapper
>>     100000    2   udp    111  portmapper

Even "nfs" isn't listed - but clearly the nfs server is running.

My guess is that rpcbind was restarted with the "-w" flag, so it lost
all the state that it previosly had.
If you stop and restart NFS service on the server, it might start
working again.  Otherwise just reboot the nfs server.

NeilBrown


>
> Regards,
>
> Lutz Vieweg

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlk5yp0ACgkQOeye3VZi
gbkGfxAAqLko+l9+uJmnYqNLXRVIf1cWMFJ/BmtQSNqdMgvausN4/8xQ0f4MTx6x
AF45ymPXqIMlJnqBGUs77s403/wanfUV5ErXND63nb6yFeGre81F3ZqqeLfasH2M
XqO+5WTKd4ZhXrl4VIef/0I1ZEt0F0odGrYSjr4GB0kSVbrGVp44L09NZgtxDrZv
oyqPqJ648VOsWSA564dEck1e/OhwROtXajrsJp0WyDOyypHvPstdmXHNGlVVOdT4
lGcFIM2ulZaiuiakoco+UQ7NIMUriKnwtSlob/YfaEpXELSDTRJ3ZDiP/D6rLodf
8A0Yqc7Jzdfk5sHn22Gd2x1646CuCJN3Ngmwdg0vum/qeH+k+Jce7DtfauvOl5Qp
FZ2tyFuPjbI3ucTaLEXpQHSJz+fPFxATQmQ6poLvMIURM5xacHOxl8zl0op/hqeG
DsjGTsY/cJ62rddy+zrSCCbegMYZ08Jx1Wit8oIYMMGKv8B4dZWgjSSf7LhapMK+
ZnzvYwjwbYESS64WkTGXGKEY7Da8cYnJo4ikThG2WQ0ch2L0hduPRShf9fC2IcYy
LzTrlzzsmXmbhvP7u7bH2CbewdzWt4nDux9ov4lZ2ZuMZKuqTc+MFhAuAjzx7s7U
ogkJjlhOjOrAIlIYOhyJ3nYXfa0OvBG8EiClQkmoB+lciQLdAzk=
=yggz
-----END PGP SIGNATURE-----
--=-=-=--
