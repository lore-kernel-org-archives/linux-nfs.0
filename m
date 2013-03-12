Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:39625 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932514Ab3CLUg3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Mar 2013 16:36:29 -0400
Received: by mail-ie0-f179.google.com with SMTP id k11so413165iea.10
        for <linux-nfs@vger.kernel.org>; Tue, 12 Mar 2013 13:36:28 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 00/10] gssd clean-ups for nfs-utils
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 12 Mar 2013 16:36:26 -0400
Message-ID: <20130312203105.2478.88903.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've been working on several fixes and clean-ups in response to an
issue reported by Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>.
The thread is archived here:

 http://www.spinics.net/lists/linux-nfs/msg35306.html

There were two suggestions in that thread:

 1.  Clarify rpc.gssd(8)

 2.  Implement a gssd option to name a credential file where
     machine credentials can be found

This series implements the first suggestion along with a number of
clean-ups I found while working on this code.  The second suggestion
has been dropped for the moment.
      
I had this series with me at Connectathon, and did some light
testing there.  This series is ready to be merged into
nfs-utils.

Changes since v1:

  o  Acks from Bruce
  o  Restored part of the comment documenting
     gssd_find_existing_krb5_ccache()
  o  Dropped the patch adding the "-c" option to rpc.gssd.
     This issue will be revisited soon.

---

Chuck Lever (10):
      gssd: gethostname(3) returns zero or -1, not an errno
      gssd: Fix whitespace nits
      gssd: Clean up gssd_setup_krb5_user_gss_ccache()
      gssd: Update description of "-l" option
      gssd: Clarify use of the term "machine credentials" in rpc.gssd(8)
      gssd: Provide an introduction in gssd(8)
      gssd: gssd.man is missing a description of the "-M" option
      gssd: Use italics for option values and pathnames
      mountd: make local functions in v4root.c static
      mountd: remove unused variable


 utils/gssd/gssd.c      |    2 
 utils/gssd/gssd.man    |  310 +++++++++++++++++++++++++++++++++++-------------
 utils/gssd/gssd_proc.c |   12 +-
 utils/gssd/krb5_util.c |   20 ++-
 utils/mountd/cache.c   |    2 
 utils/mountd/v4root.c  |    6 +
 6 files changed, 244 insertions(+), 108 deletions(-)

-- 
Chuck Lever
