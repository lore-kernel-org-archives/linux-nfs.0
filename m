From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: svc_create_xprt for nfsd and lockd with ipv6
Date: Mon, 26 May 2008 11:47:54 +0200
Message-ID: <483A874A.5080502@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-nfs@vger.kernel.org
To: nfsv4 <nfsv4@linux-nfs.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:42502 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbYEZJtO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 May 2008 05:49:14 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
I was thinking that linux-2.6.25-rc6-CITI_NFS4_ALL-1 nfsd was able to listen on the IPV6 domain also.
Since 2.6.24 Main changes have been done to replace the way to make a socket for nfsd and lockd by replacing
svc_makesock routine by the *svc_create_xprt* service.

Does anybody know if there is already a patch on this new code to support IPV6 for nfsd and lockd ?

Thanks



-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic 
Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
Fax     : 33 (4) 76.29.75.18
----------------------------------------------------------------- 

