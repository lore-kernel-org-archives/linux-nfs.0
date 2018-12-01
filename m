Return-Path: <SRS0=P3M0=OK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0E5AC04EB9
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Dec 2018 22:00:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A04582081C
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Dec 2018 22:00:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A04582081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725745AbeLBJOW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 04:14:22 -0500
Received: from ipmail03.adl6.internode.on.net ([150.101.137.143]:20684 "EHLO
        ipmail03.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725736AbeLBJOW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Dec 2018 04:14:22 -0500
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail03.adl6.internode.on.net with ESMTP; 02 Dec 2018 08:30:48 +1030
Received: from dave by dastard with local (Exim 4.80)
        (envelope-from <david@fromorbit.com>)
        id 1gTDJd-0001JY-Q1; Sun, 02 Dec 2018 09:00:45 +1100
Date:   Sun, 2 Dec 2018 09:00:45 +1100
From:   Dave Chinner <david@fromorbit.com>
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        bfields@redhat.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Matthew Wilcox <willy@infradead.org>,
        Jeff Layton <jlayton@kernel.org>,
        Steve French <stfrench@microsoft.com>
Subject: Re: [PATCH v2 01/10] VFS generic copy_file_range() support
Message-ID: <20181201220045.GQ19305@dastard>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <20181130200348.59524-2-olga.kornievskaia@gmail.com>
 <CAOQ4uxjXGPOPQTsgKnMx7YN2S1Oz3MDbg5kDf0VV1rK+9Ybu8A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxjXGPOPQTsgKnMx7YN2S1Oz3MDbg5kDf0VV1rK+9Ybu8A@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Dec 01, 2018 at 10:11:48AM +0200, Amir Goldstein wrote:
> On Fri, Nov 30, 2018 at 10:04 PM Olga Kornievskaia
> <olga.kornievskaia@gmail.com> wrote:
> >
> > Relax the condition that input files must be from the same
> > file systems.
> >
> > Add checks that input parameters adhere semantics.
> >
> > If no copy_file_range() support is found, then do generic
> > checks for the unsupported page cache ranges, LFS, limits,
> > and clear setuid/setgid if not running as root before calling
> > do_splice_direct(). Update atime,ctime,mtime afterwards.
> >
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > ---
> 
> This patch is either going to bring you down or make you stronger ;-)
> 
> This is not how its done. Behavior change and refactoring mixed into
> one patch is wrong for several reasons. And when you relax same sb
> check you need to restrict it inside filesystems, like your previous patch
> did.
.....
> In any case, I hear that Dave is neck deep in fixing copy_file_range()
> so changes to this function should be collaborated with him. Or better
> yet, wait until he posts his fixes and carry on from there.

Yeah, because I've heard nothing for a month and this is kinda
important, I have a series of 8-9 patches that make all the fixes we
need, push the cross-filesystem checks down into the filesystems,
and let filesystems handle the fallback to a splice based copy
themselves (because there are way more fallback cases than just
EOPNOPSUPP and EXDEV).

I also have a patch for the man page that document all the missing
failure cases, and document where things are filesystem specific or
not.

And I also have a fstests patch that exercises all the failure cases
so that all filesystems will end up behaving the same way for all
the same cases they should.

I'm still sorting out the fstests patch (it requires changes
to xfs_io's copy-range command) so I've got some confidence that the
code actually does what it says in the man page, but I should have
that sorted in a couple of days.

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com
