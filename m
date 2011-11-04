Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45380 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752451Ab1KDIDp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 04:03:45 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pA483jJi016127
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 4 Nov 2011 04:03:45 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Message-ID: <20147.40030.333964.631999@regina.usersys.redhat.com>
Date: Fri, 4 Nov 2011 19:03:42 +1100
From: Max Matveev <makc@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] RDMA: RPCRDMA_MAX_DATA_SEGS cause i686 stack to blow.
In-Reply-To: <1320346359-1515-1-git-send-email-steved@redhat.com>
References: <1320346359-1515-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu,  3 Nov 2011 14:52:38 -0400, Steve Dickson wrote:

 steved> Commit 2773395b3 increased RPCRDMA_MAX_DATA_SEGS from 8
 steved> to 64 which significantly increases throughput with the
 steved> RDMA transport.

 steved> Unfortunately making RPCRDMA_MAX_DATA_SEGS that large blows
 steved> the stack on i686 builds during compilation. So the
 steved> RPCRDMA_MAX_PHYSREG_DATA_SEGS is used to allocated data on
 steved> the stack.

How is it supposed to work if you "advertise" 256K r/wsize (64 * 4k)
but only post enough buffers to deal with 64K worth of data?

max

