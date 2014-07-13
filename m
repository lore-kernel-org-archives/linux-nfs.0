Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53158 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753177AbaGMLAt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Jul 2014 07:00:49 -0400
Date: Sun, 13 Jul 2014 04:00:47 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: nfsd4_locku / nfs4_free_lock_stateid question
Message-ID: <20140713110047.GA28727@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,

while reviewing some of your patches I've started wondering about
some v4 locking code.

In nfsd4_locku we're doing a call to find_any_file to grab a file
structure for the lock stateid, which nfs4_free_lock_stateid tries to
close. But what guarantees that we're actually getting the same file
descriptor back?

The nfs4_file is shared by and stateid that access a given inode,
so the first call to find_any_file might return the read/only file
structure because that's the only one available so far, while
by the time we unlock we might have a read/write and/or write-only file
available as well, which find_any_file will return.

It seems like the lock stateid needs a pointer to the actual file
locked, and keep a reference to it independent of the nfs4_file, or am I
missing something?
