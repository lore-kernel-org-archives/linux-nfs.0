Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e33.co.us.ibm.com ([32.97.110.151]:44811 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904Ab2EGRxg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2012 13:53:36 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 7 May 2012 11:53:34 -0600
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 7BB71C9005E
	for <linux-nfs@vger.kernel.org>; Mon,  7 May 2012 13:52:25 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q47HqRMM119898
	for <linux-nfs@vger.kernel.org>; Mon, 7 May 2012 13:52:27 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q47HqRlU005510
	for <linux-nfs@vger.kernel.org>; Mon, 7 May 2012 14:52:27 -0300
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q47HqQeP005499
	for <linux-nfs@vger.kernel.org>; Mon, 7 May 2012 14:52:26 -0300
Date: Mon, 7 May 2012 12:52:25 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: short read from NFS client
Message-ID: <20120507175225.GA15419@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All,

	An application running on an NFS file got short read (received
fewer bytes than requested). At the same time, we noticed few ESTALE
errors for NFS READ Calls in the tcpdump. We lost few packets in the
tcpdump, so can't say if there were any other errors at that time. What
are the circumstances (other than the ones listed below) where NFS
client can send a short read to the application in buffered read system
call?

EOF is not reached, no direct I/O is involved, and the read syscall is not
interrupted, of course!

Thanks, Malahal.

