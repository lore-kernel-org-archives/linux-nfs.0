From: Peter Staubach <staubach@redhat.com>
Subject: Re: [RFC][PATCH] client cannot get lock after other client got lock
 occur network partition.
Date: Wed, 11 Nov 2009 09:02:49 -0500
Message-ID: <4AFAC409.4050100@redhat.com>
References: <4AF7DEAB.20202@cn.fujitsu.com>	 <1257772609.3754.11.camel@heimdal.trondhjem.org>	 <4AF934A1.9040908@cn.fujitsu.com> <1257856550.3046.6.camel@heimdal.trondhjem.org> <4AFA853F.6000805@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	NFSv3 list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34055 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751405AbZKKOCy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Nov 2009 09:02:54 -0500
In-Reply-To: <4AFA853F.6000805@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/11/2009 04:34 AM, Mi Jinlong wrote:
> Hi Trond
>=20
> Trond Myklebust =E5=86=99=E9=81=93:
>> On Tue, 2009-11-10 at 17:38 +0800, Mi Jinlong wrote:
>>> Hi Trond
>>>
>>> Trond Myklebust =E5=86=99=E9=81=93:
>>>> On Mon, 2009-11-09 at 17:19 +0800, Mi Jinlong wrote:
>>>>> Hi Trond et all
>>>>>
>>>>> There is a bug, when i test NFSv3 file's lock as followed:
>>>>>
>>>>> Step1: ClientA and ClientB open a same nfs file;
>>>>> Step2: ClientA locks file with write lock, it's ok;
>>>>> Step3: Cut off the network between ClientA and Server;
>>>>> Step4: ClientB can not acquire for write lock successful forever,=
 even though
>>>>>        the network partition larger than NLM_HOST_EXPIRE.
>>>>>
>>>>> As i know, If use NFSv4, step4 can success after LEASE_TIME.
>>>>>
>>>>> Is it necessary to fix NFSv3 ?=20
>>>>>
>>>>> The attached patch can make this case OK, but i am not sure it's =
good.
>>>> Unfortunately, NLM (the NFSv2 and v3 locking protocol) is not leas=
e
>>>> based, so the above scenario is truly an unfixable one.
>>>>
>>>> The problem with applying your patch is, in essence, that we risk
>>>> breaking another scenario where a client grabs a lock, and then ho=
lds it
>>>> for a while.
>>>> The reason this breaks is that there is no equivalent in the NLM
>>>> protocol of the NFSv4 RENEW operation to tell the server that "Thi=
s
>>>> client is still alive and wants you to keep its state".
>>> Thanks for your answer!
>>>
>>> This bug seems serious, shouldn't we fix it?
>>
>> Unless you can think of a fix which works with the current NLM proto=
col,
>> I'd suggest simply encouraging people to move to a protocol with lea=
se
>> based locks: i.e. NFSv4...
>=20
> Can we add a process(like NFSv4's nfsd4) to call the nlm_gc_hosts() p=
eriodically?
> At nlm_gc_hosts, then call rpc_ping() to check whether network is OK,=
 if not,
> its resource will be release.
>=20

This would also violate the semantics that the current NLM has.
If, while holding the lock, the client does not need to contact
the server, it may not even notice the network partition and
will continue to expect that it holds the lock.

It might have been interesting to fix this problem about 20
years ago.  However, nowadays, we just live with it.  If it is
a real problem, then using NFSv4 can be a good solution.

		ps
