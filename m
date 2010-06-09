From: Steven Shiau <steven@nchc.org.tw>
Subject: Bug#579397: STAT_FAIL to debian for SM_MON of 192.168.120.254, No canonical hostname found for 192.168.120.254
Date: Wed, 09 Jun 2010 22:41:01 +0800
Message-ID: <4C0FA7FD.3000301@nchc.org.tw>
References: <4BF71C27.7070309@nchc.org.tw>	 <1274492328.11828.3.camel@localhost> <4BFA99CD.2040902@oracle.com>	 <4C0819C2.2020203@oracle.com> <1275769799.2870.107.camel@localhost>
Reply-To: Steven Shiau <steven@nchc.org.tw>, 579397@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>, 579397@bugs.debian.org,
 linux-nfs@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.579397.B579397.127609446926316@bugs.debian.org>
In-Reply-To: <1275769799.2870.107.camel@localhost>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-ID: <linux-nfs.vger.kernel.org>



On 2010=E5=B9=B406=E6=9C=8806=E6=97=A5 04:29, Ben Hutchings wrote:
> On Thu, 2010-06-03 at 17:08 -0400, Chuck Lever wrote:
>   =20
>> On 05/24/10 11:22 AM, Chuck Lever wrote:
>>     =20
> [...]
>   =20
>>> We can probably remove the reverse mapping constraint for presentatio=
n
>>> addresses. A simple fix might be to change statd_canonical_name() fro=
m:
>>>
>>> freeaddrinfo(ai);
>>> if (!result)
>>> return NULL;
>>>
>>> to
>>>
>>> freeaddrinfo(ai);
>>> if (!result)
>>> return strdup(hostname);
>>>
>>> Let me know if this works.
>>>       =20
>> Any update?  I have a patch ready for nfs-utils to fix this regression=
,
>> but I need confirmation that it addresses your problem.
>>     =20
> Steven originally had this problem, not me.  Steven, do you need me to
> build a new package with this change?
>
> Ben.
>
>   =20
Ben,
Yes, please.
Thanks.

Steven.

--=20
Steven Shiau<steven _at_ nchc org tw>  <steven _at_ stevenshiau org>
National Center for High-performance Computing, Taiwan.
http://www.nchc.org.tw
Public Key Server PGP Key ID: 1024D/9762755A
Fingerprint: A2A1 08B7 C22C 3D06 34DB  F4BC 08B3 E3D7 9762 755A
