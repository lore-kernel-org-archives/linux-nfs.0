Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e8.ny.us.ibm.com ([32.97.182.138]:46497 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754333Ab2GXQiY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jul 2012 12:38:24 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Tue, 24 Jul 2012 12:38:01 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 3A57738C911F
	for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2012 11:53:18 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6OFrHUN267234
	for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2012 11:53:17 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6OFr7iW014003
	for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2012 11:53:08 -0400
Received: from malahal (malahal.austin.ibm.com [9.41.105.170])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q6OFr5rw013860
	for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2012 11:53:05 -0400
Date: Tue, 24 Jul 2012 10:53:04 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: Re: 2 NFS server for the same mount point ?
Message-ID: <20120724155304.GA9721@us.ibm.com>
References: <500EBB69.5000205@physics.umanitoba.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <500EBB69.5000205@physics.umanitoba.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Maiko Langelaar [maiko@physics.umanitoba.ca] wrote:
> I want to move the original mount points over to Server B !
> 
> Question : Can I export the SAME mount points on 2 NFS servers
> for the same subnet ? I figure yes, because any particular NFS
> client will *target* a particular server. BUT the RPC nature of
> the NFS protocol makes me a bit nervous about doing so.

Yes, you can.

