From: Clay McClure <clay-zo/yENU/GurR7s880joybQ@public.gmane.org>
Subject: Data corruption using 2.6.18 NFSv3 client -- sparse files?
Date: Wed, 30 Apr 2008 06:41:48 +0000 (UTC)
Message-ID: <loom.20080430T061925-652@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:38846 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752714AbYD3HAH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2008 03:00:07 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1Jr6IM-0007kT-KX
	for linux-nfs@vger.kernel.org; Wed, 30 Apr 2008 07:00:03 +0000
Received: from 203.sub-70-212-185.myvzw.com ([70.212.185.203])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 30 Apr 2008 07:00:02 +0000
Received: from clay by 203.sub-70-212-185.myvzw.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 30 Apr 2008 07:00:02 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

When multiple 2.6.18 NFSv3 clients write to the same file, after one of the
clients has recently read from the file, we see data corruption in the form of
null bytes inserted into the file.

Simple test case:

hosta% echo "line 1" > /nfs/volume/bar.txt 

then, in rapid succession: 

hostb% cat bar.txt && sleep 2 && echo "line 2 from hostb" >> /nfs/bar.txt 
hostc% cat bar.txt && sleep 2 && echo "line 2 from hostc" >> /nfs/bar.txt 

Expected result:

/nfs/bar.txt contains:

line 1
line 2 from hostb
line 2 from hostc

Actual result:

/nfs/bar.txt contains:

line 1
\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0line 2 from hostc

This seems to be due to an inconsistency between the page cache and the
attribute cache on hostc. Running the 'cat' command on hostc causes bar.txt
to be loaded into the page cache. Meanwhile, its attributes are cached in the
attribute cache.

Seconds later, the 'echo' command on hostc causes the attribute cache to be
updated (a GETATTR operation is issued) with the new file size (reflecting
the line just appended by hostb), but the page cache is not updated (no READ
operation is issued).

The subsequent WRITE operation from hostc specifies an offset of 0 (beginning
of file) and a length equal to "line 1" + "line 2 from hostb" + "line 2 from 
hostc". Since the page cache on hostc does not contain the "line 2 from hostb"
content, that segment of the WRITE buffer is filled with nulls.

Note that no file locking is being used in this test case or our production
use case.

Questions:

- Is this a bug or correct operation?
- Would file locking produce the expected behaviour?

Thanks,

Clay McClure



