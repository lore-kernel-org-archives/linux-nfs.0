Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:40319 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754214AbaFYWG3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2014 18:06:29 -0400
Received: from [71.236.153.111] (helo=FranksLaptop)
	by elasmtp-banded.atl.sa.earthlink.net with esmtpa (Exim 4.67)
	(envelope-from <ffilzlnx@mindspring.com>)
	id 1WzvBJ-0003dX-8F
	for linux-nfs@vger.kernel.org; Wed, 25 Jun 2014 17:56:41 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: <linux-nfs@vger.kernel.org>
Subject: Execute only permission issue with client
Date: Wed, 25 Jun 2014 14:56:25 -0700
Message-ID: <029301cf90c0$4fabe660$ef03b320$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Back a year ago or so, I ran the following test against Ganesha:

http://www.tuxera.com/community/posix-test-suite/

On NFS v4, one of the issues it tripped over was execute only files.
Apparently the Linux v4 client doesn't make ACCESS calls in conjunction with
an open system call, with the result that you can open an execute only file
(per RFC 3530bis, the server is allowing such to allow clients to execute
executables).

We tripped over this issue again in some of our testing.

One bit that I don't actually understand is how the kernel differentiates
between bash (etc) issuing an open system call to load a script and vi
trying to browse same script... 

I had done some testing executing shell scripts and such and saw some
inconsistency. Now, trying things, I can't seem to run a bash script that is
execute only (local, v3, or v4), but can run a compiled binary that is
execute only (local, v3, and v4), so I'm not sure what the deal is...

Current setup is Fedora 20 with EXT4, running Ganesha 2.1 for NFS server.

Thanks for any insight,

Frank




