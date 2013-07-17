Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:46235 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757093Ab3GQTf4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jul 2013 15:35:56 -0400
Received: by mail-pd0-f170.google.com with SMTP id x11so2193308pdj.15
        for <linux-nfs@vger.kernel.org>; Wed, 17 Jul 2013 12:35:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <A5C56FD6-9E14-43A3-8627-1C8F77EC6926@oracle.com>
References: <CAHsu+b_hhSr2vwcwM8TX3=xF=3HffUXG=YLVLcsEpH1wHn+JoA@mail.gmail.com>
	<A5C56FD6-9E14-43A3-8627-1C8F77EC6926@oracle.com>
Date: Wed, 17 Jul 2013 21:35:55 +0200
Message-ID: <CAHsu+b9vWUyCGHSs==Na=VntwvYp65=rva7+y9aQDXquxX4t-A@mail.gmail.com>
Subject: Re: Error writing to nfs4 with 3.11-rc1
From: Andre Heider <a.heider@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: multipart/mixed; boundary=047d7b5d9eb3c52b5204e1ba33c9
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--047d7b5d9eb3c52b5204e1ba33c9
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 17, 2013 at 9:10 PM, Chuck Lever <chuck.lever@oracle.com> wrote=
:
>
> On Jul 17, 2013, at 2:55 PM, Andre Heider <a.heider@gmail.com> wrote:
>
>> Hi,
>>
>> I'm having problems using 3.11-rc1 as nfs4 client (with a FreeBSD 9.1
>> server) using sec=3Dsys.
>>
>> With the same server+client setup, just booting different kernels:
>> 3.9.10 works without issues
>> 3.10.1 works too, but introduced "RPC: AUTH_GSS upcall timed out." in
>> dmesg (iirc I don't need gss with sec=3Dsys)
>
> Not a requirement, but running gssd should make that message go away.  Th=
e client is attempting to use krb5i to manage its lease on the server, and =
falling back to AUTH_UNIX when it sees gssd is not running.
>
>> 3.11-rc1 reading from the server still works, writing fails
>>
>> Even a simple touch on the share fails with:
>> touch: cannot touch =E2=80=98/mnt/andre/test=E2=80=99: Input/output erro=
r
>
> A network capture is a reasonable place to start.
>
>   # tcpdump -s0 -w /tmp/raw
>
> Then try your touch test again.  Stop the tcpdump.  You can post a compre=
ssed version of the raw dump here if it's short.

Attached two dumps, one from 3.10 (works) and one from 3.11 (doesn't work).

Thanks,
Andre

--047d7b5d9eb3c52b5204e1ba33c9
Content-Type: application/octet-stream; name="dump.tar.xz"
Content-Disposition: attachment; filename="dump.tar.xz"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hj8xjszx0

/Td6WFoAAATm1rRGAgAhARYAAAB0L+Wj4Cf/A7ldABmLgoeLX5/09jcjiFh5N+2vb5aHUGmDuTew
2+q5DW9l9XcneMCoAio23quhI235aI12BRax1hcGCfhbfDuHcjO7kpASxf+gy+KeHxAjHMjbjTkQ
+DRcLLS4OTk7M8eEFGs4hEHRsO5w6TydSae3xVZvfLfHuiWCZ6Onmoz59KACMHqNBNyFZCKxokdm
d9BKf3Ymj/oERl55EKcQnZPmcK2t3LpNGsN+jW3q6yJMJZLQ0nQ1h5NvyZbVPOe5+bdnnaxSOW18
XvN0jPy+qwnJoGS/BREAz7gexpYUvyfJr86J0O7jphWG7M0PqjI4b8rrwJsJKgK4HCgyjyGUZMnR
JpogNYgcw6P5rAHe3ngEw2zCHCwgdZ8+ICiBD0OVTkDZxMeCd62rksxMVMVJOLytvaCObsWKp//4
/QlMmGsWAYM2jM2GESCMvm2XmkRzmIyIIPvTd1IXQuToxgGyltHQYP9uuoHqbo397XdsvnNYkIP7
JXIKMwBemo4mP96p21nU/+t3Wm7HvYNaQ0s5RWskHfbuQJ2wlBnbZR4mr01kZf1JE30EQmrsUcRQ
eaOR6cBoYTFiP5RUR3d05jdbH6QnivPH+ZM45XhWRlM4ingqWe99gsq/Y/JpqizM1UFtY/sOqh5D
fvE1nqABhH041EPocoHc5wtFMIWY5AMzu+gehoEYM8IxjQqCVfuNGzu0gvmtmY1m3uSFi90vHMOP
EtY/G5qV+ZpcyI1Ib5jJOV1QuHe4mGMM/po6HkYj9rPIwSetjJtwrzIT4lj6ZR+2y6QckQEW7oJW
r5s2wWb8iPK5QKpVicvUZiFNWpKHWh6Rahuez7s8d8FTXSNCYqcE0eENN0NTng2LzF76mjIKrDX5
p4pU3D115L5CBDcsbR6m+OYDie+SQ4s/a3HzI42hBuV+igkO3bFckt0bsN4PBqlhcOJVZARaqzqa
KMKCow0QpvTSFD4n+w1TpoOzVetJXCS6w/jNf+rpIw3zajArExpdic9IgGhG87BAYHh3EmO+r4yI
aTX/RIhI1Ci7b1sTpUzWAxmorijWOZkiNMlVAZr7ZDplm01bdh9E9mm3a6z/51GTyA9MNWNEaBob
tE6KOl0JFLtzIYl54RtYw2eKG3eLe0XpqpON45AHO9jU6T6APpUijtJJnBGbo0hnnfH5W0RVUckl
7nByAeAWJE9aghXXKsCWTds7/wqtza3tBbc2NgQk42OOZ6Ep9t1nxov6FP+OuldbbfsUk7Ks0teW
how75TYFaHF7Y7TLWUcAAAAAAPNwi53AgawCAAHVB4BQAADaHWOyscRn+wIAAAAABFla
--047d7b5d9eb3c52b5204e1ba33c9--
