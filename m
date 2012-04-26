Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6320 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751833Ab2DZNlB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 09:41:01 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20120424212911.GA26073@fieldses.org>
References: <20120424212911.GA26073@fieldses.org> <20120419140558.17272.74360.stgit@warthog.procyon.org.uk> <20120419140612.17272.57774.stgit@warthog.procyon.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: [PATCH 1/6] xstat: Add a pair of system calls to make extended file stats available
Date: Thu, 26 Apr 2012 14:40:17 +0100
Message-ID: <18533.1335447617@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields <bfields@fieldses.org> wrote:

> > (11) Include granularity fields in the time data to indicate the
> >      granularity of each of the times (NFSv4 time_delta) [Steve French].
> 
> It looks like you're including this with *each* time?  But surely
> there's no filesystem with different granularity (say) for ctime than
> for mtime.

I put it in each time struct to use up the hole there.  I could, I suppose,
split tv_sec from tv_nsec to get rid of the holes and then put the granularity
separately.  That means that someone who wanted both the tv_sec and tv_nsec
would have to fish them out separately, but that's probably okay.

I could even make the granularity bigger then, to allow for the possibility of
having a granularity >4s, but I don't know of anywhere that requires a gran >2.

> Also, nfsd will want only one time_delta, not one for each time.

time_delta?  Is that the same as granularity?

> Note also we need to document carefully what this means: I think it
> should be the granularity that the filesystem is capable of
> representing, but people are sometimes surprised to find out that the
> actual time source is usually more coarse-grained than that.

Yeah, but the latter is something you may not be able to determine, and may
indeed change over time (say someone updates the server kernel to one with a
more fine-grained software clock).  Also, for a network fs, it may depend on
the client that happened to set that time last.

David
