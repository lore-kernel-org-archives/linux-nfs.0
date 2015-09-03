Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:35029 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001AbbICT05 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Sep 2015 15:26:57 -0400
Received: by ioiz6 with SMTP id z6so70233291ioi.2
        for <linux-nfs@vger.kernel.org>; Thu, 03 Sep 2015 12:26:57 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 3 Sep 2015 15:26:56 -0400
Message-ID: <CAN-5tyEmSD2wwu+M9UURq5MWOZTDqdp18TnmTSiQCc04mSvJmA@mail.gmail.com>
Subject: async CLOSE creates a race with a DELEGRETURN followed by a REMOVE
From: Olga Kornievskaia <aglo@umich.edu>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When file is opened with O_DIRECT, sending asynchronous CLOSE creates
a race condition between CLOSE and DELEGRETURN followed REMOVE. Next
operations are sent before the reply for CLOSE comes back which is
according to the spec is not allowed (section 10.4.4). Server can get
a REMOVE before the CLOSE and it causes EACCESS error to be returned
because server thinks there is open state left.

According to the spec: "...whenever a client chooses to return a
delegation voluntarily.  The following items of state need to be dealt
with:

   o  If the file associated with the delegation is no longer open and
      no previous CLOSE operation has been sent to the server, a CLOSE
      operation must be sent to the server."

So i'm not sure if it will be argued that it doesn't say that a reply
must be received before sending the DELEGRETURN. However, if it's not
mandated then a race as I'm mentioning occurs.

The following patch introduces making close async:
commit f895c53f8ace3c3e49ebf9def90e63fc6d46d2bf
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Feb 1 14:17:50 2010 -0500

    NFS: Make close(2) asynchronous when closing NFS O_DIRECT files

    For NFSv2 and v3:

    O_DIRECT writes are always synchronous, and aren't cached, so nothing
    should be flushed when closing an NFS O_DIRECT file descriptor.  Thus
    there are no write errors to report on close(2).

    In addition, there's no cached data to verify on the next open(2),
    so we don't need clean GETATTR results at close time to compare with.

    Thus, there's no need for the nfs_revalidate_inode() call when closing
    an NFS O_DIRECT file.  This reduces the number of synchronous
    on-the-wire requests for a simple open-write-close of an NFS O_DIRECT
    file by roughly 20%.

    For NFSv4:

    Call nfs4_do_close() with wait set to zero when closing an NFS
    O_DIRECT file.  The CLOSE will go on the wire, but the application
    won't wait for it to complete.

I'd like to suggest to revert the use of this patch.
