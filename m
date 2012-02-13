Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:37000 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751007Ab2BMN3s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Feb 2012 08:29:48 -0500
Message-ID: <4F39103B.2020804@netapp.com>
Date: Mon, 13 Feb 2012 08:29:31 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC 19/21] NFS: Convert v4 into a module
References: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>  <1328911325-1566-19-git-send-email-bjschuma@netapp.com>  <4F37FECD.9030500@panasas.com> <1329085229.2746.3.camel@lade.trondhjem.org> <4F3845B5.6020402@panasas.com>
In-Reply-To: <4F3845B5.6020402@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/12/12 18:05, Boaz Harrosh wrote:

> On 02/13/2012 12:20 AM, Myklebust, Trond wrote:
>> On Sun, 2012-02-12 at 20:02 +0200, Boaz Harrosh wrote:
>>> On 02/11/2012 12:02 AM, bjschuma@netapp.com wrote:
>>>> The module will be created in the same directory as nfs.ko.  You need to
>>>> run `modprobe nfs4` before you can use it.
>>>>
>>>
>>> Can we do this mod_alias and autoloading magic like we do with 
>>> LD drivers, so if NFSv4 is requested it is automatically loaded
>>> by Kernel. 
>>
>> You need to call request-module() from the nfs.ko module as soon as you
>> know which version the user is trying to load...
>> I don't see why you need mod_alias?
>>
> 
> That will work. I can now see that it's on the todo in the [00/21] mail
> Sorry for the noise


I agree that it's important to do, so don't worry about the extra reminder!

- Bryan

> 
> Thanks
> Boaz


