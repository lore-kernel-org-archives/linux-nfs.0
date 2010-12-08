Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout0.thls.bbc.co.uk ([132.185.240.35]:47744 "EHLO
	mailout0.thls.bbc.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755338Ab0LHPsg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Dec 2010 10:48:36 -0500
Received: from gateh.kw.bbc.co.uk (gateh.kw.bbc.co.uk [132.185.132.17])
	by mailout0.thls.bbc.co.uk (8.14.4/8.14.3) with ESMTP id oB8FmXXD000158
	for <linux-nfs@vger.kernel.org>; Wed, 8 Dec 2010 15:48:33 GMT
Received: from mailhub.rd.bbc.co.uk ([172.29.120.130])
	by gateh.kw.bbc.co.uk (8.13.6/8.13.6) with ESMTP id oB8FmXcA003503
	for <linux-nfs@vger.kernel.org>; Wed, 8 Dec 2010 15:48:33 GMT
Date: Wed, 8 Dec 2010 15:48:32 +0000
From: David Flynn <davidf@rd.bbc.co.uk>
To: linux-nfs@vger.kernel.org
Cc: David Flynn <davidf@rd.bbc.co.uk>
Subject: Re: can't dump core on NFSv4 mounts
Message-ID: <20101208154832.GE20844@rd.bbc.co.uk>
References: <20101208153340.GD20844@rd.bbc.co.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101208153340.GD20844@rd.bbc.co.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

* David Flynn (davidf@rd.bbc.co.uk) wrote:
> On an NFS4 client (mounting a solaris ufs export), for a long time i've
> been experiencing vim complaining when exiting:
>   E137: Viminfo file is not writable: /home/davidf/.viminfo

A similar and possibly related fault that I'm seeing is the inability
for a process to dump a core file when it segfaults on an nfs4 mount.

If the filesystem is mounted nfs3, then this issue does not arise.

using:
  $ echo 'int main() {return *(int*)0;}' >segfault.c

on an nfs4 mount:
  host-a$ ~/segfault
  Segmentation fault
  host-a$ ls -l
  total 1
  -rw------- 1 4294967294 4294967294 0 2010-12-08 15:34 core

a remote system shows:
  host-b$ ls -l
  total 1
  -rw------- 1 davidf rd 0 Dec  8 15:34 core

waiting for the dust to settle:
  host-a$ ls -l
  total 1
  -rw------- 1 davidf rd 0 2010-12-08 15:34 core

Iff, the core file already exists, then the core dump succeeds:
  host-a$ touch core
  host-a$ ls -l
  total 1
  -rw------- 1 davidf rd 0 2010-12-08 15:42 core
  host-a$ ~/segfault
  Segmentation fault (core dumped)

I can reliably reproduce using 2.6.32.11 and 2.6.35
I can not reproduce on 2.6.26

Kind regards,

..david
