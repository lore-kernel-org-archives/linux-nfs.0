Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6000 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753138Ab1AFLgh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Jan 2011 06:36:37 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 00/15] pnfs wave 2 submission
Date: Thu,  6 Jan 2011 06:36:17 -0500
Message-Id: <1294313792-14280-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Version 6 of the wave 2 submission.

changes from version 5:
- rebased onto Andy's v9 callback patches

These patches implement wave 2 of the pnfs submission, which
encompasses CB_LAYOUTRECALL and its serialization with LAYOUTGET,
as well as the "forgetful model" in which LAYOUTRETURNs are never
sent, but instead merely discarded by the client.

Fred

