Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from outbound-smtp02.blacknight.com ([81.17.249.8]:33928 "EHLO
	outbound-smtp02.blacknight.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752134AbbG0LAL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jul 2015 07:00:11 -0400
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id AFE0098B90
	for <linux-nfs@vger.kernel.org>; Mon, 27 Jul 2015 10:52:18 +0000 (UTC)
Date: Mon, 27 Jul 2015 11:52:16 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] nfs: avoid swap-over-NFS deadlock
Message-ID: <20150727105216.GD2660@techsingularity.net>
References: <1437552643-18774-1-git-send-email-jmarchan@redhat.com>
 <CAHQdGtRXhUi+=akuASUWo-tYy0YCWJtUts6fqGnA62fo1Jf5tA@mail.gmail.com>
 <55AF9EA8.6020102@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
In-Reply-To: <55AF9EA8.6020102@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 22, 2015 at 03:46:16PM +0200, Jerome Marchand wrote:
> On 07/22/2015 02:23 PM, Trond Myklebust wrote:
> > On Wed, Jul 22, 2015 at 4:10 AM, Jerome Marchand <jmarchan@redhat.com> wrote:
> >>
> >> Lockdep warns about a inconsistent {RECLAIM_FS-ON-W} ->
> >> {IN-RECLAIM_FS-W} usage. The culpritt is the inode->i_mutex taken in
> >> nfs_file_direct_write(). This code was introduced by commit a9ab5e840669
> >> ("nfs: page cache invalidation for dio").
> >> This naive test patch avoid to take the mutex on a swapfile and makes
> >> lockdep happy again. However I don't know much about NFS code and I
> >> assume it's probably not the proper solution. Any thought?
> >>
> >> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
> > 
> > NFS is not the only O_DIRECT implementation to set the inode->i_mutex.
> > Why can't this be fixed in the generic swap code instead of adding
> > yet-another-exception-for-IS_SWAPFILE?
> 
> I meant to cc Mel. Just added him.
> 

Can the full lockdep warning be included as it'll be easier to see then if
the generic swap code can somehow special case this? Currently, generic
swapping does not not need to care about how the filesystem locked.
For most filesystems, it's writing directly to the blocks on disk and
bypassing the FS. In the NFS case it'd be surprising to find that there
also are dirty pages in page cache that belong to the swap file as it's
going to cause corruption. If there is any special casing it would to only
attempt the invalidation in the !swap case and warn if mapping->nrpages. It
still would look a bit weird but safer than just not acquiring the mutex
and then potentially attempting an invalidation.

-- 
Mel Gorman
SUSE Labs
