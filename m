Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61441 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752702Ab1GVITI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jul 2011 04:19:08 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p6M8J8A3021037
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 22 Jul 2011 04:19:08 -0400
Content-Type: text/plain; charset=us-ascii
Message-ID: <20009.12921.103429.724673@regina.usersys.redhat.com>
Date: Fri, 22 Jul 2011 18:19:05 +1000
From: Max Matveev <makc@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] RDMA: Increasing RPCRDMA_MAX_DATA_SEGS
In-Reply-To: <1311270542-2021-1-git-send-email-steved@redhat.com>
References: <1311270542-2021-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 21 Jul 2011 13:49:02 -0400, Steve Dickson wrote:

 steved> Our performance team has noticed that increasing
 steved> RPCRDMA_MAX_DATA_SEGS from 8 to 64 significantly
 steved> increases throughput when using the RDMA transport.

Did they try new client with old server and vice versa?
Both read and write?

max

