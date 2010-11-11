Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25689 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932117Ab0KKCLW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Nov 2010 21:11:22 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: iisaman@netapp.com, linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] Fix session draining and back channel processing 
Date: Thu, 11 Nov 2010 09:10:37 -0500
Message-Id: <1289484640-4100-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Currently the state manager only waits for the fore channel to drain.
The back channel processing must also be considered.
Have the state manager thread also wait for the any current back channel
processing to complete (drain).

Guarantee that the nfs_client exists during callback processing.

0001-pnfs-submit-set-back-channel-highest-slot-used.patch
0002-pnfs-submit-add-back-channel-draining.patch
0003-pnfs-submit-callbacks-cannot-use-an-nfs_client-that-.patch

-->Andy

