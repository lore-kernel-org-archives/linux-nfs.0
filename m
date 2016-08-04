Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:34584 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758747AbcHDPEr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Aug 2016 11:04:47 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 65B4D280AEF
	for <linux-nfs@vger.kernel.org>; Thu,  4 Aug 2016 17:04:43 +0200 (CEST)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 560D313E95
	for <linux-nfs@vger.kernel.org>; Thu,  4 Aug 2016 17:04:41 +0200 (MEST)
Date: Thu, 4 Aug 2016 17:04:41 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Andy Adamson <William.Adamson@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Steve Dickson <steved@redhat.com>
Message-ID: <748748607.4225721.1470323081028.JavaMail.zimbra@desy.de>
In-Reply-To: <CAN-5tyGMXCob2a222_PJr5vnzaMtb0UKNPH-QASq8a8v3U2ebA@mail.gmail.com>
References: <1485779983.22627050.1467888579184.JavaMail.zimbra@desy.de>
    <34F13011-FB4A-4ACD-9DDC-BAD3F7EC9B56@netapp.com>
    <1826288060.966410.1468428541658.JavaMail.zimbra@desy.de>
    <CAN-5tyEKDpciUS81QEQwS_ioufndrjDKzPwtcYkQ8O8hvtWiQQ@mail.gmail.com>
    <1548681850.3694730.1470049705230.JavaMail.zimbra@desy.de>
    <CAN-5tyGMXCob2a222_PJr5vnzaMtb0UKNPH-QASq8a8v3U2ebA@mail.gmail.com>
Subject: Re: Lost CLOSE with NFSv4.1 on RHEL7 ( and bejond?)
MIME-Version: 1.0
Content-Type: multipart/mixed;
    boundary="----=_Part_4225719_791975097.1470323081026"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

------=_Part_4225719_791975097.1470323081026
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


Hi Olga et al.

Finally I was able to to create a reproducer (attached)!

It looks like, if on close client application is interrupted by
Ctrl+C or SIGINT, then nfs client does not sends CLOSE. I can
100% reproduce it on RHEL7 and Fedora24 with 4.6 kernel. The 4.7
kernel works (side effect of some other change?).

The attached application reads file in a loop. On the second
iteration a thread is started, which will send SIGINT
to itself. When CLOSE is lost, you still can read the
file. Client even won't send any OPEN. So it looks like
that some where file is marked as open, but corresponding
process does not exist any more. Even re-mount does not help.

Best regards,
   Tigran.

----- Original Message -----
> From: "Olga Kornievskaia" <aglo@umich.edu>
> To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
> Cc: "Andy Adamson" <William.Adamson@netapp.com>, "Linux NFS Mailing List"=
 <linux-nfs@vger.kernel.org>, "Trond Myklebust"
> <trond.myklebust@primarydata.com>, "Steve Dickson" <steved@redhat.com>
> Sent: Monday, August 1, 2016 11:22:10 PM
> Subject: Re: Lost CLOSE with NFSv4.1 on RHEL7 ( and bejond?)

> On Mon, Aug 1, 2016 at 7:08 AM, Mkrtchyan, Tigran
> <tigran.mkrtchyan@desy.de> wrote:
>> Hi Olga,
>>
>> we have installed kernel 4.7.0 on one of the nodes and don't see missing
>> closes from that node.
>>
>> Nevertheless, I don't think that the commit you have mentioned is fixing=
 that,
>> as it fixes OPEN_DOWNGRADE, but we have a sequence of OPEN->CLOSE->OPEN.=
 The
