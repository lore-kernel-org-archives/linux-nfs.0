Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:50976 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753157AbdF2Ne7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Jun 2017 09:34:59 -0400
From: Christoph Hellwig <hch@lst.de>
To: trond.myklebust@primarydata.com
Cc: jlayton@poochiereds.net, schumaker.anna@gmail.com,
        bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: open by handle support for NFS V2
Date: Thu, 29 Jun 2017 06:34:49 -0700
Message-Id: <20170629133453.19641-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

this resurrects parts of an old series to add open by handle support to
NFS.  The prime intent here is to support the actual open by handle
ioctls, although it will also allow very crude re-exporting.  Without
the other patches from Jeff's series that re-exporting will suck badly
though.

Changes since V1:
 - rebased on top of the nfs op constifycation (as merged in the nfsd tree)
