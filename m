From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/2] convert lockd to kthread API (try #9)
Date: Tue,  5 Feb 2008 14:37:55 -0500
Message-ID: <1202240277-24437-1-git-send-email-jlayton@redhat.com>
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35159 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754789AbYBETiD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Feb 2008 14:38:03 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the ninth iteration of the patchset to convert lockd to use the
kthread API. This patchset is smaller than the earlier ones since some
of the patches in those sets have already been taken into Bruce's tree.
This set only changes lockd to use the kthread API.

The patch here is pretty close to the most recent patchset, the main
differences are that this patchset tries to be very careful to make
sure that when lockd_down wants to take down lockd, that it exits as
soon as possible. In particular:

1) lockd_down now sends a signal to lockd to try to make sure that it
   doesn't block in recvmsg()

2) I've added a check for kthread_should_stop to nlmsvc_retry_blocked.
   If it returns true, nlmsvc_retry_blocked returns immediately.

I'd like to see this soak in Bruce's nfsd-2.6 git tree (and maybe -mm)
over the 2.6.25 development cycle and go in early when 2.6.26 opens.

Comments and suggestions appreciated...

Signed-off-by: Jeff Layton <jlayton@redhat.com>

