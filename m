Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cliff.cs.toronto.edu ([128.100.3.120]:53024 "EHLO
        cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726236AbeIMGcH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Sep 2018 02:32:07 -0400
From: Chris Siebenmann <cks@cs.toronto.edu>
To: linux-nfs@vger.kernel.org
cc: cks@cs.toronto.edu
Subject: Correctly understanding Linux's close-to-open consistency
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 12 Sep 2018 21:24:58 -0400
Message-Id: <20180913012458.A6651322562@apps1.cs.toronto.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 I'm trying to get my head around the officially proper way of
writing to NFS files (not just what works today, and what I think
is supposed to work, since I was misunderstanding things about that
recently).

 Is it correct to say that when writing data to NFS files, the only
sequence of operations that Linux NFS clients officially support is
the following:

- all processes on all client machines close() the file
- one machine (a client or the fileserver) opens() the file, writes
  to it, and close()s again
- processes on client machines can now open() the file again for
  reading

Other sequences of operations may work in some particular kernel version
or under some circumstances, but are not guaranteed to work over kernel
version changes or in general.

In an official 'we guarantee that if you do this, things will work' sense,
how does taking NFS locks interact with this required sequence? Do NFS
locks make some part of it unnecessary, or does it remain necessary and
NFS locks are just there to let you coordinate who has a magic 'you can
write' token and you still officially need to close and open and so on?

Thanks in advance.

	- cks
