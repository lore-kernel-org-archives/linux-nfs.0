Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:45291 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496Ab1INP7Q convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Sep 2011 11:59:16 -0400
From: <tao.peng@emc.com>
To: <bhalevy@tonian.com>
CC: <rees@umich.edu>, <linux-nfs@vger.kernel.org>
Date: Wed, 14 Sep 2011 11:56:27 -0400
Subject: RE: NULL pointer dereference during mount
Message-ID: <F19688880B763E40B28B2B462677FBF805C3F37B8F@MX09A.corp.emc.com>
References: <F19688880B763E40B28B2B462677FBF805C3299FFE@MX09A.corp.emc.com>,<20110913124202.GA9498@merit.edu>
 <F19688880B763E40B28B2B462677FBF805C3F37B8D@MX09A.corp.emc.com>
 <4E704999.1060205@tonian.com>,<F19688880B763E40B28B2B462677FBF805C3F7A912@MX09A.corp.emc.com>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805C3F7A912@MX09A.corp.emc.com>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, Benny,

OK, I found the problem. It is because I was building nfs module, instead of rebuilding the whole kernel. commit bea6cd74 in pnfs-all-latest branch changes struct super_block by adding s_pnfs_op pointer. Then sb->s_security of the new module is translated into accessing sb->s_xattr, which is NULL, and causes the oops.

After rebuilding the kernel, I don't get it any more. Sorry for the noise...

Cheers,
Tao
________________________________________
From: linux-nfs-owner@vger.kernel.org [linux-nfs-owner@vger.kernel.org] On Behalf Of tao.peng@emc.com [tao.peng@emc.com]
Sent: Wednesday, September 14, 2011 3:53 PM
To: bhalevy@tonian.com
Cc: rees@umich.edu; linux-nfs@vger.kernel.org
Subject: RE: NULL pointer dereference during mount

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org]
> On Behalf Of Benny Halevy
> Sent: Wednesday, September 14, 2011 2:29 PM
> To: Peng, Tao
> Cc: rees@umich.edu; linux-nfs@vger.kernel.org
> Subject: Re: NULL pointer dereference during mount
>
> I couldn't reproduce this with selinux neither disabled nor enforcing.
> What's your selinux configuration?
I didn't changed selinux config so it is the default on Fedora15
/etc/selinux/config:
SELINUX=enforcing
SELINUXTYPE=targeted

/etc/selinux/semanage.conf:
module-store = direct
expand-check=0
usepasswd=False

Cheers,
Tao
>
> Benny
>
> On 2011-09-13 18:43, tao.peng@emc.com wrote:
> >
> > ________________________________________
> > From: Jim Rees [rees@umich.edu]
> > Sent: Tuesday, September 13, 2011 8:42 PM
> > To: Peng, Tao
> > Cc: bhalevy@tonian.com; linux-nfs@vger.kernel.org
> > Subject: Re: NULL pointer dereference during mount
> >
> > tao.peng@emc.com wrote:
> >
> >   After rebasing to your pnfs-all-latest branch, I always got bellow NULL
> >   pointer dereference for both nfsv4 and pnfs. Do you know of any recent
> >   change that can cause this?
> >
> > "git diff" shows no change in the nfs client between my for-benny branch and
> > benny's pnfs-all-latest branch.  And the mount works for me.  But the first
> > thing I always do on a fresh Fedora install is disable selinux.  Maybe
> > something changed in selinux?
> > [PT] Just tested 3.1-rc6 and it is working properly. So I think it should be caused by
> nfs changes.--
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

