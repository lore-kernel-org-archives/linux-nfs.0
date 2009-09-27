From: Andy Mastbaum <mastbaum-q5nx0x9Hqjyyum0STUha2w@public.gmane.org>
Subject: "NFS: Buggy server - nlink == 0!" & segfault
Date: Sun, 27 Sep 2009 16:04:00 -0400
Message-ID: <4ABFC530.4060504@hep.upenn.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from HIGGS.HEP.upenn.edu ([128.91.45.1]:37548 "EHLO
	higgs.hep.upenn.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961AbZI0UkX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Sep 2009 16:40:23 -0400
Received: from [128.91.45.56] (neutralino.hep.upenn.edu [128.91.45.56])
	by higgs.hep.upenn.edu (8.13.0/8.13.0) with ESMTP id n8RK22Jo028776
	for <linux-nfs@vger.kernel.org>; Sun, 27 Sep 2009 16:02:03 -0400 (EDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello. I have a bunch of Linux (2.6.18-128.1.1.el5, RHEL 5.3) boxen that 
mount NFS shares from Solaris, and one died recently in a conflagration 
of kernel segfaults following an NFS error:

Sep 11 19:37:12 nubar6 kernel: NFS: Buggy server - nlink == 0!
Sep 11 19:47:57 nubar6 kernel: gdb[28311]: segfault at 00002b4888e73c0b 
rip 0000000000508f20 rsp 00007fff4112c988 error 4
Sep 11 19:55:42 nubar6 kernel: NFS: Buggy server - nlink == 0!
Sep 11 19:55:42 nubar6 kernel: NFS: Buggy server - nlink == 0!
Sep 11 20:10:27 nubar6 kernel: NFS: giant filename in readdir (len 201)!
Sep 11 20:10:42 nubar6 kernel: NFS: giant filename in readdir (len 201)!
...
Sep 11 20:36:12 nubar6 kernel: gdb[21443]: segfault at 00002aec9e92d90c 
rip 000000000050be3e rsp 00007fff6fa92250 error 4
Sep 11 22:09:42 nubar6 kernel: gdb[6258]: segfault at 000000010b7023b5 
rip 0000000000508ea0 rsp 00007fff8d39da88 error 4
...

Perhaps the Solaris NFS server is indeed buggy, but shouldn't this be 
caught/handled by the Linux NFS client? Any thoughts/suggestions?

Thanks!

Andy Mastbaum
mastbaum-q5nx0x9Hqjyyum0STUha2w@public.gmane.org