>> OPEN_DOWNGRADE is not expected - file is already closed when a second op=
en
>> is sent and both requests using the same session slot.
>>
>> Have you seen a similar issue on vanilla or rhel kernel?
>=20
> I had a hard time triggering it consistently. I believe I have seen it
> on RHEL7.2 kernel but I think I was more consistently seeing it on
> some upstream (Trond's) kernel version (I think it was around 4.2).
> The problem was seen by Netapp QA on 4.3-rc7 version.
>=20
> Thanks for testing on the 4.7 version. I'll see what else went in that
> might explain the failure on the older kernel.
>=20
>>
>> Thanks a lot,
>>    Tigran.
>>
>> ----- Original Message -----
>>> From: "Olga Kornievskaia" <aglo@umich.edu>
>>> To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
>>> Cc: "Andy Adamson" <William.Adamson@netapp.com>, "Linux NFS Mailing Lis=
t"
>>> <linux-nfs@vger.kernel.org>, "Trond Myklebust"
>>> <trond.myklebust@primarydata.com>, "Steve Dickson" <steved@redhat.com>
>>> Sent: Thursday, July 14, 2016 4:52:59 PM
>>> Subject: Re: Lost CLOSE with NFSv4.1 on RHEL7 ( and bejond?)
>>
>>> Hi Tigran,
>>>
>>> On Wed, Jul 13, 2016 at 12:49 PM, Mkrtchyan, Tigran
>>> <tigran.mkrtchyan@desy.de> wrote:
>>>>
>>>>
>>>> Hi Andy,
>>>>
>>>> I will try to get upstream kernel on one of the nodes. It will take
>>>> some time as we need to add a new host into the cluster and get
>>>> some traffic go through it.
>>>>
>>>> In the mean while, with RHEL7 we get it easy reproduced - about 10
>>>> such cases per day. Is there any tool that will help us to see where
>>>> it happens? Some traces points? Call trace from vfs close to NFS close?
>>>
>>> There are NFS tracepoints but I don't know think there are VFS
>>> tracepoints. Unfortunately, there was a bug in the OPEN tracepoints
>>> that caused a kernel crash. I had a bugzilla out for RHEL7.2. It says
>>> it's fixed in the later kernel (.381) but it's currently not back
>>> ported to RHEL7.2z but hopefully will be soon (just chatted with Steve
>>> about getting the fix into zstream). I made no progress in figuring
>>> out what could be causing the lack of CLOSE and it was hard for me to
>>> reproduce.
>>>
>>> Just recently Trond fixed a problem where a CLOSE that was suppose to
>>> be sent as an OPEN_DOWNGRADE wasn't sent (commit 0979bc2a59) . I
>>> wonder if that can be fixing this problem....
>>>
>>>> There is a one comment in the kernel code, which sounds similar:
>>>> (http://git.linux-nfs.org/?p=3Dtrondmy/linux-nfs.git;a=3Dblob;f=3Dfs/n=
fs/nfs4proc.c;h=3D519368b987622ea23bea210929bebfd0c327e14e;hb=3Drefs/heads/=
linux-next#l2955)
>>>>
>>>> nfs4proc.c: 2954
>>>> =3D=3D=3D=3D
>>>>
>>>> /*
>>>>  * It is possible for data to be read/written from a mem-mapped file
>>>>  * after the sys_close call (which hits the vfs layer as a flush).
>>>>  * This means that we can't safely call nfsv4 close on a file until
>>>>  * the inode is cleared. This in turn means that we are not good
>>>>  * NFSv4 citizens - we do not indicate to the server to update the fil=
e's
>>>>  * share state even when we are done with one of the three share
>>>>  * stateid's in the inode.
>>>>  *
>>>>  * NOTE: Caller must be holding the sp->so_owner semaphore!
>>>>  */
>>>> int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
>>>>
>>>
>>> I'm not sure if the comment means to say that there is a possibility
>>> that NFS won't send a CLOSE (or at least I hope not). I thought that
>>> because we keep a reference count on the inode and send the CLOSE when
>>> it goes down to 0. Basically the last WRITE will trigger the nfs close
>>> not the vfs_close.
>>>
>>>
>>>> =3D=3D=3D=3D
>>>>
>>>>
>>>> Tigran.
>>>>
>>>>
>>>> ----- Original Message -----
>>>>> From: "Andy Adamson" <William.Adamson@netapp.com>
>>>>> To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
>>>>> Cc: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>, "Andy Adams=
on"
>>>>> <William.Adamson@netapp.com>, "Trond Myklebust"
>>>>> <trond.myklebust@primarydata.com>, "Steve Dickson" <steved@redhat.com>
>>>>> Sent: Tuesday, July 12, 2016 7:16:19 PM
>>>>> Subject: Re: Lost CLOSE with NFSv4.1 on RHEL7 ( and bejond?)
>>>>
>>>>> Hi Tigran
>>>>>
>>>>> Can you test with an upstream kernel? Olga has seen issues around no =
CLOSE being
>>>>> sent - it is really hard to reproduce=E2=80=A6.
>>>>>
>>>>> =E2=80=94>Andy
>>>>>
>>>>>
>>>>>> On Jul 7, 2016, at 6:49 AM, Mkrtchyan, Tigran <tigran.mkrtchyan@desy=
.de> wrote:
>>>>>>
>>>>>>
>>>>>>
>>>>>> Dear NFS folks,
>>>>>>
>>>>>> we observe orphan open-states on our deployment with nfsv4.1.
>>>>>> Our setup - two client nodes, running RHEL-7.2 with kernel
>>>>>> 3.10.0-327.22.2.el7.x86_64. Both nodes running ownCloud (like
>>>>>> a dropbox) which nfsv4.1 mounts to dCache storage. Some clients
>>>>>> connected to node1, others to node2.
>>>>>>
>>>>>> Time-to-time we see some 'active' transfers on data our DS
>>>>>> which do nothing. There is a corresponding state on MDS.
>>>>>>
>>>>>> I have traced one one such cases:
>>>>>>
>>>>>>  - node1 uploads the file.
>>>>>>  - node2 reads the file couple of times, OPEN+LAYOUTGET+CLOSE
>>>>>>  - node2 sends OPEN+LAYOUTGET
>>>>>>  - there is no open file on node2 which points to it.
>>>>>>  - CLOSE never send to the server.
>>>>>>  - node1 eventually removes the removes the file
>>>>>>
>>>>>> We have many other cases where file is not removed, but this one I w=
as
>>>>>> able to trace. The link to capture files:
>>>>>>
>>>>>> https://desycloud.desy.de/index.php/s/YldowcRzTGJeLbN
>>>>>>
>>>>>> We had ~ 10^6 transfers in last 2 days and 29 files in such state (~=
0.0029%).
>>>>>>
>>>>> > Tigran.
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

------=_Part_4225719_791975097.1470323081026
Content-Type: text/x-c++src; name="nfs_leak_close.c"
Content-Disposition: attachment; filename="nfs_leak_close.c"
Content-Transfer-Encoding: base64

I2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxzdGRsaWIuaD4KI2luY2x1ZGUgPGZjbnRsLmg+
CiNpbmNsdWRlIDx1bmlzdGQuaD4KI2luY2x1ZGUgPHN5cy9zdGF0Lmg+CiNpbmNsdWRlIDxzaWdu
YWwuaD4KI2luY2x1ZGUgPHB0aHJlYWQuaD4KCiNkZWZpbmUgQlNJWkUgNTEyCgp2b2lkICpraWxs
X3Rhc2sodm9pZCAqYXJnKQp7CiAgICBraWxsKGdldHBpZCgpLCBTSUdJTlQpOwogICAgcmV0dXJu
IE5VTEw7Cn0KCmludCBpb190YXNrKGNvbnN0IGNoYXIgKmZuYW1lLCBvZmZfdCBzaXplKQp7CiAg
ICBpbnQgZmQ7CiAgICBpbnQgcmVzOwogICAgY2hhciBidWZbQlNJWkVdOwogICAgaW50IG4gPSAw
OwogICAgcHRocmVhZF90IHRpZDsKCiAgICB3aGlsZSAoMSkgewoJZmQgPSBvcGVuKGZuYW1lLCBP
X1JET05MWSk7CglpZiAoZmQgPCAwKSB7CgkgICAgcGVycm9yKCJmYWlsZCB0byBvcGVuIGZpbGU6
Iik7CgkgICAgcmV0dXJuIGZkOwoJfQoKCXJlcyA9IGxzZWVrKGZkLCByYW5kb20oKSAlIHNpemUs
IFNFRUtfU0VUKTsKCWlmIChyZXMgPCAwKSB7CgkgICAgcGVycm9yKCJzdGF0Iik7CgkgICAgcmV0
dXJuIHJlczsKCX0KCglpZiAobikgewoJICAgIC8qIHRyeSB0byBzaW11bGF0ZSBzeXN0ZW0gY2Fs
bCBpbnRlcnJ1cHQgKi8KCSAgICBwdGhyZWFkX2NyZWF0ZSgmdGlkLCBOVUxMLCBraWxsX3Rhc2ss
IE5VTEwpOwoJfQoKCXJlYWQoZmQsIGJ1ZiwgQlNJWkUpOwoKCXB0aHJlYWRfeWllbGQoKTsKCgly
ZXMgPSBjbG9zZShmZCk7CglpZiAocmVzIDwgMCkgewoJICAgIHBlcnJvcigiZmFpbGQgdG8gY2xv
c2UgZmlsZToiKTsKCSAgICByZXR1cm4gcmVzOwoJfQoJbisrOwogICAgfQogICAgcmV0dXJuIDA7
Cn0KCmludCBtYWluKGludCBhcmdjLCBjaGFyICphcmd2W10pCnsKICAgIHN0cnVjdCBzdGF0IHNi
dWY7CiAgICBjb25zdCBjaGFyICpmbmFtZTsKCiAgICBpZiAoYXJnYyAhPSAyKSB7CglwcmludGYo
IlVzYWdlOiAlczogPGZuYW1lPlxuIiwgYXJndlswXSk7CglleGl0KDEpOwogICAgfQoKICAgIGZu
YW1lID0gYXJndlsxXTsKCiAgICBpZiAoc3RhdChmbmFtZSwgJnNidWYpIDwgMCkgewoJcGVycm9y
KCJzdGF0Iik7CglleGl0KDEpOwogICAgfQoKICAgIGlvX3Rhc2soKHZvaWQgKikgZm5hbWUsIHNi
dWYuc3Rfc2l6ZSk7CgogICAgcmV0dXJuIDA7Cn0K

------=_Part_4225719_791975097.1470323081026--
