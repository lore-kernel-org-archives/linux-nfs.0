Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:29681 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754767Ab2HGOgu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Aug 2012 10:36:50 -0400
Message-ID: <502127EF.3030209@netapp.com>
Date: Tue, 07 Aug 2012 10:36:31 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Joerg Roedel <joro@8bytes.org>
CC: Joerg Roedel <joerg.roedel@amd.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        wdauchy@gmail.com
Subject: Re: kernel BUG at /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
References: <20120807134156.GP1996@amd.com> <50211E42.6040808@netapp.com> <20120807141548.GG1917@8bytes.org> <5021237D.1010107@netapp.com> <20120807142707.GH1917@8bytes.org>
In-Reply-To: <20120807142707.GH1917@8bytes.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/07/2012 10:27 AM, Joerg Roedel wrote:
> On Tue, Aug 07, 2012 at 10:17:33AM -0400, Bryan Schumaker wrote:
>> On 08/07/2012 10:15 AM, Joerg Roedel wrote:
>>> Yes, it reproduces pretty reliable here with Ubuntu 11.10 Server on an
>>> Intel box with an NFSv3 directory mounted at boot. This is the only box
>>> I have seen this so far, probably it depends on the config. I attach the
>>> config of the failing box.
>>
>> Interesting.  Are you mounting v4, too?  This code shouldn't be
>> running for v3... maybe that's why I haven't been able to hit it.
> 
> No, I am not using NFSv4 on the box where the BUG happens. I have
> another box mounting the same directory where the BUG does not trigger
> with v3.6-rc1. A difference I spotted between the kernels is, that on
> the failing box NFS is compiled as a module whereas it is compiled into
> the kernel on the box that works fine. Not sure if that has anything to
> do with the problem...
> 

Your stack trace is showing v4 calls on the failing box, those definitely shouldn't be happening if you're using v3.  Can you double check /etc/fstab and /proc/mounts on a working kernel to be sure?

My VM has nfs as a module, so I don't think that's the issue... I just started compiling your config to test on my own.

> 
> 	Joerg
> 
> 

