Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251]:39988 "EHLO
	moving-picture.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755660Ab1EQQkD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 May 2011 12:40:03 -0400
Received: from cassini.mpc.local ([172.16.15.37] helo=moving-picture.com)
	by moving-picture.com with esmtp (Exim 4.43)
	id 1QMN1Q-0000Wa-Hl
	for linux-nfs@vger.kernel.org; Tue, 17 May 2011 17:21:24 +0100
Message-ID: <4DD2A084.1040905@moving-picture.com>
Date: Tue, 17 May 2011 17:21:24 +0100
From: James Pearson <james-p@moving-picture.com>
To: linux-nfs@vger.kernel.org
Subject: How to control the order of different export options for different
 client formats?
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'm using CentOS 5.x (nfs-utils based on v1.0.9) - and have been using 
the following in /etc/exports:

/export *(rw,async) @backup(rw,no_root_squash,async)

which works fine - hosts in the backup NIS netgroup mount the file 
system with no_root_squash and other clients with root_squash

However, I now want to restrict the export to all clients in a single 
subnet - so I now have /etc/exports as:

/export 172.16.0.0/20(rw,async) @backup(rw,no_root_squash,async)

Unfortunately, hosts in the backup NIS netgroup (which are also in the 
172.16.0.0/20 subnet) no longer mount with no_root_squash

It appears that the subnet export takes precedence over the netgroup 
export (it doesn't matter in what order the subnets/netgroups exports 
are listed in /etc/exports) - so the netgroup client options are ignored 
as a match has already been found in the subnet export.

Is there any way to control the order in which clients are checked for 
export options?

i.e. I would like netgroups to take precedence over subnets

Thanks

James Pearson
