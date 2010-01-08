Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47877 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751505Ab0AHUXV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jan 2010 15:23:21 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs41: implement cb_recall_slot 
Date: Fri,  8 Jan 2010 15:23:02 -0500
Message-Id: <1262982183-2412-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This patch applies on 2.6.33-rc3 Tronds nfs-for-next tree, on top of the last
patch series I sent.

[last patch series]
0001-nfs41-fix-wrong-error-on-callback-decode-hdr-overflo.patch
0002-nfs41-directly-encode-back-channel-error.patch
0003-nfs41-remove-uneeded-checks-in-callback-processing.patch
0004-nfs41-prepare-for-back-channel-drc.patch
0005-nfs41-back-channel-drc-minimal-implementation.patch


0006-nfs41-implement-cb_recall_slot.patch
The fore channel session is drained, then the new highest_slot is set.

Tested with a new pyNFS server CB_RECALL_SLOT call and the Connectathon basic
big file test which uses all available slots. 

-->Andy

