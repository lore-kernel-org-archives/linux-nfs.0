Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:56490 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751505Ab1E1NCf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 May 2011 09:02:35 -0400
From: =?iso-8859-1?q?R=FCdiger_Meier?= <sweet_f_a@gmx.de>
To: linux-nfs@vger.kernel.org
Subject: infinite getdents64 loop
Date: Sat, 28 May 2011 15:02:31 +0200
Content-Type: text/plain;
  charset="us-ascii"
Message-Id: <201105281502.32719.sweet_f_a@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,


I have some directories where I run reproducible into infinite 
getdents64 loop. This happens whith kernels >=2.6.37 on clients and 
just doing ls or find on that dirs.

The "broken" dirs are mostly very large with >200000 files.
While copying such dir within the underlying fs (ext4) keeps that odd 
behavior it's not easy to create one on another exported filesystem.

Sometimes I could "repair" such dir by just finding the right single 
file to remove. But there was nothing special with that file.


I could track down the problem to:

commit 0b26a0bf6ff398185546432420bb772bcfdf8d94
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Nov 20 14:26:44 2010 -0500

    NFS: Ensure we return the dirent->d_type when it is known


After reverting the problem is gone.


cu,
Rudi
