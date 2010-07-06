From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Bug#579397: STAT_FAIL to debian for SM_MON of 192.168.120.254,
 No canonical hostname found for 192.168.120.254
Date: Tue, 06 Jul 2010 13:05:17 -0400
Message-ID: <4C33624D.2070405@oracle.com>
References: <4BF71C27.7070309@nchc.org.tw>	 <1274492328.11828.3.camel@localhost> <4BFA99CD.2040902@oracle.com>	 <4C0819C2.2020203@oracle.com> <1275769799.2870.107.camel@localhost> <4C0FA7FD.3000301@nchc.org.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Cc: Ben Hutchings <ben@decadent.org.uk>, 579397@bugs.debian.org,
	linux-nfs@vger.kernel.org
To: Steven Shiau <steven@nchc.org.tw>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:17560 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753130Ab0GFRGM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jul 2010 13:06:12 -0400
In-Reply-To: <4C0FA7FD.3000301@nchc.org.tw>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/ 9/10 10:41 AM, Steven Shiau wrote:
>
>
> On 2010=E5=B9=B406=E6=9C=8806=E6=97=A5 04:29, Ben Hutchings wrote:
>> On Thu, 2010-06-03 at 17:08 -0400, Chuck Lever wrote:
>>> On 05/24/10 11:22 AM, Chuck Lever wrote:
>> [...]
>>>> We can probably remove the reverse mapping constraint for presenta=
tion
>>>> addresses. A simple fix might be to change statd_canonical_name() =
from:
>>>>
>>>> freeaddrinfo(ai);
>>>> if (!result)
>>>> return NULL;
>>>>
>>>> to
>>>>
>>>> freeaddrinfo(ai);
>>>> if (!result)
>>>> return strdup(hostname);
>>>>
>>>> Let me know if this works.
>>> Any update? I have a patch ready for nfs-utils to fix this regressi=
on,
>>> but I need confirmation that it addresses your problem.
>> Steven originally had this problem, not me. Steven, do you need me t=
o
>> build a new package with this change?
>>
>> Ben.
>>
> Ben,
> Yes, please.
> Thanks.

Any progress on this?
