Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cirse-out.extra.cea.fr ([132.167.192.142]:39334 "EHLO
	cirse-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934184Ab2DLOVX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Apr 2012 10:21:23 -0400
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by cirse.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.3) with ESMTP id q3CELLfh028983
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 12 Apr 2012 16:21:21 +0200
Received: from muguet1.intra.cea.fr (muguet1.intra.cea.fr [132.166.192.6])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id q3CELLGk016017
	for <linux-nfs@vger.kernel.org>; Thu, 12 Apr 2012 16:21:21 +0200
	(envelope-from philippe.deniel@cea.fr)
Received: from zia.cdc.esteban.ctsi (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet1.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.2) with SMTP id q3CELK0Q027729
	for <linux-nfs@vger.kernel.org>; Thu, 12 Apr 2012 16:21:20 +0200
Message-ID: <4F86E4E0.8000703@cea.fr>
Date: Thu, 12 Apr 2012 16:21:20 +0200
From: DENIEL Philippe <philippe.deniel@cea.fr>
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
Subject: How to manage EDQUOT on the server side
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I am currently busy with implementing quota management in my nfs server 
(nfs-ganesha).
I have efficient way to make NFS3_WRITE detecting an IO that exceeds 
data quota, and use that to return NFS3ERR_DQUOT.
Wireshark shows me that nfs reply contains NFS3ERR_DQUOT, but the client 
starts looping on the same WRITE call. By the end, by test application 
(a simple 'dd') end with "I/O Error".
Did I miss something when implementing this ?
I had no rquotad running for the share at the time the test was running, 
should I have a co-related rquotad running as well ?

    Regards

       Philippe
