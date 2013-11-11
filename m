Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:48495 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752434Ab3KKXZL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Nov 2013 18:25:11 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Malahal Naineni <malahal@us.ibm.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Fix a data corruption issue when retransmitting
 RPC calls
Date: Mon, 11 Nov 2013 23:25:10 +0000
Message-ID: <1384212310.7614.29.camel@leira.trondhjem.org>
References: <1384021209-2586-1-git-send-email-Trond.Myklebust@netapp.com>
	 <20131111231541.GA31826@us.ibm.com>
In-Reply-To: <20131111231541.GA31826@us.ibm.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-11-11 at 17:15 -0600, Malahal Naineni wrote:
+AD4- Trond Myklebust +AFs-Trond.Myklebust+AEA-netapp.com+AF0- wrote:
+AD4- +AD4- +AEAAQA- -700,13 +-707,20 +AEAAQA- static int xs+AF8-tcp+AF8-send+AF8-request(struct rpc+AF8-task +ACo-task)
+AD4- +AD4-  	xs+AF8-pktdump(+ACI-packet data:+ACI-,
+AD4- +AD4-  				req-+AD4-rq+AF8-svec-+AD4-iov+AF8-base,
+AD4- +AD4-  				req-+AD4-rq+AF8-svec-+AD4-iov+AF8-len)+ADs-
+AD4- +AD4- +-	/+ACo- Don't use zero copy if this is a resend. If the RPC call
+AD4- +AD4- +-	 +ACo- completes while the socket holds a reference to the pages,
+AD4- +AD4- +-	 +ACo- then we may end up resending corrupted data.
+AD4- +AD4- +-	 +ACo-/
+AD4- +AD4- +-	if (task-+AD4-tk+AF8-flags +ACY- RPC+AF8-TASK+AF8-SENT)
+AD4- 
+AD4- How about RPC+AF8-WAS+AF8-SENT() ?

+ADw-shrug+AD4-that evaluates to the same+ADw-/shrug+AD4-

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
