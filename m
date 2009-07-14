Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33945 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752537AbZGNRuF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2009 13:50:05 -0400
Date: Tue, 14 Jul 2009 13:48:28 -0400
From: Valerie Aurora <vaurora@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>, Jan Blunck <jblunck@suse.de>,
        Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Union mounts, NFS, and locking
Message-ID: <20090714174828.GE27582@shell>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

For now, the union mount developers are assuming that the bottom layer
of a union mount is read-only.  This avoids the directory
topology-related problems summarized in this thread:

http://lkml.org/lkml/2008/1/17/4

The problem is making a file system really really read-only and not
letting someone else come along and start sneakily modifying it
underneath us.  My superblock readonly users patch
(http://lkml.org/lkml/2009/7/13/243) fixes that for local file
systems, but I'm not sure how to handle NFS mounts as the bottom
layer.  The client can mount it read-only, but that puts no
restrictions on the server.  However, the kernel can already deal with
things unexpectedly moving/going away on an NFS mount - ESTALE - and
the dentry/inode/etc. won't suddenly disappear in the way they can
with local file systems.  Is this good enough for union mounts?  Or do
we need to get the NFS server to promise that the exported file system
is really really read-only too?

(Yes, this depends on the actual concrete union mount locking scheme,
but I'm more interested in whether it can or cannot be solved in
principle.)

-VAL
