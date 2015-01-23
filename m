Return-Path: linux-nfs-owner@vger.kernel.org
Received: from [198.137.202.9] ([198.137.202.9]:54660 "EHLO
	bombadil.infradead.org" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751849AbbAWIII (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jan 2015 03:08:08 -0500
Date: Fri, 23 Jan 2015 00:07:32 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v5 00/51] Add Flexfile Layout Module
Message-ID: <20150123080732.GA8687@infradead.org>
References: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series breaks xfstests with the first test when used together
with a local pnfs block export.

Steps to reproduce:

 (1) start a KVM VM with a second virtio-blk disk.
 (2) add /mnt/test/ to /etc/exports
 (2) configure xfstests with TEST_DIR=/mnt/nfs1 and
     TEST_DEV=127.0.0.1:/mnt/test

then run the following commands:

mkfs.xfs -f /dev/vdb
mount /dev/vdb /mnt/test

/etc/init.d/nfs-kernel-server restart

blkmapd
mount -t nfs 127.0.0.1:/mnt/test/ /mnt/nfs1 -o vers=4.1

cd xfstests
./check -nfs -g auto

I've also pushed out the trivially merged flexfiles+pnfsd branch
to git://git.infradead.org/users/hch/pnfs.git that also includes
a hack to force 4.1 and a revert for the commit that causes nfs to
deadlock for me all the time.
