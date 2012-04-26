Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39397 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752700Ab2DZO2h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 10:28:37 -0400
Date: Thu, 26 Apr 2012 10:28:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: David Howells <dhowells@redhat.com>
Cc: Steve French <smfrench@gmail.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: [PATCH 1/6] xstat: Add a pair of system calls to make extended
 file stats available
Message-ID: <20120426142816.GB7176@fieldses.org>
References: <CAH2r5muMb8m9-fMc_tcfn3ku_s55q9EEbc-vzvoFjPnsDdq1gA@mail.gmail.com>
 <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
 <20120419140612.17272.57774.stgit@warthog.procyon.org.uk>
 <20120424212911.GA26073@fieldses.org>
 <18765.1335447954@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <18765.1335447954@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 26, 2012 at 02:45:54PM +0100, David Howells wrote:
> Steve French <smfrench@gmail.com> wrote:
> 
> > I also would prefer that we simply treat the time granularity as part
> > of the superblock (mounted volume) ie returned on fstat rather than on
> > every stat of the filesystem.   For cifs mounts we could conceivably
> > have different time granularity (1 or 2 second) on mounts to old
> > servers rather than 100 nanoseconds.
> 
> The question is whether you want to have to do a statfs in addition to a stat?
> I suppose you can potentially cache the statfs based on device number.
> 
> That said, there are cases where caching filesystem-level info based on i_dev
> doesn't work.  OpenAFS springs to mind as that only has one superblock and
> thus one set of device numbers, but keeps all the inodes for all the different
> volumes it may have mounted there.
> 
> I don't know whether this would be a problem for CIFS too - say on a windows
> server you fabricate P:, for example, by joining together several filesystems
> (with junctions?).  How does this appear on a Linux client when it steps from
> one filesystem to another within a mounted share?

In the NFS case we do try to preserve filesystem boundaries as well as
we can--the protocol has an fsid field and the client creates a new
mount each time it sees it change.  And the protocol defines time_delta
as a per-filesystem attribute (though, somewhat hilariously, there's
also a per-filesystem "homogeneous" attribute that a server can clear to
indicate the per-filesystem attributes might actually vary within the
filesystem.)

--b.
