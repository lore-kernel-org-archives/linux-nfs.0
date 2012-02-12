Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:40764 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755164Ab2BLXFk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Feb 2012 18:05:40 -0500
Message-ID: <4F3845B5.6020402@panasas.com>
Date: Mon, 13 Feb 2012 01:05:25 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC 19/21] NFS: Convert v4 into a module
References: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>  <1328911325-1566-19-git-send-email-bjschuma@netapp.com>  <4F37FECD.9030500@panasas.com> <1329085229.2746.3.camel@lade.trondhjem.org>
In-Reply-To: <1329085229.2746.3.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/13/2012 12:20 AM, Myklebust, Trond wrote:
> On Sun, 2012-02-12 at 20:02 +0200, Boaz Harrosh wrote:
>> On 02/11/2012 12:02 AM, bjschuma@netapp.com wrote:
>>> The module will be created in the same directory as nfs.ko.  You need to
>>> run `modprobe nfs4` before you can use it.
>>>
>>
>> Can we do this mod_alias and autoloading magic like we do with 
>> LD drivers, so if NFSv4 is requested it is automatically loaded
>> by Kernel. 
> 
> You need to call request-module() from the nfs.ko module as soon as you
> know which version the user is trying to load...
> I don't see why you need mod_alias?
> 

That will work. I can now see that it's on the todo in the [00/21] mail
Sorry for the noise

Thanks
Boaz
