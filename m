From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/1 v2] nfs: use compound hdr.status to override op status.
Date: Fri,  9 May 2008 15:21:39 -0700
Message-ID: <1210371699-8741-1-git-send-email-bhalevy@panasas.com>
References: <47F20334.7040208@panasas.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from streamline134.sjccnet.com ([207.87.51.134]:60125 "EHLO
	lt.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751919AbYEJGpp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 10 May 2008 02:45:45 -0400
In-Reply-To: <47F20334.7040208@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


