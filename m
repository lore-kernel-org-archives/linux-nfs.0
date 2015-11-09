Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34791 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751731AbbKIVbl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Nov 2015 16:31:41 -0500
Date: Mon, 9 Nov 2015 16:31:41 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH] Using pthreads to handle upcalls.
Message-ID: <20151109213141.GD11046@fieldses.org>
References: <1447074308-15823-1-git-send-email-steved@redhat.com>
 <20151109183938.GD8738@fieldses.org>
 <5640FDF2.9040802@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5640FDF2.9040802@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 09, 2015 at 03:11:30PM -0500, Steve Dickson wrote:
> Hey,
> 
> On 11/09/2015 01:39 PM, J. Bruce Fields wrote:
> > On Mon, Nov 09, 2015 at 08:05:07AM -0500, Steve Dickson wrote:
> >> Recently a bug was found that was causing a
> >> TGT fetch for every mount upcall. The bug was
> >> caused when forking for every mount was introduce.
> >> The global memory for the TGT cache was being
> >> freed when the forked process existed. 
> >>
> >> The fix we came up with was to only fork on non-root
> >> upcalls, basically mount upcalls would no longer fork.
> >> In debugging the patch it became apparent that if the
> >> process hung, all NFS mounts on that client would be blocked.
> >> So at this point rpc.gssd is a single point of failure.
> >>
> >> This patch replaces the forking/non-forking with creating
> >> pthreads for every upcall which I think is a better 
> >> solution to the original problem since pthreads can share
> >> global data. 
> > 
> > I seem to recall the reason for the fork is to allow dropping some
> > privileges while processing the upcall, is that right? 
> I don't see this where privileges are being dropped. 

See 6b53fc9ce38ba6fff2fd5c2f6ed143747067a39d "gssd: do a more thorough
change of identity after forking".  I think the id's its switching there
are global to a process, not specific to a single pthread.

> >> I was also hoping using pthread would bring more asynchronous
> >> to rpc.gssd. I was thinking rpc.gssd could take an upcall,
> >> fire off a thread to handle it, the go back and listen
> >> for more upcalls. 
> >>
> >> Unfortunately this is not the case. It seems, maybe due to
> >> my lack of my pthreads understanding, that after each 
> >> pthread_create() call, a pthread_join() call, which waits for 
> >> the created to stop, is needed. Similar to fork/wait..
> > 
> > Actually making gssd thread-safe would be a significant effort.
> Is it because the MIT libs are not thread-safe?

I don't know, it's one of many things we'd need to check.

> Isn't the gssd_k5_kt_princ_list the only global list?  Something to do
> with the upcalls? 

There's also some global data that keeps track of the state of the rpc
pipefs directory--topdir_list, etc.

It might be easier just to share that one list?  I don't know what would
be involved, though.

I'm not convinced this is a good way to help with hangs--a lot of the
cases that would cause a hang are going to cause further threads to hang
too.

I can believe the parallelism might be useful in some cases for
performance reasons, but I don't know if we've seen such a case yet.

--b.
