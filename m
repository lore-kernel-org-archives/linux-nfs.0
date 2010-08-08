From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Bug#579397: STAT_FAIL to debian for SM_MON of 192.168.120.254, No canonical hostname found for 192.168.120.254
Date: Sun, 8 Aug 2010 12:55:46 -0400
Message-ID: <6C244072-B1DA-4F2D-8707-767DBAAC13B5@oracle.com>
References: <4BF71C27.7070309@nchc.org.tw> <1274492328.11828.3.camel@localhost> <4BFA99CD.2040902@oracle.com> <4C0819C2.2020203@oracle.com> <1275769799.2870.107.camel@localhost> <4C0FA7FD.3000301@nchc.org.tw>  <4C33624D.2070405@oracle.com> <1281243553.7543.281.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=utf-8
Cc: Steven Shiau <steven@nchc.org.tw>, 579397@bugs.debian.org,
	linux-nfs@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:17310 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab0HHQ42 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Aug 2010 12:56:28 -0400
In-Reply-To: <1281243553.7543.281.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 8, 2010, at 12:59 AM, Ben Hutchings wrote:

> On Tue, 2010-07-06 at 13:05 -0400, Chuck Lever wrote:
>> On 06/ 9/10 10:41 AM, Steven Shiau wrote:
>>>=20
>>>=20
>>> On 2010=E5=B9=B406=E6=9C=8806=E6=97=A5 04:29, Ben Hutchings wrote:
>>>> On Thu, 2010-06-03 at 17:08 -0400, Chuck Lever wrote:
>>>>> On 05/24/10 11:22 AM, Chuck Lever wrote:
>>>> [...]
>>>>>> We can probably remove the reverse mapping constraint for presen=
tation
>>>>>> addresses. A simple fix might be to change statd_canonical_name(=
) from:
>>>>>>=20
>>>>>> freeaddrinfo(ai);
>>>>>> if (!result)
>>>>>> return NULL;
>>>>>>=20
>>>>>> to
>>>>>>=20
>>>>>> freeaddrinfo(ai);
>>>>>> if (!result)
>>>>>> return strdup(hostname);
>>>>>>=20
>>>>>> Let me know if this works.
>>>>> Any update? I have a patch ready for nfs-utils to fix this regres=
sion,
>>>>> but I need confirmation that it addresses your problem.
>>>> Steven originally had this problem, not me. Steven, do you need me=
 to
>>>> build a new package with this change?
>>>>=20
>>>> Ben.
>>>>=20
>>> Ben,
>>> Yes, please.
>>> Thanks.
>>=20
>> Any progress on this?
>=20
> I've heard nothing from Steven but one positive report from another
> user.  In any case we'll include this in our package.
>=20
> We now have a git repository of the nfs-utils package at
> <git://git.debian.org/kernel/nfs-utils.git>; currently our changes ar=
e
> kept in a quilt patch series in debian/patches.

Thanks, I'll submit the latest version of this to the nfs-utils maintai=
ner.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



