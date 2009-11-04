From: Jon Forrest <jlforrest-TVLZxgkOlNX2fBVCVOL8/A@public.gmane.org>
Subject: (ANSWER) Question About nfs3 vs. nfs4 Semantics On Sun 7310 Server
Date: Wed, 04 Nov 2009 14:40:21 -0800
Message-ID: <hcsvs6$dbl$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfsv4@linux-nfs.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:50054 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758325AbZKDWkb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Nov 2009 17:40:31 -0500
Received: from list by lo.gmane.org with local (Exim 4.50)
	id 1N5oWq-0006FD-15
	for linux-nfs@vger.kernel.org; Wed, 04 Nov 2009 23:40:36 +0100
Received: from nobozo.cchem.berkeley.edu ([128.32.50.5])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 04 Nov 2009 23:40:36 +0100
Received: from jlforrest by nobozo.cchem.berkeley.edu with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 04 Nov 2009 23:40:36 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The other day I posted the description below of a problem
I was having when I was mounting from a Sun 7310
server using NFSv3 and NFSv4 from a CentOS 5.3
client.

It turned out that the solution was trivial - all
I needed to do was to use the "noacl" option
in my NFSv3 mount command. I still think that the
client shouldn't have complained about not
being able to preserve file protections since
it was actually to do so.

I'm still not sure if I should try NFSv4 but that's
another issue.

Cordially,

-- 
Jon Forrest
Research Computing Support
College of Chemistry
173 Tan Hall
University of California Berkeley
Berkeley, CA
94720-1460
510-643-1032

1    [nfs3]# touch x
2    [nfs3]# cp -p x y
3    cp: preserving permissions for `y': Operation not supported
4    cp: preserving ACL for `y': Operation not supported
5    [nfs3]# ls -l
6    total 1
7    -rw-r--r--+ 1 root root 0 Nov  3 14:46 x
8    -rw-r--r--+ 1 root root 0 Nov  3 14:46 y
9    [nfs3]# cd /tmp/x/home/jlforrest/nfs4
10   [nfs4]# touch x
11   [nfs4]# cp -p x y
12   [nfs4]# ls -l
13   total 1
14   -rw-rw-r-- 1 nobody nobody 0 Nov  3 14:48 x
15   -rw-rw-r-- 1 nobody nobody 0 Nov  3 14:48 y


