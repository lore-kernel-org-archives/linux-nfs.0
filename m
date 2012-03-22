Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cirse-out.extra.cea.fr ([132.167.192.142]:53732 "EHLO
	cirse-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701Ab2CVMpl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Mar 2012 08:45:41 -0400
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by cirse.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.3) with ESMTP id q2MCjd3r011293
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 22 Mar 2012 13:45:39 +0100
Received: from muguet2.intra.cea.fr (muguet2.intra.cea.fr [132.166.192.7])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id q2MCjdh9030437
	for <linux-nfs@vger.kernel.org>; Thu, 22 Mar 2012 13:45:39 +0100
	(envelope-from philippe.deniel@cea.fr)
Received: from zia2.esteban.ctsi (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet2.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.2) with SMTP id q2MCjdwM015558
	for <linux-nfs@vger.kernel.org>; Thu, 22 Mar 2012 13:45:39 +0100
Message-ID: <4F6B1EF3.2000200@cea.fr>
Date: Thu, 22 Mar 2012 13:45:39 +0100
From: DENIEL Philippe <philippe.deniel@cea.fr>
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
Subject: READDIRPLUS3 and NFS3ERR_BAD_COOKIE
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

what is the client's behavior if NFS3ERR_BAD_COOKIE is replied by 
READDIRPLUS3 ?
I have this error when running bonnie++ on top of my (non knfsd) server. 
At this step bonnie++ readdirs all dentries and erase them. One of the 
readdir calls ends with NFS3ERR_BAD_COOKIE and immediatly after, the 
client is calling RMDIR3, without having removed any of the found 
dentries. Of course RMDIR3 replies NFS3ERR_NOT_EMPTY, but I do not 
understand why REMOVE is not called. It looks like the clients behaves 
that the directory is empty after having received NFS3ERR_BAD_COOKIE 
(that just an hypothesis, I am not just this is what actually happens).
Do you have any idea ?

    Regards

       Philippe
