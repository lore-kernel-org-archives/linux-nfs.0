Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cirse-out.extra.cea.fr ([132.167.192.142]:42874 "EHLO
	cirse-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755147Ab1G2H2G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 03:28:06 -0400
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by cirse.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.2) with ESMTP id p6T7S3ji008607
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Fri, 29 Jul 2011 09:28:04 +0200
Received: from muguet1.intra.cea.fr (muguet1.intra.cea.fr [132.166.192.6])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id p6T7S30G003089
	for <linux-nfs@vger.kernel.org>; Fri, 29 Jul 2011 09:28:03 +0200
	(envelope-from philippe.deniel@cea.fr)
Received: from zia.esteban.ctsi (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet1.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.1) with SMTP id p6T7S3UU009828
	for <linux-nfs@vger.kernel.org>; Fri, 29 Jul 2011 09:28:03 +0200
Message-ID: <4E326103.6020003@cea.fr>
Date: Fri, 29 Jul 2011 09:28:03 +0200
From: DENIEL Philippe <philippe.deniel@cea.fr>
To: linux-nfs@vger.kernel.org
Subject: pynfs and newpynfs for NFSv4 and NFSv4.1
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I had a look at the repositories listed here 
(http://www.citi.umich.edu/projects/nfsv4/pynfs/) for pynfs. The page 
lists two repositories, but when looking at them, even if their names 
differ, they look pretty similar (same logm same commits).
Are they different ? Can I use a single newpynfs do validate both 
NFSv4.0 and NFSv4.1 ?

    Regards

       Philippe
