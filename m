Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f41.google.com ([209.85.216.41]:64843 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716AbaDWBXV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Apr 2014 21:23:21 -0400
Received: by mail-qa0-f41.google.com with SMTP id j5so267228qaq.14
        for <linux-nfs@vger.kernel.org>; Tue, 22 Apr 2014 18:23:21 -0700 (PDT)
Date: Tue, 22 Apr 2014 21:23:17 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: question about old flock() on nfsv4 commit
Message-ID: <20140422212317.3f18689a@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond.

I'm looking at a flock() on nfsv4 problem, where I'm not seeing unlock
requests go out in some cases (mostly when a filp is inherited across
fork() and the last close is done by a different process than the
opener.

I have a question about this commit:

-------------------------

commit 77041ed9b49a9e10f374bfa6e482d30ee7a3d46e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jul 1 12:49:11 2010 -0400

    NFSv4: Ensure the lockowners are labelled using the fl_owner and/or fl_pid
    
    flock locks want to be labelled using the process pid, while posix locks
    want to be labelled using the fl_owner.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

-------------------------

I don't get it...why does the pid have any relevance here? Shouldn't
these locks be associated with the struct file? If so, then that's
already accounted for in the fl_owner_t when it comes down from the vfs.

It seems like we ought to let the vfs manage who owns the lock and just
treat that owner opaquely in the NFS code. Am I missing something?

Thanks,
-- 
Jeff Layton <jlayton@poochiereds.net>
