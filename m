Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39922 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbbLCMEf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Dec 2015 07:04:35 -0500
From: Christoph Hellwig <hch@lst.de>
To: viro@zeniv.linux.org.uk
Cc: tao.peng@primarydata.com, jeff.layton@primarydata.com,
        bfields@fieldses.org, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: move btrfs clone ioctls to common code V2
Date: Thu,  3 Dec 2015 12:59:48 +0100
Message-Id: <1449143992-7415-1-git-send-email-hch@lst.de>
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


Changes since V1:
 - change the locks_mandatory_area calling convention again
 - support clones on CIFS properly
 - rebase on top of the NFS clone updates in 4.4-rc3

