From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [RFC][PATCH] client cannot get lock after other client got lock
 occur network partition.
Date: Tue, 10 Nov 2009 17:38:41 +0800
Message-ID: <4AF934A1.9040908@cn.fujitsu.com>
References: <4AF7DEAB.20202@cn.fujitsu.com> <1257772609.3754.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=Shift_JIS
Cc: NFSv3 list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64040 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752456AbZKJJhZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2009 04:37:25 -0500
In-Reply-To: <1257772609.3754.11.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond

Trond Myklebust =8E=CA=93=B9:
> On Mon, 2009-11-09 at 17:19 +0800, Mi Jinlong wrote:
>> Hi Trond et all
>>
>> There is a bug, when i test NFSv3 file's lock as followed:
>>
>> Step1: ClientA and ClientB open a same nfs file;
>> Step2: ClientA locks file with write lock, it's ok;
>> Step3: Cut off the network between ClientA and Server;
>> Step4: ClientB can not acquire for write lock successful forever, ev=
en though
>>        the network partition larger than NLM_HOST_EXPIRE.
>>
>> As i know, If use NFSv4, step4 can success after LEASE_TIME.
>>
>> Is it necessary to fix NFSv3 ?=20
>>
>> The attached patch can make this case OK, but i am not sure it's goo=
d.
>=20
> Unfortunately, NLM (the NFSv2 and v3 locking protocol) is not lease
> based, so the above scenario is truly an unfixable one.
>=20
> The problem with applying your patch is, in essence, that we risk
> breaking another scenario where a client grabs a lock, and then holds=
 it
> for a while.
> The reason this breaks is that there is no equivalent in the NLM
> protocol of the NFSv4 RENEW operation to tell the server that "This
> client is still alive and wants you to keep its state".

Thanks for your answer!

This bug seems serious, shouldn't we fix it?

thanks,
Mi Jinlong

