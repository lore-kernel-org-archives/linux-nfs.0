Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:37438 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758168Ab1BKWRv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Feb 2011 17:17:51 -0500
Received: from hop04-l1d11-si02.isus.emc.com (HOP04-L1D11-SI02.isus.emc.com [10.254.111.55])
	by mexforward.lss.emc.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p1BMHoQS008033
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 11 Feb 2011 17:17:50 -0500
Received: from mailhub.lss.emc.com (mailhub.lss.emc.com [10.254.221.253]) by hop04-l1d11-si02.isus.emc.com (RSA Interceptor) for <linux-nfs@vger.kernel.org>; Fri, 11 Feb 2011 17:17:42 -0500
Received: from mxhub21.corp.emc.com (mxhub21.corp.emc.com [128.221.56.107])
	by mailhub.lss.emc.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p1BMG0Hj011430
	for <linux-nfs@vger.kernel.org>; Fri, 11 Feb 2011 17:16:00 -0500
From: <Daniel.Muntz@emc.com>
To: <linux-nfs@vger.kernel.org>
Date: Fri, 11 Feb 2011 17:15:58 -0500
Subject: pNFS files server?
Message-ID: <DE966DA98A4ABE438D726BDF1699CF61043FE56802@MX05A.corp.emc.com>
References: <1297443279-19813-1-git-send-email-iisaman@netapp.com>
 <1297443279-19813-8-git-send-email-iisaman@netapp.com>
In-Reply-To: <1297443279-19813-8-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Is anyone still working on a freely-available pNFS files server for Linux?  I've had a couple of inquiries recently about spNFS, and would like to be able to point people to recent work.  Last I knew, Andy's GFS2-based pnfs files server work was the POR for delivering a server.  Is that work still going on, and if so, is there usable code I can point to?

  Thanks,
  Dan