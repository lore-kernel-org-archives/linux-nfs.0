Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2489 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932557Ab1EFS5i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 May 2011 14:57:38 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 0/2] NFSD: add FREE_STATEID and TEST_STATEID operations
Date: Fri,  6 May 2011 14:57:33 -0400
Message-Id: <1304708255-20464-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

These patches add FREE_STATEID and TEST_STATEID to the NFS server.  I
appreciate any comments, so there might be a better way of doing things.

Thanks!

- Bryan
