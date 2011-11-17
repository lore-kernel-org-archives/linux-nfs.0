Return-Path: linux-nfs-owner@vger.kernel.org
Received: from trumpkin.cc.andrews.edu ([143.207.1.81]:52899 "EHLO
	trumpkin.cc.andrews.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162Ab1KQRLQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Nov 2011 12:11:16 -0500
Received: from secures.cc.andrews.edu (root@secures.cc.andrews.edu [143.207.1.47])
	by trumpkin.cc.andrews.edu (8.14.3/8.14.3/Debian-9.1) with ESMTP id pAHGve6A018145
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Nov 2011 11:57:40 -0500
Received: from [143.207.4.197] (blackhole.cc.andrews.edu [143.207.4.197])
	(authenticated bits=0)
	by secures.cc.andrews.edu (8.14.3/8.14.3/Debian-9.4) with ESMTP id pAHGvrML022336
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Nov 2011 11:57:53 -0500
Message-ID: <4EC53D15.3020801@andrews.edu>
Date: Thu, 17 Nov 2011 11:57:57 -0500
From: Todd Freeman <freeman@andrews.edu>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Updated files desync and become unlinked
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Good day all...

This may (very likely) be me just misunderstanding a "feature" of 
NFS...  but I have a VERY odd behaviour pattern.

We update a set of perl modules on an NFS client (svn update to grab new 
files) we then ssh to another client and restart our apache server there 
and go along our merry way.
We noticed that the apache server would fairly consistently have an old 
version of the file running and continue running with it until a new 
child started and reread the file (minutes later).

In debugging this we changed the module so that it checks its .pm file 
with a stat call to see how things are going. The data that we got from 
the stat reflected that the file was still old. We noticed that 'ls -al 
/the/directory/with/the/module/ ' would "fix" the desync... but that 'ls 
-al /the/directory/with/the/module/Module.pm'  would not. We also 
noticed that an ls of the file in question would show the link count as 
0 until it got "fixed", once fixed the link count was 1 again.

Am I missing a mount option.. or is there some way around this "feature" 
without doing and ls -alR of the whole thing to make sure all the 
modules are up to date?

My system info:
Ubuntu 10.10 server
2.6.35-30-server #60-Ubuntu SMP Mon Sep 19 21:00:00 UTC 2011 x86_64 
GNU/Linux

nfs-common 1:1.2.2-1ubuntu1.1

Thanks for any help you have to offer.

--
Todd
