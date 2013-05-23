Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:47332 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758671Ab3EWNjn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 May 2013 09:39:43 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Yong, Fan" <fan.yong@intel.com>
CC: Peng Tao <bergwolf@gmail.com>,
        "Dilger, Andreas" <andreas.dilger@intel.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH] nfs: support 64-bit root inode number in NFS FSID
Date: Thu, 23 May 2013 13:39:40 +0000
Message-ID: <1369316375.3764.7.camel@leira.trondhjem.org>
References: <CDC2ABAC.3341C%andreas.dilger@intel.com>
	 <CA+a=Yy4CQ7zG48dGOVjh8YBv0e+X1Gk4RxpDzdR4vM8JmqossQ@mail.gmail.com>
	 <1369313382.3764.2.camel@leira.trondhjem.org>
	 <7FB055E0B36B6F4EB93E637E0640A56F5B4AA961@FMSMSX114.amr.corp.intel.com>
In-Reply-To: <7FB055E0B36B6F4EB93E637E0640A56F5B4AA961@FMSMSX114.amr.corp.intel.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-05-23 at 12:59 +0000, Yong, Fan wrote:
> Just make it match the "inode64" in nfs-utils parse_fsid(), which is defined as "unsigned long long", and the parsed_fsid:: inode is copied from "inode64" as following:
> 
> static int parse_fsid(int fsidtype, int fsidlen, char *fsid,
>                 struct parsed_fsid *parsed)
> {
>         unsigned int dev;
>         unsigned long long inode64;
> ...
>         case FSID_UUID16_INUM: /* 8 byte inode number and 16 byte uuid */
>                 if (fsidlen != 24)
>                         return -1;
>                 memcpy(&inode64, fsid, 8);
>                 parsed->inode = inode64;
>                 parsed->uuidlen = 16;
>                 parsed->fhuuid = fsid+8;
>                 break;
>         }
> 
> --
> Cheers,
> Nasf

Eeeeeeeewww! This is _exactly_ why we should be using properly
dimensioned types. Feel free to tell me how the value of 'inode64' is
well defined on systems where sizeof(unsigned long long) != 8...

Trond

> -----Original Message-----
> From: Myklebust, Trond [mailto:Trond.Myklebust@netapp.com] 
> Sent: Thursday, May 23, 2013 8:50 PM
> To: Peng Tao
> Cc: Dilger, Andreas; J. Bruce Fields; linux-nfs@vger.kernel.org; Yong, Fan; Steve Dickson
> Subject: Re: [PATCH] nfs: support 64-bit root inode number in NFS FSID
> 
> On Thu, 2013-05-23 at 16:12 +0800, Peng Tao wrote:
> > [nfs-utils patch needs to be sent to Steve Dickson (CC'ed)]
> > 
> > On Thu, May 23, 2013 at 7:06 AM, Dilger, Andreas 
> > <andreas.dilger@intel.com> wrote:
> > > When exporting a filesystem via NFS, it can generate several kinds 
> > > of NFS filesystem IDs. For most of cases, it uses a 32-bit inode 
> > > number in the NFS FSID, but this does not work on a filesystem using 
> > > a 64-bit root inode number.
> > >
> > > In kernel space, NFS can generate/use NFS FSID with a 64-bit inode 
> > > number for the "FSID_UUID16_INUM" type. Unfortunately, while the 
> > > user space nfs-utils decode the 64-bit inode number from the FSID 
> > > correctly, it is truncated when storing it in "struct parsed_fsid".
> > > Expand the "struct parsed_fsid" inode field to store the full 64-bit 
> > > root inode number.
> > >
> > > Intel-bug-id: LU-2904
> > > Signed-off-by: Fan Yong <fan.yong@intel.com>
> > > Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
> > > ---
> > >  utils/mountd/cache.c |    2 +-
> > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > >
> > > diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c index 
> > > 517aa62..a7212e7 100644
> > > --- a/utils/mountd/cache.c
> > > +++ b/utils/mountd/cache.c
> > > @@ -388,7 +388,7 @@ struct parsed_fsid {
> > >         int fsidtype;
> > >         /* We could use a union for this, but it would be more
> > >          * complicated; why bother? */
> > > -       unsigned int inode;
> > > +       unsigned long long inode; /* We need 64-bits ino# */
> > >         unsigned int minor;
> > >         unsigned int major;
> > >         unsigned int fsidnum;
> > > --1.7.1
> > >
> > > Patch is also attached separately, since it will likely be butchered 
> > > by this email client.
> > >
> > >
> > > Cheers, Andreas
> > > --
> > > Andreas Dilger
> 
> Why not just specify a uint64_t size then?
> 
> --
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
