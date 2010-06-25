Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cirse-out.extra.cea.fr ([132.166.172.106]:55067 "EHLO
	cirse-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830Ab0FYHvg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jun 2010 03:51:36 -0400
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by cirse.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.0) with ESMTP id o5P7pZdR028314
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jun 2010 09:51:35 +0200
Received: from muguet2.intra.cea.fr (muguet2.intra.cea.fr [132.166.192.7])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id o5P7pYaD026398
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jun 2010 09:51:35 +0200
	(envelope-from Philippe.DENIEL@CEA.FR)
Received: from zia.bruyeres.cea.fr (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet2.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.1) with SMTP id o5P7pYf0012527
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jun 2010 09:51:34 +0200
Message-ID: <4C246006.10708@cea.fr>
Date: Fri, 25 Jun 2010 09:51:34 +0200
From: philippe.deniel@cea.fr
To: linux-nfs@vger.kernel.org
Subject: NFS4ERR_DELAY and OP4_PUTROOTFH
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

in which situation would OP4_PUTROOTFH return NFS4ERR_DELAY ? I have 
seen in rfc5661 that PUTROOTFH can return such an error, but I can't 
figure out when this can occur.

    Regards,

       Philippe
