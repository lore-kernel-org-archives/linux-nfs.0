Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59236 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757066AbcDGQ7q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Apr 2016 12:59:46 -0400
Date: Thu, 7 Apr 2016 12:59:41 -0400
To: Pete Black <pete@marchingcubes.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Status of PNFS/XFS Block Server
Message-ID: <20160407165941.GA30676@fieldses.org>
References: <261697B7-0C14-4CCF-AE34-A1E0B336C454@marchingcubes.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <261697B7-0C14-4CCF-AE34-A1E0B336C454@marchingcubes.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 03, 2016 at 11:57:36AM +1200, Pete Black wrote:
> Hi There,
> 
> Apologies if this is the wrong place to provide this feedback/ask this question.
> 
> I have been attempting to test out the PNFS block layout support, using NFS 4.1/pnfs, XFS filesystem and iSCSI.
> 
> I created 4 virtual machines (using Virtualbox, and internal networking) and configured them as follows:
> 
> All machines using Fedora 23 (4.4.6 kernel)
> 
> DS - 192.168.50.20  running iSCSI tgtd, exporting a file-backed LUN of 1GB in size. Obviously this is tiny, and useless for production purposes.
> 
> MDS - 192.168.50.10 running nfs-server, iscsid with the block device (/dev/sdb) available, and mounted on /mnt/xfs
> 
> mount options:
> /dev/sdb /mnt/xfs xfs _netdev 0 0
> 
> /etc/exports:
> /mnt/xfs 192.168.50.0/24(rw,pnfs)
> 
> NFS Client 1 - 192.168.50.50  running iscsid, block device available as /dev/sdb and mounting the nfs share
> /etc/fstab:
> 192.168.50.10:/mnt/xfs /mnt/pnfs_xfs nfs4 _netdev,v4.1 0 0
> 
> NFS Client 2 - 192.168.50.51 running iscsid, block device available as /dev/sdb and mounting the nfs share
> /etc/fstab:
> 192.168.50.10:/mnt/xfs /mnt/pnfs_xfs nfs4 _netdev,v4.1 0 0
> 
> 
> server kernel logs have 'XFS (sdb): using experimental pNFS feature, use at your own risk', nfsstat on the clients reflects LAYOUTGET traffic, and basic file IO works fine from both clients - I can open, read and write files to the xfs filessytem via nfs, and everything seems to be consistent and correct so broadly speaking everything is working as it should.
> 
> I am considering replicating this setup on real hardware and testing it for use in production, however I would like to know what, aside from a seeming lack of testing, is keeping this as experimental.

The block protocol itself has some inherent problems:

	- lack of a common fencing method, leading to the fencing-script
	  annoyance you've noted.
	- addressing only by signatures (bits of data stored on the
	  device itself), making device discovery inefficient (you have
	  to check every device for the signature) and unreliable (e.g.
	  a byte-for-byte copy of the data on another device will have
	  the same signature).

Christoph has addressed those with a new SCSI pNFS layout which should
work fine on your setup:

	http://marc.info/?l=linux-nfs&m=145712078417363

All you should need is a new kernel built with NFSD_SCSILAYOUT.  "New"
here means 4.6-rc1 or later, though.

Alternatively, as long as you're still in testing and not production,
you could ignore the fencing for now and continue with the block layout.
As long as you don't need fencing, the two layout types (block and scsi)
should work pretty much the same, so for example any performance results
you get in the block case will probably still apply.  And the same
hardware setup should work for both.

We'll be interested in hearing any results, positive or negative.

--b.

> 
> I would also like to ask for some clarification on the client fencing script - there is reference on the available documentation to the fact that the nfs server will call /sbin/nfsd-recall-failed when it needs to fence a client, but it is very unclear to me what this script is expected to actually do in practice  - i.e. the current 'example' script on:
> 
> http://git.linux-nfs.org/?p=bfields/linux.git;a=blob_plain;f=Documentation/filesystems/nfs/pnfs-block-server.txt
> 
>  seems to only place a log message in the MDS system log and nothing more - obviously it would be environment-specific, but is there anything else  such a script could or should be expected to do in a linux/iscsi environment such as my test rig?
> 
> 
> Thanks for any help you may be able to offer, and please let me know if there are better places to present these questions.
