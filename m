Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:57430 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753472Ab3DSSwa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Apr 2013 14:52:30 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com, bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] 64bit time fixes
Date: Fri, 19 Apr 2013 14:52:25 -0400
Message-Id: <1366397547-14639-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>


xfstests generic/258 attempts to set atime of a file to a value before the
unix epoch by running touch -t 196001010101.  I found that both the client
and the server were zero-filling the first 32bits rather than sending the
correct 64bit time value during a setattr.  These patches fix this on both
the client and the server.

Questions?  Comments?

- Bryan

Bryan Schumaker (2):
  nfs: Send atime and mtime as a 64bit value
  nfsd: Decode and send 64bit time values

 fs/nfs/nfs4xdr.c  |  6 ++----
 fs/nfsd/nfs4xdr.c | 19 +++++--------------
 2 files changed, 7 insertions(+), 18 deletions(-)

-- 
1.8.2.1

