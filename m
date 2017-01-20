Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:38063 "EHLO
        smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752266AbdATRab (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jan 2017 12:30:31 -0500
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Chuck Lever'" <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
References: <20170113173023.32692.30661.stgit@manet.1015granger.net>
In-Reply-To: <20170113173023.32692.30661.stgit@manet.1015granger.net>
Subject: RE: [PATCH v1 0/5] Fix "support large inline thresholds"
Date: Fri, 20 Jan 2017 11:30:37 -0600
Message-ID: <021301d27342$e9f59fb0$bde0df10$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> 
> I've received a number of reports that v4.9 commit 655fec6987be
> ("xprtrdma: Use gathered Send for large inline messages") causes
> NFS/RDMA mounts to fail for devices that have a small max_sge.
> 
> This series addresses that problem.
> 
> A much smaller fix was provided initially. It worked for devices
> with as small as five send SGEs. However, additional research has
> shown that there is at least one in-tree device that supports only
> three send SGEs.
> 
> The current series should enable NFS/RDMA again on those devices.
> 
> 
> Available in the "nfs-rdma-for-4.10-rc" topic branch of this git repo:
> 
> git://git.linux-nfs.org/projects/cel/cel-2.6.git

Hey Chuck,

Tests ok on cxgb4.

Tested-by: Steve Wise <swise@opengridcomputing.com>

