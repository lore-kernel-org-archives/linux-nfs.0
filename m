Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:42380 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751697Ab2KWFx7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Nov 2012 00:53:59 -0500
Message-ID: <50AF10ED.3070208@cn.fujitsu.com>
Date: Fri, 23 Nov 2012 14:00:13 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        =?UTF-8?B?ImZhID4+IOiMg+acneaMuiI=?= <fanchaoting@cn.fujitsu.com>
Subject: Re: nfs cache bug (when server delete the file ,nfs client can read
 file also)
References: <50AEF92B.4080900@cn.fujitsu.com>	 <4FA345DA4F4AE44899BD2B03EEEC2FA9092F7F07@SACEXCMBX04-PRD.hq.netapp.com>	 <50AF0850.6060901@cn.fujitsu.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9092F7F85@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9092F7F85@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: multipart/mixed;
 boundary="------------060804090208000107080501"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--------------060804090208000107080501
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=utf-8

Myklebust, Trond =E5=86=99=E9=81=93:
> On Fri, 2012-11-23 at 13:23 +0800, fanchaoting wrote:
>> Myklebust, Trond =E5=86=99=E9=81=93:
>>> On Fri, 2012-11-23 at 12:18 +0800, fanchaoting wrote:
>>>> Hi,everyone. I found a big bug abount nfs cache.
>>>>
>>>> when server delete the file ,nfs client can read file also.
>>>>
>>>> the following is the reproduce.
>>>>
>>>> ip: 192.168.0.19  nfs-client
>>>> ip: 192.168.0.20  nfs-client
>>>> ip: 192.168.0.21  nfs-server
>>>>
>>>> ####################################################################=
########
>>>>
>>>> /usr/bin/ssh -n 192.168.0.21 service nfs start
>>>> /usr/bin/ssh -n 192.168.0.21 /usr/sbin/rpc.idmapd
>>>> /usr/bin/ssh -n 192.168.0.19 /usr/sbin/rpc.idmapd
>>>> /usr/bin/ssh -n 192.168.0.20 /usr/sbin/rpc.idmapd
>>>> /usr/bin/ssh -n 192.168.0.21 "rm -rf /nfsroot; mkdir -p /nfsroot"
>>>> /usr/bin/ssh -n 192.168.0.21 /usr/sbin/exportfs -au
>>>> /usr/bin/ssh -n 192.168.0.21 /usr/sbin/exportfs -i -o insecure,no_ro=
ot_squash,rw,fsid=3D0 *:/nfsroot
>>>> /usr/bin/ssh -n 192.168.0.19 test -d /nfsroot || (rm -rf /nfsroot; m=
kdir -p /nfsroot)
>>>> /usr/bin/ssh -n 192.168.0.20 test -d /nfsroot || (rm -rf /nfsroot; m=
kdir -p /nfsroot)
>>>>
>>>> /usr/bin/ssh -n 192.168.0.19 umount /nfsroot
>>>> /usr/bin/ssh -n 192.168.0.20 umount /nfsroot
>>>> cmd=3D"echo \"hello world\" > /nfsroot/tmpfile"
>>>> /usr/bin/ssh -n 192.168.0.21 $cmd
>>>> /usr/bin/ssh -n 192.168.0.21 mkdir /nfsroot/tmpdir
>>>> /usr/bin/ssh -n 192.168.0.21 touch /nfsroot/tmpdir/tmpdfile
>>>> /usr/bin/ssh -n 192.168.0.19 mount -t nfs4 192.168.0.21:/ /nfsroot
>>>> /usr/bin/ssh -n 192.168.0.20 mount -t nfs4 192.168.0.21:/ /nfsroot
>>>> /usr/bin/ssh -n 192.168.0.21 cat  /nfsroot/tmpfile
>>>> /usr/bin/ssh -n 192.168.0.21 ls -l /nfsroot/tmpdir
>>>> /usr/bin/ssh -n 192.168.0.19 cat  /nfsroot/tmpfile
>>>> /usr/bin/ssh -n 192.168.0.19 ls -l  /nfsroot/tmpdir
>>>> /usr/bin/ssh -n 192.168.0.20 cat  /nfsroot/tmpfile
>>>> /usr/bin/ssh -n 192.168.0.20 ls -l  /nfsroot/tmpdir
>>>> /usr/bin/ssh -n 192.168.0.19 cat /nfsroot/tmpfile > /dev/null
>>>> /usr/bin/ssh -n 192.168.0.20 cat /nfsroot/tmpfile > /dev/null
>>>> /usr/bin/ssh -n 192.168.0.21 rm -rf /nfsroot/tmpfile
>>>> echo -e "sleep 60~~~~~~~~\n"
>>>> sleep 60
>>>>
>>>> ####################################################################=
#########
>>>>
>>>> last: In 192.168.0.19 I do:
>>>>
>>>> #cat /nfsroot/tmpfile           <--the nfs server delete the file,bu=
t nfs client can read the file
>>>>  hello world
>>>>
>>>>
>>>> I think  when the nfs server delete the file ,
>>>> the  server should notice the nfs client,
>>>> but the upstream kernel does't this.
>>> So is this a problem with the client or the server? In other words, i=
f
>>> you use a different server/client combination, do you see a different=

