Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:55250 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067Ab1HLVKI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Aug 2011 17:10:08 -0400
Message-ID: <4E4596A1.9050901@panasas.com>
Date: Fri, 12 Aug 2011 14:09:53 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Casey Bodley <cbodley@citi.umich.edu>,
        NFS list <linux-nfs@vger.kernel.org>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>,
        Malcolm Locke <malc@wholemeal.co.nz>
Subject: Re: Grace period NEVER ends
References: <4E44790A.8000106@panasas.com> <4E447EEB.501@panasas.com> <4E4481F0.2050806@panasas.com> <20110812021556.GD9761@pad.fieldses.org> <CAMeBU_28VPCtExvU1gr3oTbLLyqp=qFwFjxehoea64Xqi=_ncQ@mail.gmail.com> <20110812143228.GD16960@pad.fieldses.org> <4E458EBB.5020104@panasas.com>
In-Reply-To: <4E458EBB.5020104@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/12/2011 01:36 PM, Boaz Harrosh wrote:
> 
> I get these a lot:
> 	NFSD: nfsd4_create_clid_dir: DIRECTORY EXISTS
> 
> what is suppose to delete this directory? I did a clean
> umount and reboot. Next time up it is there.
> 

Bruce please look into this.

I do an:
[1]
[]$ service nfs start
	Starting NFS daemon: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
	NFSD: starting 90-second grace period
[]$ mount -t nfs4 -o minorversion=1 localhost:/ $MNT_PNFS
	Here I get the: NFSD: nfsd4_create_clid_dir: DIRECTORY EXISTS
[]$ dd if=/dev/zero of=$MNT_PNFS/dd1_pnfs bs=4k count=2048
	Here it waits, waits, waits, then boom done.

[2]
Then I do:
[]$ umount $MNT_PNFS
[]$ service nfs stop

And back to [1]

I constantly get the NFSD: nfsd4_create_clid_dir: DIRECTORY EXISTS.
Also if I do reboot after [2] then [1] after reboot I still get
the "DIRECTORY EXISTS"

Boaz
