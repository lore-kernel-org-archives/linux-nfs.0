Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52884 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752371Ab2HGORh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Aug 2012 10:17:37 -0400
Message-ID: <5021237D.1010107@netapp.com>
Date: Tue, 07 Aug 2012 10:17:33 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Joerg Roedel <joro@8bytes.org>
CC: Joerg Roedel <joerg.roedel@amd.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        wdauchy@gmail.com
Subject: Re: kernel BUG at /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
References: <20120807134156.GP1996@amd.com> <50211E42.6040808@netapp.com> <20120807141548.GG1917@8bytes.org>
In-Reply-To: <20120807141548.GG1917@8bytes.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/07/2012 10:15 AM, Joerg Roedel wrote:
> On Tue, Aug 07, 2012 at 09:55:14AM -0400, Bryan Schumaker wrote:
>> On 08/07/2012 09:41 AM, Joerg Roedel wrote:
>>> starting with Linux 3.6-rc1 I experience this BUG on one of my test
>>> machines. Please let me know if you need any additional information.
>>
>> I think this is the same bug that William Dauchy has been hitting.  Do
>> you have a reproducer for this?  I haven't been able to trigger it on
>> my own :(.
> 
> Yes, it reproduces pretty reliable here with Ubuntu 11.10 Server on an
> Intel box with an NFSv3 directory mounted at boot. This is the only box
> I have seen this so far, probably it depends on the config. I attach the
> config of the failing box.

Interesting.  Are you mounting v4, too?  This code shouldn't be running for v3... maybe that's why I haven't been able to hit it.

- Bryan

> 
> HTH,
> 
> 	Joerg
> 

