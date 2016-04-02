Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elhefe.marchingcubes.com ([173.255.211.175]:57984 "EHLO
	mx.marchingcubes.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750819AbcDCAG6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Apr 2016 20:06:58 -0400
Received: from mx.marchingcubes.net (localhost [127.0.0.1])
	by mx.marchingcubes.net (Postfix) with ESMTP id 164A71C6E8
	for <linux-nfs@vger.kernel.org>; Sat,  2 Apr 2016 23:57:40 +0000 (UTC)
Received: from [192.168.1.55] (172.100.69.111.dynamic.snap.net.nz [111.69.100.172])
	by mx.marchingcubes.net (Postfix) with ESMTPSA id 289D91C6D9
	for <linux-nfs@vger.kernel.org>; Sat,  2 Apr 2016 23:57:38 +0000 (UTC)
From: Pete Black <pete@marchingcubes.com>
Content-Type: text/plain; charset=us-ascii
Subject: Status of PNFS/XFS Block Server
Message-Id: <261697B7-0C14-4CCF-AE34-A1E0B336C454@marchingcubes.com>
Date: Sun, 3 Apr 2016 11:57:36 +1200
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi There,

Apologies if this is the wrong place to provide this feedback/ask this question.

I have been attempting to test out the PNFS block layout support, using NFS 4.1/pnfs, XFS filesystem and iSCSI.

I created 4 virtual machines (using Virtualbox, and internal networking) and configured them as follows:

All machines using Fedora 23 (4.4.6 kernel)

DS - 192.168.50.20  running iSCSI tgtd, exporting a file-backed LUN of 1GB in size. Obviously this is tiny, and useless for production purposes.

MDS - 192.168.50.10 running nfs-server, iscsid with the block device (/dev/sdb) available, and mounted on /mnt/xfs

mount options:
/dev/sdb /mnt/xfs xfs _netdev 0 0

/etc/exports:
/mnt/xfs 192.168.50.0/24(rw,pnfs)

NFS Client 1 - 192.168.50.50  running iscsid, block device available as /dev/sdb and mounting the nfs share
/etc/fstab:
192.168.50.10:/mnt/xfs /mnt/pnfs_xfs nfs4 _netdev,v4.1 0 0

NFS Client 2 - 192.168.50.51 running iscsid, block device available as /dev/sdb and mounting the nfs share
/etc/fstab:
192.168.50.10:/mnt/xfs /mnt/pnfs_xfs nfs4 _netdev,v4.1 0 0


server kernel logs have 'XFS (sdb): using experimental pNFS feature, use at your own risk', nfsstat on the clients reflects LAYOUTGET traffic, and basic file IO works fine from both clients - I can open, read and write files to the xfs filessytem via nfs, and everything seems to be consistent and correct so broadly speaking everything is working as it should.

I am considering replicating this setup on real hardware and testing it for use in production, however I would like to know what, aside from a seeming lack of testing, is keeping this as experimental.

I would also like to ask for some clarification on the client fencing script - there is reference on the available documentation to the fact that the nfs server will call /sbin/nfsd-recall-failed when it needs to fence a client, but it is very unclear to me what this script is expected to actually do in practice  - i.e. the current 'example' script on:

http://git.linux-nfs.org/?p=bfields/linux.git;a=blob_plain;f=Documentation/filesystems/nfs/pnfs-block-server.txt

 seems to only place a log message in the MDS system log and nothing more - obviously it would be environment-specific, but is there anything else  such a script could or should be expected to do in a linux/iscsi environment such as my test rig?


Thanks for any help you may be able to offer, and please let me know if there are better places to present these questions.


-Pete










