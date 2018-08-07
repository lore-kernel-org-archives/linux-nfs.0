Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45306 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726414AbeHGXcm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Aug 2018 19:32:42 -0400
Date: Tue, 7 Aug 2018 17:16:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tom Tucker <tom@opengridcomputing.com>
Cc: Cedric Blancher <cedric.blancher@gmail.com>,
        Peter Scott <pjscott@jpl.nasa.gov>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 file lock reporting interface request
Message-ID: <20180807211624.GB18903@fieldses.org>
References: <8dd8a352-aaca-71af-aca7-9be6c7039ff4@jpl.nasa.gov>
 <CALXu0UdHWGOnMYk-xGG6_GWGfdpXffc0U-+Ark0joEYvhPSh_g@mail.gmail.com>
 <20180807203419.GB18415@fieldses.org>
 <f72df1af-1d8e-9203-0587-0e7b4a7db9aa@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <f72df1af-1d8e-9203-0587-0e7b4a7db9aa@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 07, 2018 at 04:05:42PM -0500, Tom Tucker wrote:
> FWIW, I don't think dtrace does/did what NASA is asking for, but
> that's really irrelevant. The locks in NFSv4 are application
> specific locks, not generic kernel locks, so a service looking for
> spinlocks, mutexes, etc... wouldn't really be helpful I don't
> think.  However implementing a /sys/class, debugfs thingy that
> dumped the nfsv4 locks held is fairly simple, although I would think
> there are security implications.

We already have /proc/locks for locks taken by regular applications, it
just misses locks from nfsd.

We could extend that.  But /proc/locks has some other problems and best
is probably to make a list of those and make sure we address them all at
once.  It's a potential woodshedding exercise.  I haven't done any work
on it.

Alternatively I guess we could make a separate interface just for file
locks held by knfsd.

--b.
