Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cirse-out.extra.cea.fr ([132.167.195.14]:40861 "EHLO
	cirse-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870Ab0LMIPj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Dec 2010 03:15:39 -0500
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by cirse.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.0) with ESMTP id oBD7kO9I030268
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 13 Dec 2010 08:46:25 +0100
Received: from muguet1.intra.cea.fr (muguet1.intra.cea.fr [132.166.192.6])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id oBD7kOrf032103
	for <linux-nfs@vger.kernel.org>; Mon, 13 Dec 2010 08:46:24 +0100
	(envelope-from philippe.deniel@cea.fr)
Received: from zia.bruyeres.cea.fr (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet1.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.1) with SMTP id oBD7kOw3030293
	for <linux-nfs@vger.kernel.org>; Mon, 13 Dec 2010 08:46:24 +0100
Message-ID: <4D05CF50.1010305@cea.fr>
Date: Mon, 13 Dec 2010 08:46:24 +0100
From: DENIEL Philippe <philippe.deniel@cea.fr>
To: linux-nfs@vger.kernel.org
Subject: Side effects of having NFSv4 mounted over udp
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I know NFSv4 is definitely a connection oriented protocol, but noting 
prevent from using "mount -t nfs4 -o proto=udp <...>". Using TCP instead 
of UDP could be of great interest, especially in a HPC context where 
thousands of clients will operate at the same time. If a nfs mount point 
is made over udp, what would be the side effects ? I tried to run the 
connectathon on such a udp based mount point and I could find no errors. 
Is NFSv4/UDP a suitable solution ? Or does it make no sense to use udp ?

Thanks in advance for your answer.

    Regards

       Philippe
