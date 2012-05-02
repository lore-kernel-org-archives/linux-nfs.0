Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45495 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753866Ab2EBV4S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 May 2012 17:56:18 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
        NeilBrown <neilb@suse.de>
Subject: use_ipaddr fixes version surely-that's-enough
Date: Wed,  2 May 2012 17:56:10 -0400
Message-Id: <1335995775-12009-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This time with a minor patch-generating problem fixed (end result is the
same, but this time the result compiles halfway through).

--b.

