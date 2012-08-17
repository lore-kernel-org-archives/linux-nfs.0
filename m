Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:37900 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757338Ab2HQO1l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Aug 2012 10:27:41 -0400
Message-ID: <502E54D3.4010103@suse.com>
Date: Fri, 17 Aug 2012 19:57:31 +0530
From: Suresh Jayaraman <sjayaraman@suse.com>
MIME-Version: 1.0
To: Trond.Myklebust@netapp.com, chuck.lever@oracle.com
Cc: linux-nfs@vger.kernel.org
Subject: Slowing down state manager after unhandled error
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond and Chuck,

Recently, we have had a report on production SLES system where the
system's CPU utilization went very high due to the state manager
constantly sending huge number of requests every second due to an
unhandled error. The following patch from Chuck

  https://patchwork.kernel.org/patch/1185421/

mitigated this issue. Would be interested to know whether this patch
queued up already or you see any problem with the approach.


Thanks
Suresh
