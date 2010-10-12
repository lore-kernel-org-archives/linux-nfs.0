Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sainfoin-out.extra.cea.fr ([132.166.172.107]:47198 "EHLO
	sainfoin-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757184Ab0JLLOx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Oct 2010 07:14:53 -0400
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by sainfoin.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.0) with ESMTP id o9CBEpZW010994
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Tue, 12 Oct 2010 13:14:51 +0200
Received: from muguet1.intra.cea.fr (muguet1.intra.cea.fr [132.166.192.6])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id o9CBEpLd022636
	for <linux-nfs@vger.kernel.org>; Tue, 12 Oct 2010 13:14:51 +0200
	(envelope-from philippe.deniel@cea.fr)
Received: from zia.bruyeres.cea.fr (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet1.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.1) with SMTP id o9CBEpjo007243
	for <linux-nfs@vger.kernel.org>; Tue, 12 Oct 2010 13:14:51 +0200
Message-ID: <4CB4432B.7020709@cea.fr>
Date: Tue, 12 Oct 2010 13:14:51 +0200
From: DENIEL Philippe <philippe.deniel@cea.fr>
To: linux-nfs@vger.kernel.org
Subject: RPM packaging for libnfsidmap ?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I have searched on Google, and I found no distribution of libnfsidmap as
a rpm package (but I could easily find the tarball on CITI's website).
On my site, I need such a rpm (we have a massive cluster with yum
repository + configuration files managed by Puppet) so I will do it if
none is available.
If I write the related specfile, would someone be interested in having
it being integrated in some way to the libnfsidmap distribition ?

  Regards

       Philippe

PS: sorry if you received this email twice, I wrote first to the wrong 
address. Sorry for the noise in your mailbox
