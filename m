Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out5.uio.no ([129.240.10.17]:59392 "EHLO mail-out5.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751705AbbDOKGd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Apr 2015 06:06:33 -0400
Received: from mail-mx4.uio.no ([129.240.10.45])
	by mail-out5.uio.no with esmtp (Exim 4.80.1)
	(envelope-from <e.j.oltedal@fys.uio.no>)
	id 1YiK0U-0007Xc-Ad
	for linux-nfs@vger.kernel.org; Wed, 15 Apr 2015 11:53:18 +0200
Received: from 1x-193-157-193-61.uio.no ([193.157.193.61])
	by mail-mx4.uio.no with esmtpsa (TLSv1.2:DHE-RSA-AES128-SHA:128)
	user einojo (Exim 4.80)
	(envelope-from <e.j.oltedal@fys.uio.no>)
	id 1YiK0T-0008JU-Sh
	for linux-nfs@vger.kernel.org; Wed, 15 Apr 2015 11:53:18 +0200
Message-ID: <552E3508.5000403@fys.uio.no>
Date: Wed, 15 Apr 2015 11:53:12 +0200
From: Eino Juhani Oltedal <e.j.oltedal@fys.uio.no>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Problem installing nfs-utils to non standard dir
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi!

I'm trying to build nfs from source. I'm using nfs-utils-1.3.2 from 
http://sourceforge.net/projects/nfs/files/nfs-utils/1.3.2/.
I configure using the following command

     ./configure --prefix=/home/username/installs/tmp 
--exec-prefix=/home/username/installs/tmp

When i run "make install" most of the packages are put under 
/home/username/installs/tmp, but for some reason the
install script tries to put osd_login under /sbin, which results in an 
error:

     Making install in osd_login
     make[2]: Entering directory 
`/home/username/installs/nfs-utils-1.3.2/utils/osd_login'
     make[3]: Entering directory 
`/home/username/installs/nfs-utils-1.3.2/utils/osd_login'
         /usr/bin/mkdir -p '/sbin'
         /usr/bin/install -c osd_login '/sbin'
         /usr/bin/install: cannot remove ‘/sbin/osd_login’: Permission 
denied
         make[3]: *** [install-dist_sbinSCRIPTS] Error 1

This is not supposed to happen, is it? Is there an easy way to fix it? I 
get the same error trying to build nfs-utils-1.3.1 as well.

Cheers,
Eino
