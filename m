Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:36393 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753944AbbHXQl4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Aug 2015 12:41:56 -0400
Received: by qkda128 with SMTP id a128so25911441qkd.3
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2015 09:41:56 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Andrew W Elble <aweits@rit.edu>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/2] nfsd: fix unhashing races in nfsv4 stateid handling
Date: Mon, 24 Aug 2015 12:41:46 -0400
Message-Id: <1440434508-16046-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2:
- fix the fault injection code to handle the prototype change to
  unhash_lock_stateid

Slightly updated set, to fix a problem that Wu found when enabling the
nfsd fault injection code. Original cover-letter follows:

-------------------------[snip]-------------------

I hadn't heard from Andrew in a while so I'm not 100% clear on whether
his patches had fixed the race that he had spotted in the NFSv4
unhashing code.

Still, once he had done the analysis, the problem was clear. I think
this patchset should fix the problem in a relatively clean way. I've
run some tests against this and it seems to not have broken anything,
but I haven't been able to reproduce the actual race so I can't
verify that this fixes it.

Andrew, Anna, if you are able to do so could you test these patches
and let us know whether this fixes those races?

Jeff Layton (2):
  nfsd: ensure that the ol stateid hash reference is only put once
  nfsd: ensure that delegation stateid hash references are only put once

 fs/nfsd/nfs4state.c | 84 +++++++++++++++++++++++++++++++++--------------------
 1 file changed, 53 insertions(+), 31 deletions(-)

-- 
2.4.3

