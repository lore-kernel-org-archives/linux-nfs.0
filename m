Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:29814 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757935Ab2C1Kp1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2012 06:45:27 -0400
Date: Wed, 28 Mar 2012 13:45:19 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: jlayton@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: re: nfsd: add the infrastructure to handle the cld upcall
Message-ID: <20120328104518.GB29022@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Jeff Layton,

This is a semi-automatic email about new static checker warnings.

The patch f3f8014862d8: "nfsd: add the infrastructure to handle the 
cld upcall" from Mar 21, 2012, leads to the following Smatch 
complaint:

fs/nfsd/nfs4recover.c:605 cld_pipe_downcall()
	 error: we previously assumed 'cup' could be null (see line 604)

fs/nfsd/nfs4recover.c
   603		/* couldn't find upcall? */
   604		if (!cup) {
                    ^^^^
Check.

   605			dprintk("%s: couldn't find upcall -- xid=%u\n", __func__,
   606				cup->cu_msg.cm_xid);
                                ^^^^^
Dereference.

   607			return -EINVAL;

regards,
dan carpenter

