From: Simon Kirby <sim@hostway.ca>
Subject: RPC: multiple fragments per record not supported
Date: Mon, 8 Jun 2009 17:20:33 -0700
Message-ID: <20090609002033.GL21174@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from newpeace.netnation.com ([204.174.223.7]:59269 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750727AbZFIAUf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2009 20:20:35 -0400
Received: from sim by peace.netnation.com with local (Exim 4.63)
	(envelope-from <sim@netnation.com>)
	id 1MDp4r-0004pi-RA
	for linux-nfs@vger.kernel.org; Mon, 08 Jun 2009 17:20:33 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello!

With 2.6.28.10 and 2.6.29.4 knfsd after a few hours of heavy concurrent
NFSv3 write loads (migration of Maildirs with rsync), we are seeing this
error:

	kernel: RPC: multiple fragments per record not supported

...followed by knfsd immediately ignoring all further requests. 
Restarting knfsd (/etc/init.d/nfs-kernel-server restart) seems to make
it start responding and work as normal again.

"ps -eo pid,stat,args,wchan" during the event shows all nfsd processes
sleeping in "svc_recv":

22714 S<   [nfsd]                      svc_recv

This client with the high write load is an old 2.6.17 kernel, mounting
the server with rw,nolock,hard,intr,timeo=9,retrans=3,rsize=8192,wsize=8192
(jumbo frames are enabled).

Is this any sort of known issue?  I'm trying to reproduce it in a testing
environment.

Cheers,

Simon-
