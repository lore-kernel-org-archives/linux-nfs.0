Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:40733 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbbKZSzg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Nov 2015 13:55:36 -0500
From: Christoph Hellwig <hch@lst.de>
To: viro@zeniv.linux.org.uk
Cc: tao.peng@primarydata.com, jeff.layton@primarydata.com,
        linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org
Subject: vfs: move btrfs clone ioctls to common code
Date: Thu, 26 Nov 2015 19:50:54 +0100
Message-Id: <1448563859-21922-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set moves the existing btrfs clone ioctls that other file
system have started to implement to common code, and allows the NFS
server to export this functionality to remote systems.

This work is based originally on my NFS CLONE prototype, which reused
code from Anna Schumaker's NFS COPY prototype, as well as various
updates from Peng Tao to this code.

The patches are also available as a git branch and on gitweb:

	git://git.infradead.org/users/hch/pnfs.git clone-for-viro
	http://git.infradead.org/users/hch/pnfs.git/shortlog/refs/heads/clone-for-viro

