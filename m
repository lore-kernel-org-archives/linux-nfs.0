Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:54855 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752635Ab0ILRBQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Sep 2010 13:01:16 -0400
Message-ID: <4C8D0759.6090201@panasas.com>
Date: Sun, 12 Sep 2010 19:01:13 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>, Benny Halevy <bhalevy@panasas.com>,
        Andy Adamson <andros@netapp.com>, Fred Isaman <iisaman@netapp.com>
Subject: [RFC 0/3] Ugliness in struct pnfs_layout_segment and possible uselessness
 of the device cache
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Struct pnfs_layout_segment is the generic part of the pnfs-getlayout (segment) operation
and should not hold any layout specific part.

So what is the 	struct nfs4_deviceid *deviceid; member doing there. This is a files
only useful member that has no meaning in objects and blocks. (The later have multiple
devices per layout)

I've hacked up a possible fix. Please review. These will need more work done:
- Actual testing. They are compiled only.
- Adjusted to multiple pending changes from the changes to the layout segment allocation
  to all these latest Fred changes.
- I wish the relevant parts get into the first batch of submission in the final form
  presented here, instead of changing later. Note the cleanup it gives to the files
  layout driver. Which can even be driven deeper. So they'll need to be integrated
  down deeper. (And code rebased above it)
- So I've actually attempted using the generic cache in the objects driver. And it
  should be usable once all the code changes settle down, and I fix that FIXME: which
  is there now (See [RFC 3/3])

Andy? (Fred)? would you want to take the generic and file-layout parts out of my hands
and see them through. For one they need testing which I don't have readily available.
That is if you like them and they make any sense.

[RFC 1/3] SQUASHME: Generalize the device cache so it can be used by all layouts
[RFC 2/3] SQUASHME: fileslayout: Adjust to device_cache API changes
[RFC 3/3] SQUASHME: pnfs-obj: Use the generic device cache

Thanks
Boaz
