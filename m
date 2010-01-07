Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:61895 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752637Ab0AGQ20 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jan 2010 11:28:26 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] showmount bug fixes
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 07 Jan 2010 11:26:08 -0500
Message-ID: <20100107162421.27102.21422.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Steve-

As promised, a couple of bug fixes for the recent improvements to the
showmount command.

---

Chuck Lever (2):
      showmount: Use CLNT_CONTROL for version fallback
      showmount: Eliminate compiler warnings


 utils/showmount/showmount.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
