Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:41369 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337Ab2H2NGN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Aug 2012 09:06:13 -0400
Received: by eekc1 with SMTP id c1so216455eek.19
        for <linux-nfs@vger.kernel.org>; Wed, 29 Aug 2012 06:06:11 -0700 (PDT)
Message-ID: <503E13BF.6010304@eneotecnologia.com>
Date: Wed, 29 Aug 2012 15:06:07 +0200
From: =?ISO-8859-1?Q?Carlos_Jim=E9nez?= <cjimenez@eneotecnologia.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Stale NFS file handle - persistent error
References: <503E131F.2040904@eneotecnologia.com>
In-Reply-To: <503E131F.2040904@eneotecnologia.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello everybody,

I have a computer acting as an NFS Server running a Debian based distro 
and several hosts running CentOS 6.2 acting as NFS clients (for a 
virtualization environment). Every time more often "Stale NFS file 
handle" errors appear when trying to copy a file from one directory to 
another (both in the nfs shared directory).
In the server side there are no related information in the logs, but 
this is the output of one of the nfs clients:

Wed Aug 29 11:52:57 2012 [TM][E]: clone: Command "cd 
/var/lib/one/datastores/0/32; cp -r 
../../1/5c0455eb494fd43b5c7c576e0c642fbe 
/var/lib/one/datastores/0/32/disk.0" failed: cp: reading 
`../../1/5c0455eb494fd43b5c7c576e0c642fbe': Stale NFS file handle

I've checked that path and filenames are correct. The file itself is a 
300MG sized and the error appears aprox. 30 minutes after the start of 
the copy, so I guess that it doesn't finish the file copy.
I usually tried unmounting and remounting the shared directory. In fact, 
initially it was enough and it was possible to fully copy the file 
(after aprox. 30 minutes), moreover because the error took place from 
time to time. But now, the problem persists after doing it (even after 
rebooting the clients).
Additionally, I've tried doing the same operation (to copy the same file 
from a directory to another) locally in the NFS Server and it takes just 
a minute (aprox.).

Could you give me advice on troubleshooting it?


Thanks in advance.

Carlos.
