Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38259 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752397AbaAZU7X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 26 Jan 2014 15:59:23 -0500
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1W7Wnb-00082x-45
	for linux-nfs@vger.kernel.org; Sun, 26 Jan 2014 15:59:23 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: delegation patches for 3.14
Date: Sun, 26 Jan 2014 15:59:18 -0500
Message-Id: <1390769961-30898-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches do a little minor cleanup and close a small race left
after the vfs delegation patches.

--b.

