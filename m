Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:33718 "EHLO
	mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbbJ3Oz2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Oct 2015 10:55:28 -0400
Received: by lfbf136 with SMTP id f136so20241379lfb.0
        for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2015 07:55:26 -0700 (PDT)
MIME-Version: 1.0
From: Jeenu Viswambharan <jeenuv@gmail.com>
Date: Fri, 30 Oct 2015 14:54:56 +0000
Message-ID: <CAKCW0Y78D15MhRcxNtS2=0xQPowPFBPw43L=OLQE=1WJd8Acuw@mail.gmail.com>
Subject: NFS mount timeouts
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've a development board whose root file system is shared via. NFS
from my PC (3.13.0-66-generic #108-Ubuntu SMP x86_64 GNU/Linux). The
behaviour at times is that board mounts the NFS share, but then soon
thereafter, while in execution, it started displaying NFS timeouts,
retries, and hangs. That's the end of it.

For some reason, the only combination that doesn't work is my board
mounting from my PC. My board can mount from other servers (I tested
with colleagues'). Also, the said NFS share can be mounted from other
PCs (including mine), so I'm sure the server is functional.

I restarted the server many times with 'sudo nfs-kernel-server
restart' but that didn't help. The NFS share is created with options
"rw,insecure,no_root_squash,no_subtree_check". I wish I could get some
logs out of NFS server to see what's going on.

The following packages are installed:

dpkg -l | grep nfs:
libnfsidmap2:amd64  0.25-5
nfs-common          1:1.2.8-6ubuntu1.1
nfs-kernel-server   1:1.2.8-6ubuntu1.1

I'm completely at dark as to why this is happening. I'm happy to
provide any information that you require. Please advise.

-- 
Jeenu
