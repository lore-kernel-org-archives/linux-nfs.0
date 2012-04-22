Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:62292 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924Ab2DVFk6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Apr 2012 01:40:58 -0400
Received: by qafi31 with SMTP id i31so1702029qaf.1
        for <linux-nfs@vger.kernel.org>; Sat, 21 Apr 2012 22:40:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120420171314.73801874@corrin.poochiereds.net>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<1334749927-26138-1-git-send-email-jlayton@redhat.com>
	<20120420104055.511e15bc@tlielax.poochiereds.net>
	<4F91C49D.8070908@RedHat.com>
	<20120420203725.GA3512@us.ibm.com>
	<20120420171314.73801874@corrin.poochiereds.net>
Date: Sun, 22 Apr 2012 07:40:57 +0200
Message-ID: <CAJfpegt40cgMJQQo3JuNaaS1w957Y2a_NxVoyvx3bmTMj1TGOA@mail.gmail.com>
Subject: Re: [PATCH RFC v3] vfs: make fstatat retry once on ESTALE errors from
 getattr call
From: Miklos Szeredi <miklos@szeredi.hu>
To: Jeff Layton <jlayton@redhat.com>
Cc: Malahal Naineni <malahal@us.ibm.com>, Steve Dickson <SteveD@redhat.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        hch@infradead.org, michael.brantley@deshaw.com,
        sven.breuner@itwm.fraunhofer.de, chuck.lever@oracle.com,
        pstaubach@exagrid.com, bfields@fieldses.org,
        trond.myklebust@fys.uio.no, rees@umich.edu
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 20, 2012 at 11:13 PM, Jeff Layton <jlayton@redhat.com> wrote:
> On Fri, 20 Apr 2012 15:37:26 -0500
> Malahal Naineni <malahal@us.ibm.com> wrote:
>
>> Steve Dickson [SteveD@redhat.com] wrote:
>> > > 2) if we assume that it is fairly representative of one, how can we
>> > > achieve retrying indefinitely with NFS, or at least some large finite
>> > > amount?
>> > The amount of looping would be peer speculation. If the problem can
>> > not be handled by one simple retry I would say we simply pass the
>> > error up to the app... Its an application issue...
>>
>> As someone said, ESTALE is an incorrect errno for a path based call.
>> How about turning ESTALE into ENOENT after a retry or few retries?
>>
>
> It's not really the same thing. One could envision an application
> that's repeatedly renaming a new file on top of another one. The file
> is never missing from the namespace of the server, but you could still
> end up getting an ESTALE.
>
> That would break other atomicity guarantees in an even worse way, IMO...

For directory operations ESTALE *is* equivalent to ENOENT if already
retrying with LOOKUP_REVAL.  Think about it.  Atomic replacement by
another directory with rename(2) is not an excuse here actually.
Local filesystems too can end up with IS_DEAD directory after lookup
in that case.

For non directories we basically have getattr and setattr.   NFSv4 can
handle both without retries if we supply the name instead of the
handle (i.e. i_op->getattr_by_name, i_op->setattr_by_name).  Other
protocols can do whatever they want, exponential backoff with limited
number of retries, whatever.

No looping required in the VFS.

Thanks,
Miklos
