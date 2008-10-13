From: Omry Yadan <omry-FZzTFxfWWV5eoWH0uzbU5w@public.gmane.org>
Subject: file open for write fails under stress
Date: Tue, 14 Oct 2008 00:51:50 +0200
Message-ID: <48F3D106.9020203@yadan.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from out6.bezeqint.net ([192.115.188.206]:54923 "EHLO
	out6.bezeqint.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756094AbYJMXBM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Oct 2008 19:01:12 -0400
Received: from yadan.net (bzq-79-177-137-242.red.bezeqint.net [79.177.137.242])
	by out6.bezeqint.net (Postfix) with ESMTPA id 0181228606
	for <linux-nfs@vger.kernel.org>; Tue, 14 Oct 2008 00:49:29 +0200 (IST)
Received: from localhost (localhost [127.0.0.1])
	by yadan.net (Postfix) with ESMTP id 461161F2824
	for <linux-nfs@vger.kernel.org>; Tue, 14 Oct 2008 00:51:54 +0200 (IST)
Received: from yadan.net ([127.0.0.1])
	by localhost (home.firefang.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id KzBWFS3sQZHs for <linux-nfs@vger.kernel.org>;
	Tue, 14 Oct 2008 00:51:54 +0200 (IST)
Received: from [10.0.0.1] (main [10.0.0.1])
	by yadan.net (Postfix) with ESMTPSA id E87E71F2824
	for <linux-nfs@vger.kernel.org>; Tue, 14 Oct 2008 00:51:53 +0200 (IST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have an application that open many files for writing very fast, in a
way - it can almost be looked as a file system stress test.


my application is single threaded, and I noticed the following problem
when running a single instance of it:


at some point, after opening (and closing) many files for writing, the
application fails to open a file for writing.

if I sleep for 1 second and try again, it works.


my NFS server runs Debian etch 32 bit, with

nfs-kernel-server and nfs-common (1:1.0.10-6+etch.1).


client is also etch 32.

kernel on both is :2.6.18-6-686 #1 SMP Tue Jun 17 21:31:27 UTC 2008 i686


both machines are quad core.



I tried to mount with tcp and udp, and tried both sync and async export
point.


is this a known issue?

any known workaround that will not require messing up the application
with retry logic?


    Omry.

