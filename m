Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51119 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932392Ab2JBVt4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 17:49:56 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] NFSv4: fix corner cases with ACCESS in OPEN
Date: Tue,  2 Oct 2012 14:49:50 -0700
Message-Id: <1349214592-11717-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

My recent "ACCESS in OPEN" patch that fixed permissions due to OPEN operations
having no way to differentiate between READ and EXEC had several issues:

 - when files are opened O_EXCL, ACCESS will always return permission denied 
   for all bits until close is called.

 - POSIX allows processes to write to files without write permissions if
   that process created the file

