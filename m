Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:35427 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412Ab2IMXY5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Sep 2012 19:24:57 -0400
Message-ID: <50526B39.3000802@panasas.com>
Date: Fri, 14 Sep 2012 02:24:41 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: [PATCHSET 00/10] pnfsd + pnfsd-exofs: Fixes and enhancements to layouts
 / recalls
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Benny, Linux pNFS Server hackers

I'm submitting a set of changes to the pNFSD-Server tree, which fix and
enhance the server, to make it usable by exofs-raid1/5, as well as
panfs. (Panfs is Panasas's out-of-tree cluster FS client, used in the
implementation of a pNFS MDS)

I have been sitting on these patches for months now, because there is
one patch in the center of the set with a SPLITME: title because it
is a combination of few changes intertwined, which could be staged
better. But because of lack of time I've never done that.
I'm submitting it as is. In the long run it does not matter because
they are all SQUASHMEs anyway, but a better staging would make it easier
for review. Sorry about that.

But I would like these patches In, for BAT. So we can all work on the
same code base. (Without, pnfsd is not usable for me)

These are the patches:

[PATCH 01/10] Revert "pnfsd-exofs: Two clients must not write to the
[PATCH 02/10] Revert "pnfsd-exofs: Add autologin support to exofs"

   These two revert on unfinished / buggy code that is already
   In Benny's tree. They will be introduced again at end of
   list.

[PATCH 03/10] SQUASHME: pnfsd: Pass less arguments to init_layout()
[PATCH 04/10] SQUASHME: Remove unused lr_flags & co
[PATCH 05/10] {SPLITME} SQUASHME: pnfsd: Revamp the all
[PATCH 06/10] SQUASHME: pnfsd-exofs: layout_return API changes
[PATCH 07/10] SQUASHME: pnfsd: Something very wrong with layout_recall of RETURN_FILE

   These 5 are a deep cleanup, fixes, and API enhancements, to the core
   Server. [PATCH 05/10] could have been split farther, into 3 patches.
   Read the individual commit messages for more explanations.
   (I hope I explained well)

[PATCH 08/10] SQUASHME: pnfsd-exofs: Autologin XDR also encode URI
[PATCH 09/10] SQUASHME: pnfsd-exofs: Autologin support to
[PATCH 10/10] pnfsd-exofs: Two clients must not write to the same

   These three are the two reverted below. Better divided for later
   SQUASHME


These patches can be fetched from:
   git://git.open-osd.org/linux-open-osd.git pnfsd-exofs-devel

Based on pnfs-all-latest (v3.5):
   [081ddba3] pnfs: mimic vanilla nfs4 stateid allocation in pNFS
And up to:
   [9613a8aa] pnfsd-exofs: Two clients must not write to the same RAID stripe

However these patches by themselves are not enough. There are important fixes
to exofs that went into 3.6-rc2 which must be applied for a working system.
I have all these on a different branch, based on v3.5
(They also include the usual UML fixes that I must apply for UML to work)

These patches can be fetched from:
   git://git.open-osd.org/linux-open-osd.git debugable_linux-next

Based on:
   [28a33cbc] Linux 3.5
And up to:
   [e7936c3b] RFC: do_xor_speed Broken on UML do to jiffies

This *debugable_linux-next* branch can just be merged with any
pnfs (v3.5) branch. For convenience I have such a merged branch at:
   git://git.open-osd.org/linux-open-osd.git merge_and_compile

It is all on the gitweb at:
   http://git.open-osd.org/gitweb.cgi?p=linux-open-osd.git;a=shortlog;h=refs/heads/merge_and_compile

Thanks for your review
Boaz
