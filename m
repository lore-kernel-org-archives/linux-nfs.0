Return-Path: linux-nfs-owner@vger.kernel.org
Received: from knm.org ([173.10.24.5]:45055 "EHLO knm.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932846Ab3BSXFe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2013 18:05:34 -0500
Received: from [192.168.20.65] (account mark@knm.org HELO shell)
  by knm.org (CommuniGate Pro SMTP 5.4.8 _community_)
  with ESMTPSA id 9040165 for linux-nfs@vger.kernel.org; Tue, 19 Feb 2013 16:05:14 -0700
Date: Tue, 19 Feb 2013 16:05:14 -0700 (MST)
From: Mark Lehrer <mark@tpsit.com>
To: linux-nfs@vger.kernel.org
Subject: RDMA, el6, kernel panic
Message-ID: <alpine.DEB.1.00.1302191536430.5816@shell>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I have an easily-reproduceable kernel panic with RDMA on el6,
kernel version 2.6.32-279.19.1.el6.x86_64

If a client has an NFS filesystem mounted via RDMA, and the Infiniband
connection goes away on the client without disconnecting from the NFS
server, the NFS server gives a kernel panic.

Is this a known problem, or should I email the panic output to this
list?  If it is an unknown problem, I will try on a more recent kernel
too.

Thanks,
Mark
