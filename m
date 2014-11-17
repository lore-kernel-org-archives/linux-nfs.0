Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:50933 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445AbaKQScW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2014 13:32:22 -0500
Received: by mail-qc0-f174.google.com with SMTP id c9so5764717qcz.19
        for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2014 10:32:22 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: chuck.lever@oracle.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC 0/2] nfsdcltrack: don't use libsqlite3 functions that are too new
Date: Mon, 17 Nov 2014 13:32:13 -0500
Message-Id: <1416249135-18736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck was having a problem building nfsdcltrack on a RHEL6 era box, due
to the fact that the libsqlite3 library there was too old. While we
could play games with autoconf, it's just easier to use older library
functions in these places so that we don't have to.

Jeff Layton (2):
  nfsdcltrack: use sqlite3_close instead of sqlite3_close_v2
  nfsdcltrack: use sqlite3_errmsg instead of sqlite3_errstr

 utils/nfsdcltrack/sqlite.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

-- 
2.1.0

