Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34346 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753513Ab2EBVh7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 May 2012 17:37:59 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
        NeilBrown <neilb@suse.de>
Subject: use_ipaddr fixes
Date: Wed,  2 May 2012 17:37:50 -0400
Message-Id: <1335994675-11751-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A problem with the use_ipaddr case was found in testing.  I also noticed
a couple other bugs while I was there.

--b.

