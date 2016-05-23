Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47467 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751125AbcEWQoD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 May 2016 12:44:03 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3CAA7C064277
	for <linux-nfs@vger.kernel.org>; Mon, 23 May 2016 16:44:02 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (vpn-59-118.rdu2.redhat.com [10.10.59.118])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u4NGIT53012144
	for <linux-nfs@vger.kernel.org>; Mon, 23 May 2016 12:18:30 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [RFC PATCH 0/1] Create a DNS SRV record of the ID mapping domain
Date: Mon, 23 May 2016 12:18:26 -0400
Message-Id: <1464020307-8806-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a customer that requested the domain used
to do the ID mapping be available via DNS SVR 
record. I didn't think was that bad of an idea. 

IPA and FedFS use SRV records which seem to work out
pretty well. This patch is heavily based on the 
FedFS code. ;-) 

My only question is do we want libnfsidmap to be
dependent on the resolver library. There has been
some talk about moving libnfsidmap into nfs-utils
which means nfs-utils would be dependent the
resolver library. 

Note, this is not complete. If we are going to do
this I have to document it somehow, either in 
the man page or idmap.conf or both.

Just looking for thoughts... good/bad idea??

Steve Dickson (1):
  libnfsidmap: Query DNS for the NFSv4 ID domain

 configure.ac  |  1 +
 libnfsidmap.c | 89 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 89 insertions(+), 1 deletion(-)

-- 
2.5.0

