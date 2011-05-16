Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48092 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753205Ab1EPTnp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 May 2011 15:43:45 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v2 0/2] NFSD: add FREE_STATEID and TEST_STATEID operations
Date: Mon, 16 May 2011 15:43:39 -0400
Message-Id: <1305575021-2841-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

These patches add FREE_STATEID and TEST_STATEID to the NFS server.  I
appreciate any comments, especially if there is a better way of doing things.

v2:
- FREE_STATEID
  - Free open, lock, and delegation state ids correctly
  - Use the check_for_locks() function to check for locks

- TEST_STATEID
  - Remove openmode check
  - Sanity check on size of stateid list
  - Delay decoding stateid list until encoding the reply

Thanks!

- Bryan
