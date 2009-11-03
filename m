From: Jon Forrest <jlforrest-TVLZxgkOlNX2fBVCVOL8/A@public.gmane.org>
Subject: Question About nfs3 vs. nfs4 Semantics On Sun 7310 Server
Date: Tue, 03 Nov 2009 15:45:55 -0800
Message-ID: <hcqfb7$7va$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfsv4@linux-nfs.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:49715 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752670AbZKCXt7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Nov 2009 18:49:59 -0500
Received: from list by lo.gmane.org with local (Exim 4.50)
	id 1N5T8V-0003N0-OJ
	for linux-nfs@vger.kernel.org; Wed, 04 Nov 2009 00:50:03 +0100
Received: from nobozo.cchem.berkeley.edu ([128.32.50.5])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 04 Nov 2009 00:50:03 +0100
Received: from jlforrest by nobozo.cchem.berkeley.edu with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 04 Nov 2009 00:50:03 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(Sorry about posting to both nfs lists. I'm not
sure whether what I'm describing is an nfs3 or
nfs4 problem so I posted to both).

I've discovered what might be a bug in our Sun 7310 storage server.
This using the latest software release (2009.09.01.1.0,1-1.3).

The problem has to do with accessing a NFS share on the 7310
from a Linux 2.6.18-128.1.14.el5 kernel (a.k.a. CentOS 5.3).

The example below shows that certain behavior depends on whether
the NFS share is mounted using NFS3 or NFS4. This isn't a
surprise. What is a surprise is that both appear to have
problems.

The shell prompts in the example should clearly show which
is which (I've added line numbers in the left column for clarity).

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

To summarize, I have the same share mounted in two different
places, one using NFS3 and one using NFS4. The share has "root
access" enabled. The examples are being run by root.
In both cases, I'm simply creating a file, and then
using 'cp -p' to copy the file to another file in the same directory.

The message on line 3 is surprising because this command is being
run by root. The message on line 4 isn't surprising because NFS3
doesn't really support ACLs. If only line 4 were generated then
this would make sense. Note that the file protection and ownership
shown in lines 7-8 are correct.

On line 11, using the NFS4 mount point, no error messages are produced
when doing the copy. This is what I'd expect using either version of
NFS. However, notice that the file protection is different than
in the first example, but more importantly, notice that the file
ownership is wrong. Again, this is being run by root on a "root
access" enabled share.

Not being an NFS expert, I'm not if I'm seeing incorrect
behavior but it sure looks like it to me.

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
jlforrest-TVLZxgkOlNX2fBVCVOL8/A@public.gmane.org

