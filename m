Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:56703 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756264Ab0FBCXg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jun 2010 22:23:36 -0400
Received: by iwn6 with SMTP id 6so1073854iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 01 Jun 2010 19:23:36 -0700 (PDT)
Date: Wed, 2 Jun 2010 12:23:35 +1000
Message-ID: <AANLkTikWHjDT9_GesAqNmj31h-fNFiGMVeiYkk_oiLqd@mail.gmail.com>
Subject: Issue for list directory contains large number files
From: hce <webmail.hce@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

When I mounted NFS client to a FUSE filesystem in Linux, it took hours
to list a directory contains 100 K files. There are following two
issues:

(1) The readdir returns all file names and file attributes to NFS, but
despite NFS got the file attributes, it still called getattr for each
file. Is there any mount option can suppress those getattrs during
listing directory call?

(2) If a directory contains files smaller than 25, the NFS called only
one readdir, a normal scenario. When a directory contains files larger
than 25, NFS called multiple readdirs. In fact, between 25 getattrs,
NFS called another readdir. Every readdir returned NFS the same
directory content with all file names and file attributes in that
directory. Not clear if the 25 is a magic number or if 25 is just
coincident associated to entries, file size, or timing?

If a directory contains 100 K files, NFS called thousands getdirs.
Each getdir returned NFS the same 100 K file names and file
attributes. A wired situation where the NFS should only need one
getdir to list the directory contents on screen, is it correct?

To make sure those problems were not caused from FUSE, I've tried to
list a directory which contains 100 K files directly from FUSE mount
point (No NFS client), it indeed only called readdir once, and there
was no single getattr called after the readdir, a normal behaviour you
can imagine.

Appreciate any explanations and suggestions of how to resolve this
issue (mount options?).

Thank you.
