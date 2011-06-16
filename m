Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:55842 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698Ab1FPQX0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2011 12:23:26 -0400
Message-Id: <cover.1308241259.git.rees@umich.edu>
Subject: [PATCH 0/2] minor patches to cthon tests for gcc 4.0
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Thu, 16 Jun 2011 12:23:23 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

First patch adds some generated files to .gitignore.  Second removes
-fwritable-strings from the COPTS for gcc 4.0.

Jim Rees (2):
  add generated .c files to .gitignore
  remove -fwritable-strings for gcc 4.0

 .gitignore |    3 +++
 tests.init |    7 +++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

-- 
1.7.4.1

