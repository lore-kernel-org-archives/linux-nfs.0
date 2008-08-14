From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (157)
Date: Thu, 14 Aug 2008 17:24:21 +0200
Message-ID: <20080814152421.GA8056@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:55416 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751286AbYHNPeg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Aug 2008 11:34:36 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are not many reports of this but it seems related to stopping the
NFS server. I'm seeing them occasionally on system shutdown right after

	nfsd: last server has exited 
	nfsd: unexporting all filesystems 

kernels: 2.6.25, 2.6.26

-- 
Frank
