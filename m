From: Harald Dunkel <harald.dunkel@aixigo.de>
Subject: Solaris NFSv3 client to Linux server
Date: Fri, 16 Oct 2009 09:08:56 +0200
Message-ID: <4AD81C08.5020607@aixigo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.aixigo.de ([195.14.232.227]:19169 "EHLO gate1.ac.aixigo.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755027AbZJPHRY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Oct 2009 03:17:24 -0400
Received: from srvl003.ac.aixigo.de (srvl003.ac.aixigo.de [172.19.96.13])
	by gate1.ac.aixigo.de (8.14.1/8.14.1) with ESMTP id n9G78uZr022665
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2009 09:08:56 +0200 (CEST)
Received: from [172.19.97.183] (localhost [127.0.0.1])
	by srvl003.ac.aixigo.de (8.12.6/8.12.6/SuSE Linux 0.6) with ESMTP id n9G78u72004076
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2009 09:08:56 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

I see a pretty poor NFSv3 performance for my Solaris10 machines
(sparc) connected to the Linux (amd64, 2.6.29.6) servers,
especially on removing a lot of files. Sample:

% time rm -rf linux-2.6.31.4/Documentation
real 0m45.268s
user 0m0.044s
sys 0m44.334s

Please note the high sys value. Using a Solaris 10 NFSv3 server
and the same client I get this instead:

% time rm -rf linux-2.6.31.4/Documentation
real 0m22.712s
user 0m0.029s
sys 0m0.330s

It is still not a brilliant time, but the sys value is much
closer to what one would expect.

The usual optimizations about attribute caching and wsize/rsize
etc. did not improve the poor performance. Not to mention that
NFSv4 is _much_ faster for both servers.

Of course I understand that this is a Solaris issue, but maybe
you have some insight? Did somebody investigate this?


Regards

Harri