>>> result?
>>>
>> I think that the server has the problem .when the server deletes the f=
ile ,
>> it should notice the client immediately.
>=20
> There is no notification mechanism in NFS; on open(), the client is
> supposed to revalidate its cached information and the server is suppose=
d
> to return an ESTALE error if the filehandle is no longer valid. Either
> one of these 2 mechanisms (client revalidation or server reply) could b=
e
> going wrong here, which is why I'm asking.

I found J. Bruce Fields's patch(break delegations on unlink)  maybe solve=
 this problem .
But I did't found it in the upstream kernel.

I think when the server delete the file, it should reply a DELEGRETURN to=
 the nfs client.


>=20
>>> Which kernels are you using in your tests for the client and server?
>>>
>> I found the problem in kernel  3.7.0-rc6
>=20
> OK. Do you have a non-Linux server or client available that you can use=

> for testing? Alternatively, could you use wireshark to capture a dump o=
f
> the NFS traffic between the client and server?

In the wireshark, I found the right traffic should have open operation,
but now i can't find the open operation.

I found the function nfs4_open_prepare has problem , in the old kernel , =

it can  run=20

=2E..snip...

  rpc_call_start(task);

=2E..snip...


>=20


--------------060804090208000107080501
Content-Type: application/octet-stream;
 name="nfscache_cache_wrong.dump"
Content-Disposition: attachment;
 filename="nfscache_cache_wrong.dump"
Content-Transfer-Encoding: base64

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
4lU=


--------------060804090208000107080501
Content-Type: application/octet-stream;
 name="nfscache_cache_right.dump"
Content-Disposition: attachment;
 filename="nfscache_cache_right.dump"
Content-Transfer-Encoding: base64

1MOyoQIABAAAAAAAAAAAAP//AAABAAAAunSlUIIpBwAmAQAAJgEAAAAMKfwcqAAMKb9RPggARQAB
GNFiQABABucEwKgAE8CoABUC4QgBO/J2UCDL22yAGAM5PrIAAAEBCAoBteIfABoa0oAAAOCDnziO
AAAAAAAAAAIAAYajAAAABAAAAAEAAAABAAAAMABB+VAAAAAVbG9jYWxob3N0LmxvY2FsZG9tYWlu
AAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHAAAAFgAAAAgBAAEAAAAAAAAA
ACAAAAASAAAAAAAAAAEAAAAA8hOnUAYAAAAAAAAQb3BlbiBpZDqICD9wz663+wAAAAAAAAAAAAAA
B3RtcGZpbGUAAAAACgAAAAkAAAACABABGgAwojoAAAAfAAAACQAAAAIAAAAYADAAALp0pVB5LAcA
ggAAAIIAAAAADCm/UT4ADCn8HKgIAEUAAHTfBkAAQAbaBMCoABXAqAATCAEC4SDL22w78nc0gBgL
yNHDAAABAQgKABo8hwG14h+AAAA8g584jgAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAD
AAAAFgAAAAAAAAAgAAAAAAAAABIAAAACunSlUKIsBwBCAAAAQgAAAAAMKfwcqAAMKb9RPggARQAA
NNFjQABABufnwKgAE8CoABUC4QgBO/J3NCDL26yAEAM5FxQAAAEBCAoBteIgABo8h7p0pVBgLQcA
JgEAACYBAAAADCn8HKgADCm/UT4IAEUAARjRZEAAQAbnAsCoABPAqAAVAuEIATvydzQgy9usgBgD
OQHpAAABAQgKAbXiIAAaPIeAAADghJ84jgAAAAAAAAACAAGGowAAAAQAAAABAAAAAQAAADAAQflQ
AAAAFWxvY2FsaG9zdC5sb2NhbGRvbWFpbgAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAABwAAABYAAAAIAQABAAAAAAAAAAAgAAAAEgAAAAAAAAABAAAAAPITp1AGAAAAAAAAEG9w
ZW4gaWQ67Fuvlm29XmIAAAAAAAAAAAAAAAd0bXBmaWxlAAAAAAoAAAAJAAAAAgAQARoAMKI6AAAA
HwAAAAkAAAACAAAAGAAwAAC6dKVQZi4HAIIAAACCAAAAAAwpv1E+AAwp/ByoCABFAAB03wdAAEAG
2gPAqAAVwKgAEwgBAuEgy9usO/J4GIAYDE7PGAAAAQEICgAaPIcBteIggAAAPISfOI4AAAABAAAA
AAAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAwAAABYAAAAAAAAAIAAAAAAAAAASAAAAArp0pVCVzQcA
QgAAAEIAAAAADCn8HKgADCm/UT4IAEUAADTRZUAAQAbn5cCoABPAqAAVAuEIATvyeBggy9vsgBAD
ORXHAAABAQgKAbXiSQAaPIc=


--------------060804090208000107080501--

