Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f43.google.com ([209.85.192.43]:65402 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756552AbaDWSsL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Apr 2014 14:48:11 -0400
Received: by mail-qg0-f43.google.com with SMTP id a108so1393930qge.2
        for <linux-nfs@vger.kernel.org>; Wed, 23 Apr 2014 11:48:10 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH 1/3] nfs4: treat lock owners as opaque values
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1398277500-31575-2-git-send-email-jlayton@redhat.com>
Date: Wed, 23 Apr 2014 14:48:08 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <1A139D9F-E986-4854-8C15-AB1332880E29@primarydata.com>
References: <1398277500-31575-1-git-send-email-jlayton@redhat.com> <1398277500-31575-2-git-send-email-jlayton@redhat.com>
To: Layton Jeff <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 23, 2014, at 14:24, Jeff Layton <jlayton@redhat.com> wrote:

> Do the following set of ops with a file on a NFSv4 mount:
> 
>    exec 3>>$1
>    flock -x 3
>    exec 3>&-
> 
> You'll see the LOCK request go across the wire, but no LOCKU when the
> file is closed. This leads to
> 
> What happens is that the fd is passed across a fork, and the final close
> is done in a different process than the opener. That makes
> __nfs4_find_lock_state miss finding the correct lock state because it
> uses the fl_pid as a search key. A new one is created, and the locking
> code treats it as a delegation stateid (because NFS_LOCK_INITIALIZED
> isn't set).
> 
> The root cause of this breakage seems to be commit 77041ed9b49a9e
> (NFSv4: Ensure the lockowners are labelled using the fl_owner and/or
> fl_pid).
> 
> That changed it so that flock lockowners are allocated based on the
> fl_pid. I think this is incorrect. flock locks should be "owned" by the
> struct file, and that is already accounted for in the fl_owner field of
> the lock request when the vfs layer passes it down.

NACKed for now.

I'll grant you that there are several nice potential cleanups here, but as far as I can tell, flock_make_lock() never sets fl_owner, and neither does anything else in sys_flock().

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

