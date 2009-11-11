From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [RFC][PATCH] client cannot get lock after other client got lock
 occur network partition.
Date: Wed, 11 Nov 2009 17:34:55 +0800
Message-ID: <4AFA853F.6000805@cn.fujitsu.com>
References: <4AF7DEAB.20202@cn.fujitsu.com>	 <1257772609.3754.11.camel@heimdal.trondhjem.org>	 <4AF934A1.9040908@cn.fujitsu.com> <1257856550.3046.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFSv3 list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49683 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753028AbZKKJdk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Nov 2009 04:33:40 -0500
In-Reply-To: <1257856550.3046.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond

Trond Myklebust =E5=86=99=E9=81=93:
> On Tue, 2009-11-10 at 17:38 +0800, Mi Jinlong wrote:
>> Hi Trond
>>
>> Trond Myklebust =E5=86=99=E9=81=93:
>>> On Mon, 2009-11-09 at 17:19 +0800, Mi Jinlong wrote:
>>>> Hi Trond et all
>>>>
>>>> There is a bug, when i test NFSv3 file's lock as followed:
>>>>
>>>> Step1: ClientA and ClientB open a same nfs file;
>>>> Step2: ClientA locks file with write lock, it's ok;
>>>> Step3: Cut off the network between ClientA and Server;
>>>> Step4: ClientB can not acquire for write lock successful forever, =
even though
>>>>        the network partition larger than NLM_HOST_EXPIRE.
>>>>
>>>> As i know, If use NFSv4, step4 can success after LEASE_TIME.
>>>>
>>>> Is it necessary to fix NFSv3 ?=20
>>>>
>>>> The attached patch can make this case OK, but i am not sure it's g=
ood.
>>> Unfortunately, NLM (the NFSv2 and v3 locking protocol) is not lease
>>> based, so the above scenario is truly an unfixable one.
>>>
>>> The problem with applying your patch is, in essence, that we risk
>>> breaking another scenario where a client grabs a lock, and then hol=
ds it
>>> for a while.
>>> The reason this breaks is that there is no equivalent in the NLM
>>> protocol of the NFSv4 RENEW operation to tell the server that "This
>>> client is still alive and wants you to keep its state".
>> Thanks for your answer!
>>
>> This bug seems serious, shouldn't we fix it?
>=20
> Unless you can think of a fix which works with the current NLM protoc=
ol,
> I'd suggest simply encouraging people to move to a protocol with leas=
e
> based locks: i.e. NFSv4...

Can we add a process(like NFSv4's nfsd4) to call the nlm_gc_hosts() per=
iodically?
At nlm_gc_hosts, then call rpc_ping() to check whether network is OK, i=
f not,
its resource will be release.

thanks,
Mi Jinlong

