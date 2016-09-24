Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yb0-f173.google.com ([209.85.213.173]:36630 "EHLO
        mail-yb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754261AbcIXAs2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2016 20:48:28 -0400
Received: by mail-yb0-f173.google.com with SMTP id u125so73484331ybg.3
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2016 17:48:27 -0700 (PDT)
Message-ID: <1474678106.29585.16.camel@redhat.com>
Subject: Re: [PATCH v3 0/5] add CB_NOTIFY_LOCK support to knfsd
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Date: Fri, 23 Sep 2016 20:48:26 -0400
In-Reply-To: <20160923210500.GA9998@fieldses.org>
References: <1474057707-31286-1-git-send-email-jlayton@redhat.com>
         <20160923210500.GA9998@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-09-23 at 17:05 -0400, J. Bruce Fields wrote:
> On Fri, Sep 16, 2016 at 04:28:22PM -0400, Jeff Layton wrote:
> > 
> > v3:
> > - add NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK in a separate patch
> > 
> > v2:
> > - small bugfixes
> > 
> > Very minor update to the patchset I sent a week or so ago. The only real
> > difference from the last is to move the addition of
> > NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK to a separate patch.
> > 
> > The basic idea is to just add support for CB_NOTIFY_LOCK callbacks,
> > which just tell the client that it may want to retry a lock again
> > once it becomes available.
> > 
> > Tested in conjunction with the corresponding client-side patch
> > series.
> 
> What sort of test were you doing?
> 

I did several: cthon (of course), the lockperf suite (which still takes
quite a while to run). Mostly I just verified that I got callbacks when
expected and that the client acted on them using wireshark. Some testing
under more load would be great.

> Have you checked with wireshark's CB_NOTIFY_LOCK support is complete?
> 

Just recently fixed:

https://code.wireshark.org/review/gitweb?p=wireshark.git;a=commitdiff;h=1948f7bd7553f215dc2519a35dcd62e29e35a614


> > 
> > 
> > Jeff Layton (5):
> >   nfsd: plumb in a CB_NOTIFY_LOCK operation
> >   nfsd: have nfsd4_lock use blocking locks for v4.1+ locks
> >   nfsd: add a LRU list for blocked locks
> >   nfs: add a new NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK constant
> >   nfsd: set the MAY_NOTIFY_LOCK flag in OPEN replies
> > 
> >  fs/nfsd/netns.h           |   1 +
> >  fs/nfsd/nfs4callback.c    |  57 ++++++++++++
> >  fs/nfsd/nfs4state.c       | 232 ++++++++++++++++++++++++++++++++++++++++++----
> >  fs/nfsd/state.h           |  21 ++++-
> >  fs/nfsd/xdr4cb.h          |   9 ++
> >  include/uapi/linux/nfs4.h |   5 +-
> >  6 files changed, 301 insertions(+), 24 deletions(-)
> > 
> > -- 
> > 2.7.4

-- 
Jeff Layton <jlayton@redhat.com>
