From: Ivan Yosifov <iyosifov@gmail.com>
Subject: Re: Question: NFS behaviour in case of concurrent local and remote
 access
Date: Tue, 10 Nov 2009 15:51:36 +0200
Message-ID: <1257861096.19058.7.camel@home.yosifov.net>
References: <1257770569.7276.31.camel@home.yosifov.net>
	 <1257773136.3754.17.camel@heimdal.trondhjem.org>
	 <1257779590.9200.28.camel@home.yosifov.net>
	 <20091109182409.GA22652@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:34904 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbZKJNvf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2009 08:51:35 -0500
Received: by fxm21 with SMTP id 21so29257fxm.21
        for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2009 05:51:40 -0800 (PST)
In-Reply-To: <20091109182409.GA22652@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-11-09 at 13:24 -0500, J. Bruce Fields wrote:
> On Mon, Nov 09, 2009 at 05:13:10PM +0200, Ivan Yosifov wrote:
> > Sounds encouraging. Just to clarify, I assume local writers don't pass
> > through NFS. 
> > 
> > Out of curiosity, do you know how it's implemented ? 
> > 
> > I looked at fs/nfsd and fs/nfs in the kernel source but didn't really
> > understand a lot. I got the impression that nfs clients and the server
> > pass nfsd4_change_info objects ( defined in include/linux/nfsd/xdr4.h )
> > around with the before_change and after_change fields being "file
> > version" of sorts - ie. they are changed when the file is changed and
> > don't depend on timestamp resolution or anything like that.
> > 
> > My concern is that the normal fs has only timestamps ( right ? ) which
> > have a finite resolution and can't be used as file version indicators.
> > So it seems necessary for the normal fs code to notify the NFS code for
> > every write/change to a file that's also opened through NFS. Such a
> > tight coupling both seems hard to get and I didn't notice anything like
> > it in the source. 
> 
> Right, the linux server is designed to support concurrent local and nfs
> access, but there are two problems that I know of:
> 
> 	- timestamp granularity: ext3's timestamps only had 1-second
> 	  granularity.  Ext4's appear to be a jiffy, but that's still
> 	  coarse enough that it could miss an update.  There's a special
> 	  mount option for ext4 that will cause it to update an
> 	  i_version field on every update, in which case the nfsv4
> 	  server will use that as its change attribute.  We should fix
> 	  that to not require a mount option.

Thanks for the tip. I didn't know of the i_version mount option but it
seems quite useful. I could think of some other uses for such a field.
Is it currently readable from user space ?

> 
> 	- delegations are not revoked on all operations: we use leases
> 	  to implement delegations.  That insures that if you open a
> 	  file locally, any delegations will be revoked.  However, we
> 	  should also be revoking delegations on operations other than
> 	  open (such as rename and unlink).  I have some patches that do
> 	  this, but they still have bugs, and need some more work.

Is this a serious problem ? My understanding is that renaming or
unlinking a file in use should simply result in a stale handle, access
to which will return an error anyway.

> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



