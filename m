Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60625 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755697Ab2EWVkl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 May 2012 17:40:41 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1SXJIO-00046y-RN
	for linux-nfs@vger.kernel.org; Wed, 23 May 2012 17:40:40 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: mainly setclientid/confirm cleanup
Date: Wed, 23 May 2012 17:40:30 -0400
Message-Id: <1337809240-15770-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While working on some locking fixes I ran into trouble understanding the
setclientid and setclientid_confirm code.  So, here's some cleanup and
minor bugfixes.

The result is a lot simpler.

--b.
