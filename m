Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18993 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755998Ab1AaP1e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Jan 2011 10:27:34 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/3]: pnfs: fix pnfs lock inversion
Date: Mon, 31 Jan 2011 10:27:10 -0500
Message-Id: <1296487633-21057-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These fix the incorrect lock order used throughout the pnfs code.  We
first simplify the logic (and in the proces squash a few bugs), then
rearrange the code so we never have to take both i_lock and cl_lock
simultaneously.

They apply to Trond's linux-next branch.

Fred

