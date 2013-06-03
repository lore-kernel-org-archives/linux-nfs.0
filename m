Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga11.intel.com ([192.55.52.93]:59141 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756631Ab3FCB7f convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Jun 2013 21:59:35 -0400
From: "Yong, Fan" <fan.yong@intel.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Dilger, Andreas" <andreas.dilger@intel.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <steved@redhat.com>,
        "Peng Tao (bergwolf@gmail.com)" <bergwolf@gmail.com>
Subject: RE: [PATCH] nfs: support 64-bit root inode number in NFS FSID
Date: Mon, 3 Jun 2013 01:59:34 +0000
Message-ID: <7FB055E0B36B6F4EB93E637E0640A56F5FBF18D4@FMSMSX114.amr.corp.intel.com>
References: <CDC2ABAC.3341C%andreas.dilger@intel.com>
	 <CA+a=Yy4CQ7zG48dGOVjh8YBv0e+X1Gk4RxpDzdR4vM8JmqossQ@mail.gmail.com>
 <1369313382.3764.2.camel@leira.trondhjem.org>
In-Reply-To: <1369313382.3764.2.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update the patch as suggested.

--
Cheers,
Nasf



-----Original Message-----
From: Myklebust, Trond [mailto:Trond.Myklebust@netapp.com] 
Sent: Thursday, May 23, 2013 8:50 PM
To: Peng Tao
Cc: Dilger, Andreas; J. Bruce Fields; linux-nfs@vger.kernel.org; Yong, Fan; Steve Dickson
Subject: Re: [PATCH] nfs: support 64-bit root inode number in NFS FSID

On Thu, 2013-05-23 at 16:12 +0800, Peng Tao wrote:
> [nfs-utils patch needs to be sent to Steve Dickson (CC'ed)]
> 
> On Thu, May 23, 2013 at 7:06 AM, Dilger, Andreas 
> <andreas.dilger@intel.com> wrote:
> > When exporting a filesystem via NFS, it can generate several kinds 
> > of NFS filesystem IDs. For most of cases, it uses a 32-bit inode 
> > number in the NFS FSID, but this does not work on a filesystem using 
> > a 64-bit root inode number.
> >
> > In kernel space, NFS can generate/use NFS FSID with a 64-bit inode 
> > number for the "FSID_UUID16_INUM" type. Unfortunately, while the 
> > user space nfs-utils decode the 64-bit inode number from the FSID 
> > correctly, it is truncated when storing it in "struct parsed_fsid".
> > Expand the "struct parsed_fsid" inode field to store the full 64-bit 
> > root inode number.
> >
> > Intel-bug-id: LU-2904
> > Signed-off-by: Fan Yong <fan.yong@intel.com>
> > Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
> > ---
> >  utils/mountd/cache.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >
> > diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c index 
> > 517aa62..a7212e7 100644
> > --- a/utils/mountd/cache.c
> > +++ b/utils/mountd/cache.c
> > @@ -388,7 +388,7 @@ struct parsed_fsid {
> >         int fsidtype;
> >         /* We could use a union for this, but it would be more
> >          * complicated; why bother? */
> > -       unsigned int inode;
> > +       unsigned long long inode; /* We need 64-bits ino# */
> >         unsigned int minor;
> >         unsigned int major;
> >         unsigned int fsidnum;
> > --1.7.1
> >
> > Patch is also attached separately, since it will likely be butchered 
> > by this email client.
> >
> >
> > Cheers, Andreas
> > --
> > Andreas Dilger

Why not just specify a uint64_t size then?

--
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
