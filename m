From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/5] Convert knfsd to kthread API and fix startup/shutdown races (try #4)
Date: Tue, 10 Jun 2008 08:40:34 -0400
Message-ID: <1213101639-26423-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, neilb@suse.de,
	gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35240 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753022AbYFJMkx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2008 08:40:53 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset is the fourth attempt to change nfsd to the kthread API.
The main changes from the last patchset deal with module reference
counts. Earlier patchsets either had ignored the module reference count
for nfsd, or had attempted to do the module refcounting in the nfsd
module itself.

Ignoring them won't work. nfsd is started from userspace, so we need to
have the nfsd threads keep an explicit reference to the module. Also, we
need to have the function that actually starts each thread take the
reference. Trying to do it within the context of the thread itself would
be racy.

I think this should fix the last of the issues identified, but comments
and suggestions are welcome.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

