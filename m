From: Simon Kirby <sim@hostway.ca>
Subject: New file doesn't show up if cached as missing
Date: Fri, 29 May 2009 10:52:43 -0700
Message-ID: <20090529175243.GA30961@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from newpeace.netnation.com ([204.174.223.7]:35447 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753528AbZE2SPi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 May 2009 14:15:38 -0400
Received: from sim by peace.netnation.com with local (Exim 4.63)
	(envelope-from <sim@netnation.com>)
	id 1MA6G3-00008C-NY
	for linux-nfs@vger.kernel.org; Fri, 29 May 2009 10:52:43 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello!

On Linux 2.6.28.10 server and client, with NFSv3 or NFSv4, I can
fairly easily reproduce a case where creating a file (open,write,close)
and then attempting to open it on another client mounting the same server
returns ENOENT.  If I run "ls" before I try to cat it, it works.

To reproduce:

ssh root@lps01 'rm -f /shared/ssl/test; stat /shared/ssl/test'; \
ssh root@lps02 'echo hi > /shared/ssl/test'; \
ssh root@lps01 'cat /shared/ssl/test'

The original stat (or cat or open) is important as it seems to cache that
the file does not exist.  I can then even log in and poke around:

lps01:~# cd /shared
lps01:/shared# cat test
cat: test: No such file or directory
lps01:/shared# stat test
stat: cannot stat `test': No such file or directory
lps01:/shared# ls test
ls: test: No such file or directory
lps01:/shared# ls
<files including "test">
lps01lsh:/shared# cat test
hi

Is this expected behaviour?  The file system is mounted on both clients
with: rw,hard,intr,...,acdirmin=0,acdirmax=0,acregmin=0,acregmax=0,noac

(eg: we can't find a way to make it not happen.)

Cheers,

Simon-
