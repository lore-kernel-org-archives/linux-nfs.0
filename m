From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: NFS_ALL patchsets updated for Linux-2.4.26...
Date: Wed, 14 Apr 2004 14:23:20 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1081977800.2575.144.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: nfs@lists.sourceforge.net
List-ID: <nfs.lists.sourceforge.net>

A number of people have written to ask for updates of the 2.4.x NFS_ALL
patchsets which were unchanged since 2.4.23 or so. I haven't done this
because the 2.4.23 patches should have applied fine to all kernels
between 2.4.23 and the 2.4.26-pre series.

Since we've now merged in several of the bugfixes that were already in
NFS_ALL into Marcelo's kernel, I have put out an updated NFS_ALL for
2.4.26. Please assume that it can be applied to any future 2.4.x kernels
until further notice.

Please also assume that, 2.4.x is feature-frozen. None of these patches
are therefore slated for inclusion into Marcelo's kernel. They are only
being provided in order to allow people who are currently relying on
these features in their private 2.4.x builds to continue to use them.

Please see

   http://www.fys.uio.no/~trondmy/src/Linux-2.4.x/2.4.26/

for further details.

Cheers,
  Trond
