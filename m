Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:51231 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750894AbbJQXWz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Oct 2015 19:22:55 -0400
Date: Sun, 18 Oct 2015 10:17:59 +1100
From: Dave Chinner <david@fromorbit.com>
To: Austin S Hemmelgarn <ahferroin7@gmail.com>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>, xfs@oss.sgi.com,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-cifs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v11 21/48] ext4: Add richacl feature flag
Message-ID: <20151017231759.GV27164@dastard>
References: <1445008706-15115-1-git-send-email-agruenba@redhat.com>
 <1445008706-15115-22-git-send-email-agruenba@redhat.com>
 <5621346E.5000500@gmail.com>
 <CAHc6FU7sR2zN-K3un74wCv+1NPnrqJ=LYiWo+YQ_2X0kopyoTQ@mail.gmail.com>
 <562141AD.60302@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <562141AD.60302@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 16, 2015 at 02:27:57PM -0400, Austin S Hemmelgarn wrote:
> On 2015-10-16 13:41, Andreas Gruenbacher wrote:
> >On Fri, Oct 16, 2015 at 7:31 PM, Austin S Hemmelgarn
> ><ahferroin7@gmail.com> wrote:
> >>I would like to re-iterate, on both XFS and ext4, I _really_ think this
> >>should be a ro_compat flag, and not an incompat one.  If a person has the
> >>ability to mount the FS (even if it's a read-only mount), then they by
> >>definition have read access to the file or partition that the filesystem is
> >>contained in, which means that any ACL's stored on the filesystem are
> >>functionally irrelevant,
> >
> >It is unfortunately not safe to make such a file system accessible to
> >other users, so the feature is not strictly read-only compatible.
> If it's not safe WRT data integrity, then the design needs to be
> reworked, as that directly implies that isn't safe for even every
> day usage on a writable filesystem.

This is exactly what we have *incompat feature flags for*: to
protect old code that doesn't know about potentially dangerous new
on-disk formats from trying to parse those formats and causing
unpredictable bad things from happening.

Austin, your arguments hold no weight because they are no different
to the considerations for any new on-disk feature: the user needs to
have both kernel and userspace support to recover filesystems that
go bad. If you are using a brand new fs/kernel feature, then it is
expected that you know that your DR processes take this into
account.

This is also why we XFS devs wait at least a year after new on-disk
features are merged into XFS before we consider turning them on by
default. i.e.  to give distros and recovery utilities time to pick
up kernels and userspace pacakges that support the new feature
before the average user will encounter it....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
