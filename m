Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5660 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751225Ab2HGPM5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Aug 2012 11:12:57 -0400
Message-ID: <50213076.7060003@netapp.com>
Date: Tue, 07 Aug 2012 11:12:54 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Joerg Roedel <joro@8bytes.org>
CC: Joerg Roedel <joerg.roedel@amd.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        wdauchy@gmail.com
Subject: Re: kernel BUG at /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
References: <20120807134156.GP1996@amd.com> <50211E42.6040808@netapp.com> <20120807141548.GG1917@8bytes.org> <5021237D.1010107@netapp.com> <20120807142707.GH1917@8bytes.org> <502127EF.3030209@netapp.com> <20120807145019.GI1917@8bytes.org>
In-Reply-To: <20120807145019.GI1917@8bytes.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/07/2012 10:50 AM, Joerg Roedel wrote:
> On Tue, Aug 07, 2012 at 10:36:31AM -0400, Bryan Schumaker wrote:
>> Your stack trace is showing v4 calls on the failing box, those
>> definitely shouldn't be happening if you're using v3.  Can you double
>> check /etc/fstab and /proc/mounts on a working kernel to be sure?
> 
> So the bug is probably (for whatever reason) that the nfs4 path is
> called for an nfs3 mount :)

That's what I'm thinking.  If you're not using v4, what happens if you turn CONFIG_NFS_V4 off in your .config for the broken machine?  I still haven't been able to trigger the bug, even with your .config, so I'm going to keep poking at it.

- Bryan

> Anyway, I attach /proc/mounts and /etc/fstab from that box running a
> v3.5-rc5 kernel (where it works).

Thanks.  I don't see anything weird in there.  You're using the same settings for the other machine, too?

> 
> 
> 	Joerg
> 

