Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25305 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750714Ab0JEMnV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Oct 2010 08:43:21 -0400
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o95ChKfO007510
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 5 Oct 2010 08:43:21 -0400
Received: from badhat.bos.devel.redhat.com (badhat.boston.devel.redhat.com [10.16.60.49])
	by int-mx08.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o95ChKHH030943
	for <linux-nfs@vger.kernel.org>; Tue, 5 Oct 2010 08:43:20 -0400
Message-ID: <4CAB1D66.1050807@RedHat.com>
Date: Tue, 05 Oct 2010 08:43:18 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Updated The pNFS Developmental repository
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I've just updated the nfs-utils rpms in the pNFS development 
repository to include:
    * The latest nfs-utils release (1.2.3)
    * The latest pnfs nfs-utils bits

These rpms will now install the blkmapd init script
and the /etc/modprobe.d/nfsv41 file which hopeful get the 
correct modules installed on the client.

Instructions on how to install and use these kernels are at:
http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup

 If/when bugs are found with these rpms please enter them
in to the NFS Bugzilla Main Page at:
    https://bugzilla.linux-nfs.org/index.cgi

Please use the "pNFS" keyword.. 

Any question or issues please feel free to contact me... 

steved.
