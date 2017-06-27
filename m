Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:47802 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751508AbdF0PoJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Jun 2017 11:44:09 -0400
From: Christoph Hellwig <hch@lst.de>
To: trond.myklebust@primarydata.com
Cc: jlayton@poochiereds.net, linux-nfs@vger.kernel.org
Subject: open by handle support for NFS
Date: Tue, 27 Jun 2017 08:43:59 -0700
Message-Id: <20170627154403.20944-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

this resurrects parts of an old series to add open by handle support to
NFS.  The prime intent here is to support the actual open by handle
ioctls, although it will also allow very crude re-exporting.  Without
the other patches from Jeff's series that re-exporting will suck badly
though.

