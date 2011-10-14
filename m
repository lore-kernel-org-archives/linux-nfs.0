Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:38932 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522Ab1JNWeh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Oct 2011 18:34:37 -0400
Message-ID: <4E98B8F2.7090804@panasas.com>
Date: Sat, 15 Oct 2011 00:34:26 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: <bhalevy@tonian.com>
CC: <linux-nfs-owner@vger.kernel.org>, "Welch, Brent" <welch@panasas.com>,
        open-osd <osd-dev@open-osd.org>, NFS list <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCHSET 0/1 0/6] ore: RAID5 Support
References: <4E98703E.7040605@panasas.com> <1419910767-1318614648-cardhu_decombobulator_blackberry.rim.net-1274904192-@b18.c3.bise3.blackberry>
In-Reply-To: <1419910767-1318614648-cardhu_decombobulator_blackberry.rim.net-1274904192-@b18.c3.bise3.blackberry>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Benny.

Is it OK if we merge, pnfs tree and open-osd, on Monday in BAT first thing?
Tonight it's to late, and tomorrow I'm already flying. So Monday.

Have a safe trip
Boaz

On 10/14/2011 07:50 PM, Benny Halevy wrote:
> Awesome!
> 
> Benny
> -----Original Message-----
> From:	Boaz Harrosh <bharrosh@panasas.com>
> Sender:	linux-nfs-owner@vger.kernel.org
> Date:	Fri, 14 Oct 2011 19:24:14 
> To: Welch, Brent<welch@panasas.com>; open-osd<osd-dev@open-osd.org>; NFS list<linux-nfs@vger.kernel.org>; linux-fsdevel<linux-fsdevel@vger.kernel.org>
> Subject: [PATCHSET 0/1 0/6] ore: RAID5 Support
> 
> 
> I'm proud to present RAID5 support to ORE. Which enables raid5 for both
> exofs and pnfs-objects-layout driver.
> 
> The ORE with raid0/1/5 and soon 6 support has become a compact and abstract
> library, that with not a lot of effort, can support not only OSD but any
> type of devices. For example BTRFS, does it have a RAID5 support yet? if
> not it could use ORE. The ORE gets a bunch of pages at the top and produces
> bios for each device at the bottom. The libosd API can be easily abstracted
> and be used for block devices, just the same. The RAID layout supported by
> ORE is very rich, multi layered striping/mirroring/raid. even reacher then
> stacked MD. You can read about this layout here:
> http://git.open-osd.org/gitweb.cgi?p=ietf-rfc5664.git;a=blob_plain;f=draft-ietf-nfsv4-rfc5664bis.html;hb=boaz2
> Start at: 5.3. "Data Mapping Schemes" up to:
> 5.4.5. "RAID Usage and Implementation Notes"
> 
> There where some problems with the previous patchset here are
> the differences I squashed it to a new patchset at osd/linux-next.
> 
>  [PATCH 1/1] SQUASHME: into: ore: Only IO one group at a time (API change)
> 
> And without farther ado Here is the RAID5 support. This is highly complicated
> stuff, for humble me at least, and I would appreciate any review and/or comments
> you guys can give it. Thanks in advance. (Pretty Please? :-))
> 
> [PATCH 1/6] ore: Make ore_calc_stripe_info EXPORT_SYMBOL
> [PATCH 2/6] ore: RAID5 read
> [PATCH 3/6] ore: RAID5 Write
> [PATCH 4/6] exofs: Support for RAID5 read-4-write interface.
> [PATCH 5/6] pnfs-obj: Support for RAID5 read-4-write interface.
> [PATCH 6/6] ore: Enable RAID5 mounts
> 
> A tree with above plus all prerequisites is at:
> $ git clone git://open-osd.org/linux-open-osd linux-next
> [http://git.open-osd.org/gitweb.cgi?p=linux-open-osd.git;a=shortlog;h=refs/heads/merge_and_compile]
> 
> The code passes my tests, the highlight of which is git-clone linux and compare to
> and identical clone on ext4. But there must be month of farther testing done on this
> to get it better. For example. Aligned on stripe IO write back should be improved on
> all the way down to the VFS layer.
> 
> Thanks
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

