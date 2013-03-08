Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:36989 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851Ab3CHTqH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Mar 2013 14:46:07 -0500
Received: by mail-ie0-f177.google.com with SMTP id 16so2566991iea.36
        for <linux-nfs@vger.kernel.org>; Fri, 08 Mar 2013 11:46:05 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/11] gssd clean-ups for nfs-utils
To: linux-nfs@vger.kernel.org
Date: Fri, 08 Mar 2013 14:46:03 -0500
Message-ID: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
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

This series implements both suggestions along with a number of
clean-ups I found while working on this code.

I had this series with me at Connectathon, and did some light
testing there.  I think they are ready for broader review and
comment.

---

Chuck Lever (11):
      gssd: Add "-c" command line option
      gssd: gethostname(3) returns zero or -1, not an errno
      gssd: Fix whitespace nits
      rpc.gssd: Clean up gssd_setup_krb5_user_gss_ccache()
      gssd: Update description of "-l" option
      gssd: Clarify use of the term "machine credentials" in rpc.gssd(8)
      gssd: Provide an introduction in gssd(8)
      gssd: gssd.man is missing a description of the "-M" option
      gssd: Use italics for option values and pathnames
      mountd: make local functions in v4root.c static
      mountd: remove unused variable


 utils/gssd/gssd.c      |   16 ++
 utils/gssd/gssd.h      |    1 
 utils/gssd/gssd.man    |  328 +++++++++++++++++++++++++++++++++++-------------
 utils/gssd/gssd_proc.c |   12 +-
 utils/gssd/krb5_util.c |   84 +++++++++++-
 utils/mountd/cache.c   |    2 
 utils/mountd/v4root.c  |    6 +
 7 files changed, 339 insertions(+), 110 deletions(-)

-- 
Chuck Lever
