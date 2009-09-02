From: Jason Legate <linux-nfs-17UcKVrmzybR7s880joybQ@public.gmane.org>
Subject: NFS for millions of files
Date: Wed, 2 Sep 2009 14:08:41 -0400
Message-ID: <20090902180841.GF946@proxime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.offsitebackups.net ([64.251.15.164]:64326 "EHLO
	home.slashze.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753326AbZIBSNz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 14:13:55 -0400
Received: from localhost (unknown [127.0.0.1])
	by home.slashze.ro (Postfix) with ESMTP id 79A0461D86
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2009 14:08:43 -0400 (EDT)
Received: from home.slashze.ro ([127.0.0.1])
	by localhost (home.slashze.ro [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id x3Y-ZW7h+HkG for <linux-nfs@vger.kernel.org>;
	Wed,  2 Sep 2009 14:08:41 -0400 (EDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, I'm trying to setup a server that we can create millions of files on over
NFS.  When I run our creation benchmark locally  I can get around 3000 files/
second in the configuration we're using now, but only around 300/second over
NFS.  It's mounted as this:

rw,nosuid,nodev,noatime,nodiratime,hard,bg,nointr,rsize=32768,wsize=32768,tcp,
nfsvers=3,timeo=600,actimeo=600,nocto

When I mount the same FS over localhost instead of across the lan, it performs
about full speed (the 3000/sec).  Anyone have any ideas what I might tweak or
look at?

We're going to be testing various XFS/LVM configs to get the best performance,
but right out the gate, NFS having a 10:1 penalty of performance doesn't bode
well.

Thanks in advance,
Jason
