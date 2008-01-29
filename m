From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/2] fixes for 2.6.25
Date: Tue, 29 Jan 2008 10:30:53 -0500
Message-ID: <1201620655-7595-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58438 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755327AbYA2Pa6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jan 2008 10:30:58 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,
  Here are the two patches that I think are reasonable for 2.6.25. I
think it's probably best that we continue working on lockd over the
2.6.25 development cycle and target the conversion to kthread API
for 2.6.26.

Signed-off-by: Jeff Layton <jlayton@redhat.com>


