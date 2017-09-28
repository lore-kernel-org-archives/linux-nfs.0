Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9256 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751082AbdI1THB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 15:07:01 -0400
Date: Thu, 28 Sep 2017 15:07:00 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 05/10] NFSD first draft of async copy
Message-ID: <20170928190659.GK10182@parsley.fieldses.org>
References: <20170928172945.50780-1-kolga@netapp.com>
 <20170928172945.50780-6-kolga@netapp.com>
 <20170928180703.GE10182@parsley.fieldses.org>
 <2E614129-E276-4E80-8A6D-161C1C3019DC@netapp.com>
 <20170928185509.GI10182@parsley.fieldses.org>
 <805B49AE-1DB0-4FB1-BEEB-84A7740E9B09@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <805B49AE-1DB0-4FB1-BEEB-84A7740E9B09@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 28, 2017 at 03:04:13PM -0400, Olga Kornievskaia wrote:
> 
> > On Sep 28, 2017, at 2:55 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > 
> > On Thu, Sep 28, 2017 at 02:44:42PM -0400, Olga Kornievskaia wrote:
> >> 
> >>> On Sep 28, 2017, at 2:07 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> >>> 
> >>> On Thu, Sep 28, 2017 at 01:29:40PM -0400, Olga Kornievskaia wrote:
> >>>> Asynchronous copies are handled by a single threaded workqueue.
> >>>> If we get asynchronous request, make sure to copy the needed
> >>>> arguments/state from the stack before starting the copy. Then
> >>>> queue work and reply back to the client indicating copy is
> >>>> asynchronous.
> >>>> 
> >>>> nfsd_copy_file_range() will copy in 4MBchunk so do a loop over
> >>>> the total number of bytes need to copy.
> >>> 
> >>> I don't think you need to do this--just call vfs_copy_file_range()
> >>> directly, as nfsd_copy_file_range does.
> >>> 
> >>> The 4MB chunking was only there to prevent a synchronous copy from
> >>> taking too long, which isn't an issue in the async case.
> >>> 
> >> 
> >> One reason is to allow for the copy to be cancelled in the “middle”.
> >> Otherwise, we have no control over once we call into the vfs_copy_file_range
> >> to stop the on-going copy. At least this way we check every 4MB chunks.
> > 
> > Yes, see my other email, I think we should signal the thread to stop it.
> > 
> > Even with copying in chunks--we'd like to be able to cancel the copy
> > mid-chunk.
> > 
> > Talking this over here with Jeff and Trond.... I don't *think* there's
> > an easy way to cancel a long-running work item.
> 
> Yes I believe I was looking into signaling but couldn’t figure out how to do it
> with the current code...
> 
> > So probably you want to create your own thread for the copy instead.  It
> > looks like kthread_create/kthread_stop/kthread_should_stop are what you
> > want?  You can see some examples if you "git grep kthread net/sunrpc”.
> 
> Ok so should I instead create a dedicated thread to do all copies and have 
> a way to give this thread work? Or are you ok with creating a thread for
> each individual copy which would be much simpler?

I'd be in favor of a thread per copy.  That should make the cancelling
either as well.

--b.
