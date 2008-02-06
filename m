From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/2] convert lockd to kthread API (try #10)
Date: Wed,  6 Feb 2008 13:21:41 -0500
Message-ID: <1202322103-13716-1-git-send-email-jlayton@redhat.com>
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60949 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754561AbYBFSVq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 13:21:46 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the tenth iteration of the patchset to convert lockd to use the
kthread API. This patchset is smaller than the earlier ones since some
of the patches in those sets have already been taken into Bruce's tree.
This set only changes lockd to use the kthread API.

The only real difference between this patchset and the one posted
yesterday is some added comments to clarify the possible race involved
when signaling and calling kthread_stop.

Bruce, would you be willing to take this into your git tree once 2.6.25
development settles down? I'd like to have this considered for 2.6.26.

Thanks,

Signed-off-by: Jeff Layton <jlayton@redhat.com>

