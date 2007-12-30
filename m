From: Kovacs Gabor <kgabor-YraCNKMfOBk5Z0SDYBDJZg@public.gmane.org>
Subject: NFS client freezes under heavy disk IO
Date: Sun, 30 Dec 2007 01:13:49 +0100
Message-ID: <200712300113.49926.kgabor@bolyai.elte.hu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Cc: gbakos-6Mj89AmeLNm+fmr0zi+kZQ@public.gmane.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:34635 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752567AbXL3AOL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 29 Dec 2007 19:14:11 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello All,

We have some NFS problem on a big partition. NFS (v3) server runs kernel 
version 2.6.21.6, client runs kernel version 2.6.21.7. Exported file system 
is on XFS file system,  8.9T, typical file size is 1-10M. NFS tools are from 
Fedora 7: nfs-utils-1.1.0-3.fc7

On the client side, during heavy read-IO (a program walks on tens of thousands 
of files by opening them for reading and collects some data) after a couple 
of time (1-5 days) the user process freezes. Top command shows a "D" state 
for it, but many other commands trying to "touch" it, freezes, too. (ps, 
fuser /nfs_dir, w) making its own virtual console unusable. None of the 
frozen processes can be killed. Actually, the computer cannot be shut down 
cleanly any more, only the reset button helps.

There was a kernel error:
http://www.mediafire.com/imageview.php?quickkey=0to7xa0eowd

I guess it is some kind of out of memory condition. Is this possible? How much 
memory required by kernel nfs (client) modules?  Any idea to try?
(System has 16G memory, swap is 32G, user program consumed approx. 12G.)

A very similar deadlock was produced using NFSv4.

Thanks
Gabor Kovacs

