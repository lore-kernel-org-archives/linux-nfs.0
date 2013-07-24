Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 82-198-214-42.briteline.de ([82.198.214.42]:40145 "EHLO
	mail.artcom-gmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752900Ab3GXKEU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jul 2013 06:04:20 -0400
Received: from [192.168.141.2] (helo=artcom2.artcom-gmbh.de)
	by mail.artcom-gmbh.de with esmtps (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <pf@artcom-gmbh.de>)
	id 1V1vDj-0005Kk-HV
	for linux-nfs@vger.kernel.org; Wed, 24 Jul 2013 11:18:55 +0200
Date: Wed, 24 Jul 2013 11:18:58 +0200
From: Peter Funk <pf@artcom-gmbh.de>
To: linux-nfs@vger.kernel.org
Subject: How to avoid rebooting Linux NFS-client when NFS-server is not
 available?
Message-ID: <20130724091856.GA30866@pfmaster>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello all,

We've researched this question for quite a while now and nobody here
found a solution to the following problem:

 1: A Linux computer is NFS client of some other Linux NFS server
    and has some active mounts and some processes working with files 
    on that NFS server.  

 2: Now the NFS server becomes unavailable and a system administrator 
    wants to clean up the situation on the NFS client computer without 
    having to reboot this client computer.

Is this possible?  And if how exactly?

Best Regards and many thanks in advance, 
Peter Funk
P.S.: umount -f -l did not work  
      System hangs for a long time in shutdown and shutdown 
      only succeeds without hard reset after reconnecting the
      NFS server.
-- 
Peter Funk, home: ✉Oldenburger Str.86, D-27777 Ganderkesee
mobile:+49-179-640-8878 phone:+49-421-20419-0 <http://www.artcom-gmbh.de/>
office: ArtCom GmbH, ✉Haferwende 2, D-28357 Bremen, Germany
