Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38059 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751833Ab2DZNqv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 09:46:51 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAH2r5muMb8m9-fMc_tcfn3ku_s55q9EEbc-vzvoFjPnsDdq1gA@mail.gmail.com>
References: <CAH2r5muMb8m9-fMc_tcfn3ku_s55q9EEbc-vzvoFjPnsDdq1gA@mail.gmail.com> <20120419140558.17272.74360.stgit@warthog.procyon.org.uk> <20120419140612.17272.57774.stgit@warthog.procyon.org.uk> <20120424212911.GA26073@fieldses.org>
To: Steve French <smfrench@gmail.com>
Cc: dhowells@redhat.com, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org, wine-devel@winehq.org, kfm-devel@kde.org,
        nautilus-list@gnome.org, linux-api@vger.kernel.org,
        libc-alpha@sourceware.org
Subject: Re: [PATCH 1/6] xstat: Add a pair of system calls to make extended file stats available
Date: Thu, 26 Apr 2012 14:45:54 +0100
Message-ID: <18765.1335447954@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve French <smfrench@gmail.com> wrote:

> I also would prefer that we simply treat the time granularity as part
> of the superblock (mounted volume) ie returned on fstat rather than on
> every stat of the filesystem.   For cifs mounts we could conceivably
> have different time granularity (1 or 2 second) on mounts to old
> servers rather than 100 nanoseconds.

The question is whether you want to have to do a statfs in addition to a stat?
I suppose you can potentially cache the statfs based on device number.

That said, there are cases where caching filesystem-level info based on i_dev
doesn't work.  OpenAFS springs to mind as that only has one superblock and
thus one set of device numbers, but keeps all the inodes for all the different
volumes it may have mounted there.

I don't know whether this would be a problem for CIFS too - say on a windows
server you fabricate P:, for example, by joining together several filesystems
(with junctions?).  How does this appear on a Linux client when it steps from
one filesystem to another within a mounted share?

David
