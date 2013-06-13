Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e7.ny.us.ibm.com ([32.97.182.137]:58588 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758962Ab3FMSte (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Jun 2013 14:49:34 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Thu, 13 Jun 2013 14:49:33 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 1C82938C8045
	for <linux-nfs@vger.kernel.org>; Thu, 13 Jun 2013 14:49:30 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5DIlgli229668
	for <linux-nfs@vger.kernel.org>; Thu, 13 Jun 2013 14:47:43 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5DIlf8R026263
	for <linux-nfs@vger.kernel.org>; Thu, 13 Jun 2013 14:47:42 -0400
Date: Thu, 13 Jun 2013 13:47:37 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com
Subject: corruption due to loss of lock
Message-ID: <20130613184737.GA25713@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

I saw Bryan's patches here https://patchwork.kernel.org/patch/987402/
that fix issues after loss of a lock.  What is the status on this patch
set? Do they need more work? We have an application that uses range
locks on a file. Two threads from two different clients end up writing
to the same a file due to this bug after a lease expiry from a client.

Regards, Malahal.

