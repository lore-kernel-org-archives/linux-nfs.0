Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43221 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932378Ab3DBOtr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 10:49:47 -0400
Date: Tue, 2 Apr 2013 10:49:46 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd bugfix for 3.9
Message-ID: <20130402144946.GC12158@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull another nfsd bugfix from the for-3.9 branch at

  git://linux-nfs.org/~bfields/linux.git for-3.9

(An xdr decoding error--thanks, Toralf Förster, and Trinity!)

--b.

----------------------------------------------------------------
J. Bruce Fields (1):
      nfsd4: reject "negative" acl lengths

 fs/nfsd/nfs4xdr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
