Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:59924 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758808Ab0EVWEI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 22 May 2010 18:04:08 -0400
Received: by pvg4 with SMTP id 4so281591pvg.19
        for <linux-nfs@vger.kernel.org>; Sat, 22 May 2010 15:04:06 -0700 (PDT)
Message-ID: <4BF854D4.5090500@gmail.com>
Date: Sun, 23 May 2010 07:04:04 +0900
From: redshield88888 <redshield88888@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: How does the metadata-server synchronizes with data-servers ?
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, all.

I've succeeded to install pNFS-enabled kernel. But I wonder that how
does pNFS behaviour.
Especially, about synchronizations between the MetaDataServer and
DataServers.
I'd read a paper of the Calsoft's. This paper said like "There is
heartbeats betweenthe MetaDataServer and DataServers".
http://www.calsoftinc.com/download_pdf/White%20Papers%20-%20pnfs.pdf

When will this heartbeat be started ? The instruction below is not describe
about this, but the heartbeat will works, w'not this ?
http://wiki.linux-nfs.org/wiki/index.php/PNFS_Setup_Instructions

