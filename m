Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:59351 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752999Ab0FQORb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jun 2010 10:17:31 -0400
Received: from localhost.localdomain (netapp-61.citi.umich.edu [141.212.112.250])
	by citi.umich.edu (Postfix) with ESMTP id 1165E1809C
	for <linux-nfs@vger.kernel.org>; Thu, 17 Jun 2010 10:17:31 -0400 (EDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/1] fix delay on mount and umount
Date: Wed, 16 Jun 2010 09:02:29 -0400
Message-Id: <1276693350-1780-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This fixes the delay issues we've been having.

