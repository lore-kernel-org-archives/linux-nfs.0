Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:36708 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750737AbdBTGVm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Feb 2017 01:21:42 -0500
From: Christoph Hellwig <hch@lst.de>
To: bfields@redhat.com, jlayton@poochiereds.net
Cc: linux-nfs@vger.kernel.org
Subject: split setattr operations take 2
Date: Mon, 20 Feb 2017 07:21:32 +0100
Message-Id: <20170220062133.26607-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This just splits the setattr operations and doesn't try to use more
of the VFS infrastructure.

