From: Orion Poplawski <orion@cora.nwra.com>
Subject: Re: Client performance questions
Date: Thu, 13 Dec 2007 21:24:18 -0700
Message-ID: <47620572.4020501@cora.nwra.com>
References: <0a15723c4b267d4eb8b5ad05800315c0@swip.net>	 <1197328226.25938.7.camel@heimdal.trondhjem.org>	 <fjshfu$6f6$1@ger.gmane.org> <1197593822.7964.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from earth.cora.nwra.com ([65.44.101.180]:52606 "EHLO
	earth.cora.nwra.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755694AbXLNEeF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Dec 2007 23:34:05 -0500
In-Reply-To: <1197593822.7964.8.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Thu, 2007-12-13 at 17:07 -0700, Orion Poplawski wrote:
>> Trond Myklebust wrote:
>>> Have you tried increasing the value
>>> in /proc/sys/fs/nfs/nfs_congestion_kb ?
>> Well, I just came across this message while trying to improve NFS 
>> performance locally.  On my F8 client, it is set to 30400 by default. 
>> Changing to 60800 kills performance.  Writes go from ~20MB/s to ~5MB/s, 
>> reads from ~80MB/s to ~47MB/s as measured by bonnie++.
>>
>> Expected?
> 
> UDP? If so, then possibly yes. UDP has lousy congestion control, so if
> the server gets too busy to respond, then performance dies.

Nope, TCP.  w/rsize is 32k.  Server is pretty lightly loaded.  Server is 
RHEL4.5.


-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA/CoRA Division                    FAX: 303-415-9702
3380 Mitchell Lane                  orion@cora.nwra.com
Boulder, CO 80301              http://www.cora.nwra.com
