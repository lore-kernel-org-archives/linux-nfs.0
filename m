Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 8bytes.org ([85.214.48.195]:51777 "EHLO mail.8bytes.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754977Ab2HGO1K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Aug 2012 10:27:10 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.8bytes.org (Postfix) with SMTP id 0B06312B085
	for <linux-nfs@vger.kernel.org>; Tue,  7 Aug 2012 16:27:09 +0200 (CEST)
Date: Tue, 7 Aug 2012 16:27:07 +0200
From: Joerg Roedel <joro@8bytes.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Joerg Roedel <joerg.roedel@amd.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        wdauchy@gmail.com
Subject: Re: kernel BUG at /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
Message-ID: <20120807142707.GH1917@8bytes.org>
References: <20120807134156.GP1996@amd.com>
 <50211E42.6040808@netapp.com>
 <20120807141548.GG1917@8bytes.org>
 <5021237D.1010107@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5021237D.1010107@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 07, 2012 at 10:17:33AM -0400, Bryan Schumaker wrote:
> On 08/07/2012 10:15 AM, Joerg Roedel wrote:
> > Yes, it reproduces pretty reliable here with Ubuntu 11.10 Server on an
> > Intel box with an NFSv3 directory mounted at boot. This is the only box
> > I have seen this so far, probably it depends on the config. I attach the
> > config of the failing box.
> 
> Interesting.  Are you mounting v4, too?  This code shouldn't be
> running for v3... maybe that's why I haven't been able to hit it.

No, I am not using NFSv4 on the box where the BUG happens. I have
another box mounting the same directory where the BUG does not trigger
with v3.6-rc1. A difference I spotted between the kernels is, that on
the failing box NFS is compiled as a module whereas it is compiled into
the kernel on the box that works fine. Not sure if that has anything to
do with the problem...


	Joerg


