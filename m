From: "Brian Smith" <brian-kIZgWTxU+gRcxvNqPlePQg@public.gmane.org>
Subject: cache revalidation & locking
Date: Wed, 27 Feb 2008 09:12:28 -0800
Message-ID: <000901c87963$efffefb0$6401a8c0@T60>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from turtle-out.mxes.net ([216.86.168.191]:3012 "EHLO
	turtle-out.mxes.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018AbYB0Rni convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Feb 2008 12:43:38 -0500
Received: from mxout-04.mxes.net (mxout-04.mxes.net [216.86.168.179])
	by turtle-in.mxes.net (Postfix) with ESMTP id BCA4D1646A4
	for <linux-nfs@vger.kernel.org>; Wed, 27 Feb 2008 12:16:34 -0500 (EST)
Received: from T60 (unknown [70.254.204.177])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by smtp.mxes.net (Postfix) with ESMTP id C2825D059F
	for <linux-nfs@vger.kernel.org>; Wed, 27 Feb 2008 12:12:30 -0500 (EST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to http://www.unixcoding.org/NFSCoding#attrcache, the Linux NFS client flushes the attribute cache when a fnctl lock is obtained ("fcntl() locking flushes attribute cache with Linux and Solaris, but not with FreeBSD.") 

1. What is the first version of the client that does this (in terms of Linux kernel version)?

2. Is this a side-effect of the implementation, or is this a guarentee that the Linux client makes?

What I really want to know is "How can I get consistent read access, and perform safe appends, when multiple systems are appending to a file?"

My current locking strategy is:
 Opening the file:
   * fd = open(path, O_RDWR | O_APPEND | O_SYNC)
   * verify file integrity via checksums embedded in it
 Reading:
   * lock the while file (l_type=F_RDLCK, l_len=0, l_off=0)
   * fstat(fd, &st);
   * unlock everything after EOF (l_len=0, l_off=st.st_size)
   * read up to (st.st_size)
   * unlock everything before EOF (l_len=st.st_size, l_off=0)
 Appending:
   * lock the whole file (l_type=F_WRLCK, l_len=0, l_off=0)
   * fstat(fd, &st);
   * read up to (st.st_size)
   * replace write lock with read lock before EOF
     (l_len=st.st_size, l_off=0)
   * append the new data.
   * unlock the whole file (l_len = 0, l_off = 0)
 Protection against partial write failures:
    * checksums are written within the file in every write()

Is this a sound strategy when using the Linux NFS client? Is there a better one (one that reduces lock contention?)

- Brian

