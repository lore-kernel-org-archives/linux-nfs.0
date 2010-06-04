Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:15855 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409Ab0FDSKP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jun 2010 14:10:15 -0400
Date: Fri, 04 Jun 2010 14:09:44 -0400
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Benny Halevy" <bhalevy@panasas.com>
Subject: Resent: [pnfs][PATCH 0/3] pnfs-blocklayout client: adding support for complex volume structure
From: sfaibish <sfaibish@emc.com>
Cc: "Sorin Faibish" <sfaibish@emc.com>,
        "pnfs@linux-nfs.org" <pnfs@linux-nfs.org>
Content-Type: text/plain; format=flowed; delsp=yes; charset=iso-8859-15
Message-ID: <op.vdsfeiz2unckof@usensfaibisl2e.eng.emc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Apply against 2.6.34-rc3 pnfs branch. For pNFS client submission. Only  
touches
the block layout driver.

This patch set implements support for the complex volumes structures such  
as
stripe of multiple volumes in a single metavolume and slice of metavolumes  
into
smaller metavolumes. The patch set is specific to pnfs blocklayout and uses
simple rpc pipefs to generate messages that are passed to the userland  
which is
using an daemon to discover all the devices in the message. The userspace  
daemon
patches will be sent in a separate patch set.

The patch set replaces the current single volume implementation of the  
pnfs blocklayout
that has performance limitations and cannot support wide striped file  
systems.
The wide stripe is imperious to the performance scalability both for  
single and multiple
clients configurations. These patches address only the pnfs blocklayout  
client. Similar
patches will be implemented for the pnfsd block layout served in the  
second phase.

0001-pnfs-block-layout-add-simple-rpc-pipefs.patch
0002-pnfs-block-layout-remove-device-creation-or-remove-from-kernel.patch
0003-pnfs-block-layout-add-block-device-pipe-processing-based-on-simple-rpc.patch

Testing:
CONFIG_NFS_V4_1 set:

NFSv4.1/pNFS mounts:
Connectathon tests pass against Celerra/pNFS block layout server with both  
simple
volumes and complex volumes stripe on 4 volumes and using a slice of half  
of the
striped metavolume.

CONFIG_NFS_V4_1 not set:
NFSv4.0 mount passes Connectathon tests.

/Sorin

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

