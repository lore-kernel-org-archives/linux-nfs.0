Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:49844 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753308Ab1K2W7I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 17:59:08 -0500
Message-ID: <4ED563AC.5040501@panasas.com>
Date: Tue, 29 Nov 2011 14:58:52 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Peng Tao <bergwolf@gmail.com>, <linux-nfs@vger.kernel.org>,
        <bhalevy@tonian.com>, Garth Gibson <garth@panasas.com>,
        Matt Benjamin <matt@linuxbox.com>, Marc Eshel <eshel@almaden.ibm.com>,
        Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com>   <4ED54FE4.9050008@panasas.com> <4ED55399.4060707@panasas.com>  <1322603848.11286.7.camel@lade.trondhjem.org> <4ED55F78.205@panasas.com> <1322606842.11286.33.camel@lade.trondhjem.org>
In-Reply-To: <1322606842.11286.33.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/29/2011 02:47 PM, Trond Myklebust wrote:
> On Tue, 2011-11-29 at 14:40 -0800, Boaz Harrosh wrote: 
>> On 11/29/2011 01:57 PM, Trond Myklebust wrote:
>>>> Also Files when they will support segments and servers that request segments,
>>>> like the CEPH server, will very much enjoy the above, .i.e: Tell me the amount
>>>> you know you want to write.
>>>
>>> Why would we want to add segment support to the pNFS files client???
>>> Segments are a nuisance that multiply the amount of unnecessary chitchat
>>> between the client and the MDS without providing any tangible
>>> benefits...
>>>
>>
>> Your kidding right?
>>
>> One: it is mandated by the Standard, This is not an option. So a perfectly
>>      Standard complaint server is not Supported by Linux because we don't see
>>      the point.
> 
> Bollocks.. Nothing is "mandated by the Standard". If the server doesn't
> give us a full layout, then we fall back to write through MDS. Why dick
> around with crap that SLOWS YOU DOWN.
> 

NO! MAKE YOU FASTER.

The kind of typologies I'm talking about a single layout get ever 1GB is
marginal to the gain I get in deploying 100 of DSs. I have thousands of
DSs I want to spread the load evenly. I'm limited by the size of the layout
(Device info in the case of files) So I'm limited by the number of DSs I can
have in a layout. For large files these few devices become an hot spot all
the while the rest of the cluster is idle.

This is not a theory, we meet these problems ever day.

>> Two: There are already file-layout servers out there (multiple) which are
>>      waiting for the Linux files-layout segment support, because the underline
>>      FS requires Segments and now they do not work with the Linux client. These
>>      are CEPH and GPFS and more.
> 
> Then they will have a _long_ wait....
> 

OK, so now I understand. Because when I was talking to Fred before BAT and during
It was very very peculiar to me why he is not already done with that simple stuff.
Because usually Fred is such a brilliant fast programmer that I admire, and that simple
crap?

But now that explains

> Trond
> 

Heart
