Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42600 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1161142AbcIZQDa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 26 Sep 2016 12:03:30 -0400
Date: Mon, 26 Sep 2016 12:03:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 0/5] add CB_NOTIFY_LOCK support to knfsd
Message-ID: <20160926160317.GA7235@fieldses.org>
References: <1474057707-31286-1-git-send-email-jlayton@redhat.com>
 <20160923210500.GA9998@fieldses.org>
 <1474678106.29585.16.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1474678106.29585.16.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 23, 2016 at 08:48:26PM -0400, Jeff Layton wrote:
> On Fri, 2016-09-23 at 17:05 -0400, J. Bruce Fields wrote:
> > On Fri, Sep 16, 2016 at 04:28:22PM -0400, Jeff Layton wrote:
> > > 
> > > v3:
> > > - add NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK in a separate patch
> > > 
> > > v2:
> > > - small bugfixes
> > > 
> > > Very minor update to the patchset I sent a week or so ago. The only real
> > > difference from the last is to move the addition of
> > > NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK to a separate patch.
> > > 
> > > The basic idea is to just add support for CB_NOTIFY_LOCK callbacks,
> > > which just tell the client that it may want to retry a lock again
> > > once it becomes available.
> > > 
> > > Tested in conjunction with the corresponding client-side patch
> > > series.
> > 
> > What sort of test were you doing?
> > 
> 
> I did several: cthon (of course), the lockperf suite (which still takes
> quite a while to run). Mostly I just verified that I got callbacks when
> expected and that the client acted on them using wireshark. Some testing
> under more load would be great.
> 
> > Have you checked with wireshark's CB_NOTIFY_LOCK support is complete?
> > 
> 
> Just recently fixed:
> 
> https://code.wireshark.org/review/gitweb?p=wireshark.git;a=commitdiff;h=1948f7bd7553f215dc2519a35dcd62e29e35a614

Excellent, thanks!

--b.
