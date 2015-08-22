Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:34591 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753364AbbHVOwY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Aug 2015 10:52:24 -0400
Received: by ykdt205 with SMTP id t205so97428447ykd.1
        for <linux-nfs@vger.kernel.org>; Sat, 22 Aug 2015 07:52:23 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Andrew W Elble <aweits@rit.edu>, linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] nfsd: fix unhashing races in nfsv4 stateid handling
Date: Sat, 22 Aug 2015 10:52:15 -0400
Message-Id: <1440255137-10642-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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

 fs/nfsd/nfs4state.c | 76 ++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 49 insertions(+), 27 deletions(-)

-- 
2.4.3

