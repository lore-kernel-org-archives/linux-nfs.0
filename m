From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/3] have pooled sunrpc services make more intelligent
	allocations
Date: Tue, 03 Jun 2008 07:16:09 -0400
Message-ID: <20080603110549.8631.46647.stgit@dantu.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46155 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751999AbYFCLQ1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Jun 2008 07:16:27 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The sunrpc code has had some support for spreading pooled services over
different NUMA nodes and CPUs for some time. So far though, this support
has been for CPU masks only. Memory allocated for these services is
generally done by whatever CPU happens to be running the init script
that starts the services and so most of it ends up on the same NUMA node.
This means that nfsd's end up wasting a lot of time updating remote
memory on a different memory node.

This patchset attempts to remedy that by having pooled services make
per-thread allocations that are on their local memory node. I have no
hard performance numbers for this particular patchset, but Greg Banks
sent me a different patch that has a similar effect and claims that
there is a significant performance gain.

Comments and suggestions appreciated...

Signed-off-by: Jeff Layton <jlayton@redhat.com>
