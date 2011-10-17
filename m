Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.aixigo.de ([80.149.209.52]:52943 "EHLO mail.aixigo.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752740Ab1JQIKe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Oct 2011 04:10:34 -0400
Received: from srvvm01.ac.aixigo.de. (mail.ac.aixigo.de [172.19.96.11])
	by mail.aixigo.com (8.14.3/8.14.3) with ESMTP id p9H7rcwm003269
	for <linux-nfs@vger.kernel.org>; Mon, 17 Oct 2011 09:53:38 +0200 (CEST)
Received: from dpcl082.ac.aixigo.de (dpcl082.ac.aixigo.de [172.19.97.128])
	by srvvm01.ac.aixigo.de. (8.14.3/8.14.3/Debian-9.4) with ESMTP id p9H7rblB032368
	for <linux-nfs@vger.kernel.org>; Mon, 17 Oct 2011 09:53:38 +0200
Message-ID: <4E9BDF01.6090106@aixigo.de>
Date: Mon, 17 Oct 2011 09:53:37 +0200
From: Harald Dunkel <harald.dunkel@aixigo.de>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: nfs3 30% faster than nfs4?
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

I did a brief test on a local nfs server: Extracting the
linux kernel sources on a nfs partition it seems that nfs3
is 30% faster than nfs4. For nfs3 I got 5.2MB/sec. Nfs4
gave me just 3.8MB/sec. The server was idle except for this
test.

Client and server were running 2.6.39 from the Debian backports
repository. I just changed the mount option on the client to
select nfs3 or nfs4.

I don't want to complain, but I did not expect this huge loss
in performance for moving to nfs4. Any helpful comment would be
highly appreciated.

Harri
