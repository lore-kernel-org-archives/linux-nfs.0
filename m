From: "Smets, Jan (Jan)" <jan.smets@alcatel-lucent.com>
Subject: NFSv4.1 status
Date: Thu, 17 Jun 2010 03:05:15 +0200
Message-ID: <14C7F4F06DB5814AB0DE29716C4F6D670B6534E7@FRMRSSXCHMBSB1.dc-m.alcatel-lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smail6.alcatel.fr ([64.208.49.42]:33888 "EHLO smail6.alcatel.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752089Ab0FQBLo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jun 2010 21:11:44 -0400
Received: from FRMRSSXCHHUB02.dc-m.alcatel-lucent.com (FRMRSSXCHHUB02.dc-m.alcatel-lucent.com [135.120.45.62])
	by smail6.alcatel.fr (8.14.3/8.14.3/ICT) with ESMTP id o5H15HVG002509
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Jun 2010 03:05:17 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi list

I would like to know what status the NFS 4.1 (pNFS) development is in. 

Can it be tested? If yes, is there any guide what exactly I can do with it at this stage (and how) ? 
I already have the pnfs capable kernel, but it's unclear to me what userland tools I need (server side).

At the end I would like multiple dataservers that stripe data, and multiple metadata servers that also stripe data and all with failover/redundancy/load balancing stuff. But maybe I'm whishing for too much, yet.

Thanks

 - Jan










