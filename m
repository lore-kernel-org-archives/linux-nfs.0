Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:1483 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932503AbdJQQkw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Oct 2017 12:40:52 -0400
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [RFC PATCH 0/2] race of lockd/nfsd inetaddr notifiers with pointers
 change
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Message-ID: <24d4e50e-80f7-1874-6745-511f9e7b5739@virtuozzo.com>
Date: Tue, 17 Oct 2017 19:40:48 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

lockd and nfsd inet[6]addr notifiers use pointer that can be changed during execution.

lockd_inet[6]addr_event use nlmsvc_rqst without taken nlmsvc_mutex,
nfsd notifier have similar trouble.

We got few crashes from OpenVz customers on RHEL6-based kernel,
and I have reproduced the problem locally on this kernel.

I was unable to reproduce the problem on new kernels,
however seems they are affected.

We cannot add mutexes into notifiers because inet6addr notifiers should be atomic.

To fix the problem I use atomic counter and waitqueue:
counter allows notifier to access the pointer,
waitqueue allows to delay stop of service until notifier is in use.

Patches was not tested because I was unable to reproduce the problem on new kernels. 

Please review it carefully and let me know if this can be fixed in a better way.

Vasily Averin (2):
  race of lockd inetaddr notifiers with nlmsvc_rqst change
  race of nfsd inetaddr notifiers with nn->nfsd_serv change

 fs/lockd/svc.c   | 16 ++++++++++++++--
 fs/nfsd/netns.h  |  3 +++
 fs/nfsd/nfsctl.c |  3 +++
 fs/nfsd/nfssvc.c | 14 +++++++++++---
 4 files changed, 31 insertions(+), 5 deletions(-)

-- 
2.7.4

