From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC][PATCH] client cannot get lock after other client got
 lock occur network partition.
Date: Mon, 09 Nov 2009 08:16:48 -0500
Message-ID: <1257772609.3754.11.camel@heimdal.trondhjem.org>
References: <4AF7DEAB.20202@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFSv3 list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:53118 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754492AbZKINQr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Nov 2009 08:16:47 -0500
In-Reply-To: <4AF7DEAB.20202@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-11-09 at 17:19 +0800, Mi Jinlong wrote:
> Hi Trond et all
> 
> There is a bug, when i test NFSv3 file's lock as followed:
> 
> Step1: ClientA and ClientB open a same nfs file;
> Step2: ClientA locks file with write lock, it's ok;
> Step3: Cut off the network between ClientA and Server;
> Step4: ClientB can not acquire for write lock successful forever, even though
>        the network partition larger than NLM_HOST_EXPIRE.
> 
> As i know, If use NFSv4, step4 can success after LEASE_TIME.
> 
> Is it necessary to fix NFSv3 ? 
> 
> The attached patch can make this case OK, but i am not sure it's good.

Unfortunately, NLM (the NFSv2 and v3 locking protocol) is not lease
based, so the above scenario is truly an unfixable one.

The problem with applying your patch is, in essence, that we risk
breaking another scenario where a client grabs a lock, and then holds it
for a while.
The reason this breaks is that there is no equivalent in the NLM
protocol of the NFSv4 RENEW operation to tell the server that "This
client is still alive and wants you to keep its state".

Cheers,
  Trond


