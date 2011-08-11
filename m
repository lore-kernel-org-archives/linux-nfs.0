Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:60223 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133Ab1HKSpQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 14:45:16 -0400
Message-ID: <4E4422FD.3060706@panasas.com>
Date: Thu, 11 Aug 2011 11:44:13 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@tonian.com>, Sorin Faibish <sfaibish@emc.com>,
        peter honeyman <honey@citi.umich.edu>
CC: <tao.peng@emc.com>, <torvalds@linux-foundation.org>,
        <rdunlap@xenotime.net>, <bergwolf@gmail.com>,
        <Trond.Myklebust@netapp.com>, <linux-raid@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        "Welch, Brent" <welch@panasas.com>
Subject: Re: Linux 3.1-rc1 (nfs/pnfs and drivers/md)
References: <CA+55aFwkJdyEpyNY64aAQ5ChrPZ8Kvx9iRUwy1J6_SRaxoN=zA@mail.gmail.com> <20110810122304.96b8be67.rdunlap@xenotime.net> <CA+a=Yy5izxiyvW5eYiWuute9E1vXwNTj4frdzNeEwsLDrszesg@mail.gmail.com> <20110810175829.a834d80f.rdunlap@xenotime.net> <CA+55aFzcSLrhkexEn=J7BN8F3P3Vy+EAjwgGwMQPdeoYoQG+Bw@mail.gmail.com> <F19688880B763E40B28B2B462677FBF805BF0EAC8A@MX09A.corp.emc.com> <4E43AAD1.7090806@tonian.com>
In-Reply-To: <4E43AAD1.7090806@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/11/2011 03:11 AM, Benny Halevy wrote:
> On 2011-08-11 06:26, tao.peng@emc.com wrote:
> 
> My Ack, that's indeed closer to what I had queued in my tree originally and
> follows the approach we used for the objects layout driver.
> 
> Benny
> 

Yes but this breaks "Sorin"'s conspiracy to sneak into readhat the block
layout driver. Because it would be selected automatically if you set
CONFIG_NFS41.

Because for some perverted reason readhat wants pNFS-Files in, with
latest patches, but not the blocks or objects. I liked it that Blocks
tried to state: "pNFS is with blocks as well". Even Trond agreed that
it is logical this way.

You select CONFIG_NFS41 or not. objects and blocks are a part of that,
mandated by the protocol.

(I don't know that it was "Sorin"'s Idea, I meant the block guys)

I wish we can go back to the auto selection but fix the dependency
stuff. Surly it is possible.

Thanks
Boaz
