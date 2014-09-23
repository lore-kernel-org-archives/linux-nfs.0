Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:26528 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753859AbaIWPfm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 11:35:42 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 0/1] NFSv4.1: Fix an NFSv4.1 state renewal regression
Date: Tue, 23 Sep 2014 11:35:35 -0400
Message-ID: <1411486536-23401-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Sigh. I did not format the patch with the last changes to the header comments.
Here is the updated header comments.

Andy Adamson (1):
  NFSv4.1: Fix an NFSv4.1 state renewal regression

 fs/nfs/nfs4proc.c | 2 --
 1 file changed, 2 deletions(-)

-- 
1.8.3.1

