Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:39422 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726834AbeHJXPs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Aug 2018 19:15:48 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 72695818F6E1
        for <linux-nfs@vger.kernel.org>; Fri, 10 Aug 2018 20:44:21 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH 0/2] A few fixes to rpc.nfsd enabling/disabling minor version 0
Date: Fri, 10 Aug 2018 16:44:19 -0400
Message-Id: <20180810204421.21882-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The first patch allows version 4.0 to be enabled/disabled via the
nfs.conf file.

The second patch adds a variable to track when the user explicitly
requested version 4.0 to be enabled/disabled so that '+4.0' or '-4.0'
can be written to /proc/fs/nfsd/versions on 4.11 (first appearance of
commit d3635ff07e8c "nfsd: fix configuration of supported minor
versions").

Note that if version 4.0 is disabled (either via '-N4.0' on the command
line or via 'vers4.0=n' in nfs.conf), then it must be re-enabled
explicitly (either via '-V4.0' on the command line or via 'vers4.0=y' in
nfs.conf).  Simply removing the '-N4.0'/'vers4.0=n' options and/or
replacing them with '-V4/vers4=y' is not sufficient.  It is my
understanding that that is the desired behavior.

Scott Mayhew (2):
  nfsd: allow verson 4.0 to be enabled/disabled via nfs.conf
  nfsd: track when the user explicitly requested version 4.0

 utils/nfsd/nfsd.c   | 17 +++++++++++------
 utils/nfsd/nfssvc.c | 14 +++++++++-----
 utils/nfsd/nfssvc.h |  3 ++-
 3 files changed, 22 insertions(+), 12 deletions(-)

-- 
2.14.4
