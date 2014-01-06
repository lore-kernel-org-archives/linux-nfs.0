Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:18375 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756291AbaAFV5Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jan 2014 16:57:16 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        <bfields@fieldses.org>
Subject: [PATCH 0/3] READ_PLUS rough draft
Date: Mon, 6 Jan 2014 16:57:10 -0500
Message-ID: <1389045433-22990-1-git-send-email-Anna.Schumaker@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches are my initial implementation of READ_PLUS.  I still have a
few issues to work out before they can be applied, but I wanted to submit
them anyway to get feedback before going much further.  These patches were
developed on top of my earlier SEEK and WRITE_PLUS patches, and probably
won't apply cleanly without them (I am willing to reorder things if necessary!).

On the server side, I handle the cases where a file is 100% hole, 100% data
or hole followed by data.  Any holes after a data segment will be expanded
to zeros on the wire.  This is due to a limitation in the the NFSD
encode-to-page function that will adjust pointers to point to the xdr tail
after reading a file to the "pages" section.  Bruce, do you have any
suggestions here?

The client side needs to punch holes after decoding page information, since
data on pages will be aligned at the start of the page array.  So a file that
is <HOLE><DATA> will store the hole information, decode the data, and then
punch the hole before returning.  I think it would be better to use the
provided offset field to decode everything to their final locations, but I'm
struggling to come up with a clean way of doing so using the code that is
already there.

Let me know what you all think!
Anna

Anna Schumaker (3):
  NFSD: Implement READ_PLUS support
  SUNRPC: This patch adds functions for shifting page data
  NFS: Client side changes for READ_PLUS

 fs/nfs/nfs4client.c        |   2 +-
 fs/nfs/nfs4proc.c          |  23 +++++-
 fs/nfs/nfs4xdr.c           | 191 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/Kconfig            |  14 ++++
 fs/nfsd/nfs4proc.c         |   9 +++
 fs/nfsd/nfs4xdr.c          | 177 ++++++++++++++++++++++++++++++++++++-----
 include/linux/nfs4.h       |   1 +
 include/linux/nfs_fs_sb.h  |   1 +
 include/linux/sunrpc/xdr.h |   1 +
 net/sunrpc/xdr.c           | 115 ++++++++++++++++++++++++++-
 10 files changed, 511 insertions(+), 23 deletions(-)

-- 
1.8.5.2

