Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33679 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbcFAUbX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2016 16:31:23 -0400
Received: by mail-it0-f68.google.com with SMTP id v125so226700itc.0
        for <linux-nfs@vger.kernel.org>; Wed, 01 Jun 2016 13:31:23 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 1 Jun 2016 16:31:22 -0400
Message-ID: <CAN-5tyFXzH+Je8Th_irarJtBb+9QziFj8p7xH0NRLupOsTYBrw@mail.gmail.com>
Subject: open_downgrade use
From: Olga Kornievskaia <aglo@umich.edu>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm failing to think of what can trigger an open_downgrade?
I thought the following example should trigger an open downgrade:

fd0 = open(foo, RDRW)   -- should be open on the wire for "both"
fd1 = open(foo, RDONLY)  -- should be open on the wire for "read"
close(fd0) -- should trigger an open_downgrade
read(fd1)
close(fd1)

However this commit says that it's not allowed by the spec.

commit cd9288ffaea4359d5cfe2b8d264911506aed26a4
Author: Trond Myklebust <trond.myklebust@primarydata.com>
Date:   Thu Sep 18 11:51:32 2014 -0400

    NFSv4: Fix another bug in the close/open_downgrade code

    James Drew reports another bug whereby the NFS client is now sending
    an OPEN_DOWNGRADE in a situation where it should really have sent a
    CLOSE: the client is opening the file for O_RDWR, but then trying to
    do a downgrade to O_RDONLY, which is not allowed by the NFSv4 spec.

    Reported-by: James Drews <drews@engr.wisc.edu>
    Link: http://lkml.kernel.org/r/541AD7E5.8020409@engr.wisc.edu
    Fixes: aee7af356e15 (NFSv4: Fix problems with close in the presence...)
    Cc: stable@vger.kernel.org # 2.6.33+
    Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

If RDWR to RDONLY isn't allowed then why do we have OPEN_DOWNGRADE at all?
