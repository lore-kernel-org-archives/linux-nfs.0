Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:38203 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752805AbYLaVHE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Dec 2008 16:07:04 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Two minor lockd clean-ups
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Wed, 31 Dec 2008 16:05:55 -0500
Message-ID: <20081231210449.4959.41094.stgit@ingres.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Bruce-

Here are two clean-up patches from the end of my NFSD for-2.6.29
series that are probably safe to include now.

---

Chuck Lever (2):
      NLM: Clean up flow of control in make_socks() function
      NLM: Refactor make_socks() function


 fs/lockd/svc.c |   49 ++++++++++++++++++++++++++++---------------------
 1 files changed, 28 insertions(+), 21 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
