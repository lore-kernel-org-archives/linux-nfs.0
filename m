Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay02.ispgateway.de ([80.67.31.40]:47628 "EHLO
	smtprelay02.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373AbbG1LZm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2015 07:25:42 -0400
Received: from [217.251.98.254] (helo=zarafa)
	by smtprelay02.ispgateway.de with esmtpsa (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.84)
	(envelope-from <sb@plzk.de>)
	id 1ZK2sp-0007VH-1T
	for linux-nfs@vger.kernel.org; Tue, 28 Jul 2015 13:17:19 +0200
Received: from srv1.localhost (localhost [IPv6:::1])
	by zarafa (Postfix) with ESMTP id 4EBF122030C
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2015 13:17:18 +0200 (CEST)
Subject: exporting single directory to many hosts - locking and concurrent
 writes a problem?
From: =?utf-8?Q?Stefan_Bauer?= <sb@plzk.de>
To: =?utf-8?Q?linux-nfs=40vger=2Ekernel=2Eorg?=
	<linux-nfs@vger.kernel.org>
Date: Tue, 28 Jul 2015 13:17:18 +0200
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Message-Id: <zarafa.55b764be.798b.51558f0c6ce3c9b0@srv1.localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm evaluating filesystems for concurrent access(rw) from different hosts and came across cluster file systems like GFS2 and OCFS2.
Is NFS in a way also able to deal with concurrent reads / writes ?

I have two hosts that need to share a single storage. Access to this storage can be concurrent and to the same files at the same time.

What are the limitations / advantages on NFS compared to cluster file systems?

NFS looks like a simple solution for this to me. Cluster file systems require locking and fencing with addiontional components. I want to keep it as simple as possible.

I would be happy to get your ideas and thoughts on this.

Thank you.

Kind regards,

Stefan
