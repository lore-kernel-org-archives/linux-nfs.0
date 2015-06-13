Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:37308 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097AbbFMArc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2015 20:47:32 -0400
Received: by igbsb11 with SMTP id sb11so20342611igb.0
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jun 2015 17:47:32 -0700 (PDT)
Received: from gmail.com (c-98-212-204-93.hsd1.il.comcast.net. [98.212.204.93])
        by mx.google.com with ESMTPSA id j5sm3607641ioo.8.2015.06.12.17.47.30
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jun 2015 17:47:30 -0700 (PDT)
Date: Fri, 12 Jun 2015 19:47:18 -0500
From: Quentin Barnes <qbarnes@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: Adding file handle support to NFS client code
Message-ID: <20150613004718.GA26293@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm thinking of adding support to the NFS client code so that the
open_by_handle_at(2) and name_to_handle_at(2) services would work
on NFS mounted file systems.  As far as I can tell, this support
currently doesn't exist in mainline, correct?


Many years ago I created and still maintain (unreleased) code for
RHEL4-RHEL6 kernels that provide open-by-file-handle services for
NFS clients.  The approach was loosely based on Robert Love's ext3
open-by-inode patch of long ago.

We have used the modified NFS client code as a significant
performance boost in accessing mostly read-only files from NFS file
servers.  The files number in the many 10s of millions in trees
spread across many hundreds of thousands of nested directories.
(Come to think of it, that was several years ago.  I'm sure since
then the numbers have grown by at least an order of magnitude or
two.)  With the sheer numbers of files and directories, attempting
to use even openat(2) with all those directories would still be
overwhelming to the servers' inode cache.  Also, just doing all the
constant tree-walks down to the files kill performance and stresses
the dentry cache, let alone all the network traffic and load on our
filers that would generate.  So that's why an open-by-file-handle
hack was added to our kernels.

Now the time has come for that functionality to be ported to a
RHEL7-based kernel.  Seems to me the best approach would be not to
port my old work forward but to complete the fhandle callbacks for
NFS clients.  However, before I begin my journey down that path, I'd
like to hear if anyone has tried it before, or if there's a good
reason not to choose this approach.  Any comments?


If the NFS client fhandle support is the right way to go, since
it wouldn't be a hackfest like my previous effort, I'd attempt
contribute it upstream in case anyone else would ever find it
useful.

Quentin
