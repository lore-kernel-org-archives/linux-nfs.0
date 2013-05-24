Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga02.intel.com ([134.134.136.20]:43143 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759148Ab3EXBi6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 May 2013 21:38:58 -0400
From: "Yong, Fan" <fan.yong@intel.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, Jim Rees <rees@umich.edu>
CC: Peng Tao <bergwolf@gmail.com>,
        "Dilger, Andreas" <andreas.dilger@intel.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Subject: RE: [PATCH] nfs: support 64-bit root inode number in NFS FSID
Date: Fri, 24 May 2013 01:30:23 +0000
Message-ID: <7FB055E0B36B6F4EB93E637E0640A56F5B4AAA67@FMSMSX114.amr.corp.intel.com>
References: <CDC2ABAC.3341C%andreas.dilger@intel.com>
 <CA+a=Yy4CQ7zG48dGOVjh8YBv0e+X1Gk4RxpDzdR4vM8JmqossQ@mail.gmail.com>
 <1369313382.3764.2.camel@leira.trondhjem.org>
 <7FB055E0B36B6F4EB93E637E0640A56F5B4AA961@FMSMSX114.amr.corp.intel.com>
 <1369316375.3764.7.camel@leira.trondhjem.org>
 <20130523142010.GA3634@umich.edu>
 <4FA345DA4F4AE44899BD2B03EEEC2FA928793571@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA928793571@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For the rare unfortunate cases of "sizeof(unsigned long) < 4" or "sizeof(unsigned long long) < 8", current nfs-utils will cross-boundary memory copy. So need more work to make it stably runnable on kinds of platform...

--
Cheers,
Nasf

-----Original Message-----
From: Myklebust, Trond [mailto:Trond.Myklebust@netapp.com] 
Sent: Thursday, May 23, 2013 10:22 PM
To: Jim Rees
Cc: Yong, Fan; Peng Tao; Dilger, Andreas; J. Bruce Fields; linux-nfs@vger.kernel.org; Steve Dickson
Subject: RE: [PATCH] nfs: support 64-bit root inode number in NFS FSID

> -----Original Message-----
> From: Jim Rees [mailto:rees@umich.edu]
> Sent: Thursday, May 23, 2013 10:20 AM
> To: Myklebust, Trond
> Cc: Yong, Fan; Peng Tao; Dilger, Andreas; J. Bruce Fields; linux- 
> nfs@vger.kernel.org; Steve Dickson
> Subject: Re: [PATCH] nfs: support 64-bit root inode number in NFS FSID
> 
> Myklebust, Trond wrote:
> 
>   On Thu, 2013-05-23 at 12:59 +0000, Yong, Fan wrote:
>   > Just make it match the "inode64" in nfs-utils parse_fsid(), which 
> is defined as "unsigned long long", and the parsed_fsid:: inode is copied from "inode64"
> as following:
>   >
>   > static int parse_fsid(int fsidtype, int fsidlen, char *fsid,
>   >                 struct parsed_fsid *parsed)
>   > {
>   >         unsigned int dev;
>   >         unsigned long long inode64;
>   > ...
>   >         case FSID_UUID16_INUM: /* 8 byte inode number and 16 byte uuid
> */
>   >                 if (fsidlen != 24)
>   >                         return -1;
>   >                 memcpy(&inode64, fsid, 8);
>   >                 parsed->inode = inode64;
>   >                 parsed->uuidlen = 16;
>   >                 parsed->fhuuid = fsid+8;
>   >                 break;
>   >         }
>   >
>   > --
>   > Cheers,
>   > Nasf
> 
>   Eeeeeeeewww! This is _exactly_ why we should be using properly
>   dimensioned types. Feel free to tell me how the value of 'inode64' is
>   well defined on systems where sizeof(unsigned long long) != 8...
> 
> Is there any reason not to use ino_t?

Yes. It's not guaranteed to be 64-bit either.

Trond
