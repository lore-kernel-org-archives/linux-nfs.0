Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27503 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752299AbdECPto (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 May 2017 11:49:44 -0400
Date: Wed, 3 May 2017 08:48:39 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Eryu Guan <eguan@redhat.com>, fstests@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v5 0/5] Add copy_file_range() tests
Message-ID: <20170503154839.GF5975@birch.djwong.org>
References: <20170317195233.4042-1-Anna.Schumaker@Netapp.com>
 <20170317220246.GA12585@birch.djwong.org>
 <20170320052457.GH14226@eguan.usersys.redhat.com>
 <20170502221649.GA5970@birch.djwong.org>
 <CAN-5tyGaaPrHSmxNGYWfsbxNECKE1NZz9bp4shy-kQDs2D=MrQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyGaaPrHSmxNGYWfsbxNECKE1NZz9bp4shy-kQDs2D=MrQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 03, 2017 at 08:56:11AM -0400, Olga Kornievskaia wrote:
> On Tue, May 2, 2017 at 6:16 PM, Darrick J. Wong <darrick.wong@oracle.com> wrote:
> > On Mon, Mar 20, 2017 at 01:24:57PM +0800, Eryu Guan wrote:
> >> On Fri, Mar 17, 2017 at 03:02:46PM -0700, Darrick J. Wong wrote:
> >> > On Fri, Mar 17, 2017 at 03:52:28PM -0400, Anna Schumaker wrote:
> >> > > These tests exercise the copy_file_range() system call, and check copying
> >> > > data to both a new file and overwriting data inside an existing file.
> >> > >
> >> > > Sorry it took so long to get this version out.  I forgot about these patches
> >> > > after the last submission.
> >> >
> >> > Hooray, tests finally!
> >> >
> >> > I had to bump the numbers up due to conflicts (it's usually best to pick
> >> > a really high number and let Eryu mvtest them to their real numbers),
> >> > but these mostly look ok.
> >>
> >> Usually the test numbers are not a problem, as long as the patchset is
> >> based on latest master and there's no test number conflicts :)
> >>
> >> Overall the tests look fine to me too.
> >>
> >> >
> >> > However, I do see that something isn't triggering an EINVAL return code:
> >>
> >> Same results here, tested with xfs/ext4/btrfs on 4.11-rc2 kernel.
> >>
> >> And another nitpick is the year in copyright, s/2016/2017/ ?
> >
> > Another month, another kernel release... can we please get these tests
> > fixed and integrated?
> >
> 
> I'm curious when you say "testing with btrfs" does it mean NFS server
> exporting btrfs or does it mean just local btrfs?

Local btrfs, xfs, and ext4.

--D

> 
> > --D
> >
> >>
> >> Thanks,
> >> Eryu
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe fstests" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
