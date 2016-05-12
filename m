Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36141 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208AbcELXdl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 May 2016 19:33:41 -0400
Received: by mail-pf0-f172.google.com with SMTP id c189so36807036pfb.3
        for <linux-nfs@vger.kernel.org>; Thu, 12 May 2016 16:33:41 -0700 (PDT)
From: "Nathalie D'Amours" <nathalie.damours@gmail.com>
Content-Type: text/plain; charset=utf-8
Subject: pNFS problem: client writes go through MDS instead of going directly to DS
Date: Thu, 12 May 2016 16:33:39 -0700
Message-Id: <8AE03FE0-3F86-4B0D-AD80-D4720C56F4A4@gmail.com>
Cc: Frederic Carlson <frcarlson@gmail.com>
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I am using pNFS (blocklayout) to mount an XFS file system (on top of iSCSI) on a client. Everything works except that the write data goes through the MDS first instead of going directly to the DS.  I don’t know what I am doing wrong.  Any help or pointer would be very appreciated.

Here is the configuration:

host1: DS with one ISCSI target
host2: MDS: ISCSI initiator to target on host1, XFS built on the iSCSI device (initiator) and exported through NFS
host3: NFS client mounts the XFS file system using NFS 4.1.

I am using Fedora 23 (linux kernel 4.4.8) on all hosts.

NFS Server (host2):
------------------

$ journalctl --since "2016-05-12" -t iscsiadm
-- Logs begin at Wed 2016-05-04 19:17:25 UTC, end at Thu 2016-05-12 22:42:53 UTC. --
May 12 18:30:04 ip-172-31-28-138.us-west-2.compute.internal iscsiadm[851]: Logging in to [iface: default, target: iqn.2015-10.com.agylstor:logicalcard3, portal: 172.31.36.18,3260] (multiple)
May 12 18:30:04 ip-172-31-28-138.us-west-2.compute.internal iscsiadm[851]: Login to [iface: default, target: iqn.2015-10.com.agylstor:logicalcard3, portal: 172.31.36.18,3260] successful.
