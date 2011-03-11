Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:43089 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072Ab1CKRCb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Mar 2011 12:02:31 -0500
Date: Fri, 11 Mar 2011 12:02:27 -0500
From: Jim Rees <rees@umich.edu>
To: =?utf-8?B?55m95p2+5p6X?= <09120171@bjtu.edu.cn>
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
Subject: Re: questions about blocklayoutdriver.ko
Message-ID: <20110311170227.GA3096@merit.edu>
References: <ZILUKLNGDVEJQIKOSYKLJUGEIUTK.09120171@bjtu.edu.cn>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <ZILUKLNGDVEJQIKOSYKLJUGEIUTK.09120171@bjtu.edu.cn>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

白松林 wrote:

  We tested the pNFS informance in the environment,and found that when
  client write data to /mnt,all of the data be sent to MDS firstly, and then
  MDS forwarded the data to DS,when we got the package by wireshark,and
  found most of the protocol between MDS and DS are NFS and TCP.

I suspect you don't actually have a pnfs mount.  Check/proc/self/mountstats
for pnfs=LAYOUT_BLOCK_VOLUME.  I recently added a troubleshooting section to
the pnfs block client how-to, maybe that will help.

http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup
