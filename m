Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:48986 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932471AbZHDGzy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2009 02:55:54 -0400
Received: by fxm17 with SMTP id 17so3089995fxm.37
        for <linux-nfs@vger.kernel.org>; Mon, 03 Aug 2009 23:55:54 -0700 (PDT)
Date: Tue, 4 Aug 2009 08:55:54 +0200
Message-ID: <3a4e28f70908032355u6ecf7a2bx6789347fdd5e5300@mail.gmail.com>
Subject: Problem with active / active NFS cluster
From: Niko Neufeld <niko.neufeld@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Dear all,

My apologies up-front if this the wrong mailing list for this post.

To serve the needs of a fairly large (~ 1000 nodes) cluster for an
experiment at CERN we use the following setup:
5 servers running RHEL 5.3 (2.6.18-128.1.16.el5 x86_64) export two
filesystems rw via NFS v3 over UDP to the entire cluster. The clients
are predominantly RHEL4 (2.6.9-78.0.8.EL.cernsmp) both 32 and 64 bits.
The filesystems reside on a SAN and the servers mount them using
StorNext cvfs 3.5.1.
For load-sharing and high-availability we use the following setup:
there are as many virtual IPs as their are physical servers. The
clients mount from a DNS alias. When all servers are active each
server will export both file-systems via one of the virtual IPs. We
use heartbeat to handle failovers, which works very nicely.
/etc/exports on all servers looks like this
<SNIP>
*lbdaq.cern.ch(rw,sync,root_squash,no_subtree_check,fsid=100)
</SNIP>

Recently users have reported the following strange problems

1) a directory (with some subdirectories and files) was deleted on one
client. Immedeatly afterwards the directory was re-created from a CVS
checkout. On at least one other client this change was *not* visible.
The original contents (before the unlink) remained visible for more
than 1 hour (!). Unfortunately the problem "vanished" before we could
get traces (wireshark etc...). Fact is that the two client nodes in
question have mounted the fs from different servers.

2) One user claims that a freshly checked out directory (on which he
also worked from another node) has "vanished".

After googling for a while I realized that - at least from a
superficial search - that this specific configuration, where  several
servers serve the same filesystem at the same time, is rare.
My question now is: is there something fundamentally flawed or risky
in this setup? My (admittedly) not very deep understanding of NFS is
that this should not be worse in terms of (potential) caching problems
than a setup with a single server.

Any hint / comment is greatly appreciated.

Regards,
Niko
