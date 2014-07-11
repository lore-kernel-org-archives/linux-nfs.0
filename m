Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33431 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755254AbaGKUHD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jul 2014 16:07:03 -0400
Date: Fri, 11 Jul 2014 16:07:01 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd bugfix for 3.16
Message-ID: <20140711200701.GA11931@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull another nfsd bugfix from

  git://linux-nfs.org/~bfields/linux.git for-3.16

Another xdr encoding regression that may cause incorrect encoding on
failures of certain readdirs.

--b.

----------------------------------------------------------------
Kinglong Mee (1):
      nfsd: Fix bad reserving space for encoding rdattr_error

 fs/nfsd/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
