Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39893 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932688Ab1ERQoP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 May 2011 12:44:15 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1QMjr5-0004Tb-H7
	for linux-nfs@vger.kernel.org; Wed, 18 May 2011 12:44:15 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: pynfs server-side unlink test
Date: Wed, 18 May 2011 12:44:11 -0400
Message-Id: <1305737053-17096-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These are a couple patches to help me test some delegation changes; I'm
committing them to my pynfs repo for now.

--b.
