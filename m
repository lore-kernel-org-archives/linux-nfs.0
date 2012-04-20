Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63451 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751670Ab2DTUTS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 16:19:18 -0400
Message-ID: <4F91C49D.8070908@RedHat.com>
Date: Fri, 20 Apr 2012 16:18:37 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu,
        viro@ZenIV.linux.org.uk, hch@infradead.org,
        michael.brantley@deshaw.com, sven.breuner@itwm.fraunhofer.de,
        chuck.lever@oracle.com, pstaubach@exagrid.com, malahal@us.ibm.com,
        bfields@fieldses.org, trond.myklebust@fys.uio.no, rees@umich.edu
Subject: Re: [PATCH RFC v3] vfs: make fstatat retry once on ESTALE errors
 from getattr call
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com> <1334749927-26138-1-git-send-email-jlayton@redhat.com> <20120420104055.511e15bc@tlielax.poochiereds.net>
In-Reply-To: <20120420104055.511e15bc@tlielax.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/20/2012 10:40 AM, Jeff Layton wrote:
> I guess the questions at this point is:
> 
> 1) How representative is Peter's mkdir_test() of a real-world workload?
Reading your email I had to wonder the same thing... What application 
removes hierarchy of directories in a loop from two different clients?
I would suspect not many, if any... esp over NFS... 
 
> 
> 2) if we assume that it is fairly representative of one, how can we
> achieve retrying indefinitely with NFS, or at least some large finite
> amount?
The amount of looping would be peer speculation. If the problem can
not be handled by one simple retry I would say we simply pass the
error up to the app... Its an application issue... 
 
> 
> I have my doubts as to whether it would really be as big a problem for
> other filesystems as Miklos and others have asserted, but I'll take
> their word for it at the moment. What's the best way to contain this
> behavior to just those filesystems that want to retry indefinitely when
> they get an ESTALE? Would we need to go with an entirely new
> ESTALERETRY after all?
> 
Introducing a new errno to handle this problem would be overkill IMHO...

If we have to go to the looping approach, I would strong suggest we
make the file systems register for this type of behavior...

steved. 
