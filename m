Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31469 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751000AbdEaPLb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 May 2017 11:11:31 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: client recovery when server no longer supports NFSv4.1
Date: Wed, 31 May 2017 11:11:18 -0400
Message-Id: <A24594C9-0164-4A91-A38E-9ADFEABC5F38@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trondmy@primarydata.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

There's some internal testing going on here where a Linux NFS client
mounts a server with NFSv4.1, then the server is rebooted with older
software that supports only NFSv4.0. We're looking at how the client
responds to this odd corner case.

Active I/O system calls on that mount complete with "Protocol not
supported". I wasn't sure if this was a permitted error code for
write(2), stat(2), or getdents(3).

Another question is what happens when the server reboots again and
it supports NFSv4.1 again. Our testing shows the mount starts to
work again. But we're wondering if it's possible for open or lock
state to remain on the client after the first reboot, and if so,
is there any guarantee that state can be properly recovered by the
client when the server supports NFSv4.1 again.

Our feeling is that it can't. Perhaps the client should make that
mount point unusable after the first server reboot?

This feels like a state recovery edge condition, perhaps not
covered by RFC 5661 and newer.


--
Chuck Lever



