From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Question: NFS behaviour in case of concurrent local and remote
	access
Date: Mon, 9 Nov 2009 13:24:09 -0500
Message-ID: <20091109182409.GA22652@fieldses.org>
References: <1257770569.7276.31.camel@home.yosifov.net> <1257773136.3754.17.camel@heimdal.trondhjem.org> <1257779590.9200.28.camel@home.yosifov.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Ivan Yosifov <iyosifov@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42120 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752036AbZKISX5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Nov 2009 13:23:57 -0500
In-Reply-To: <1257779590.9200.28.camel-+yaoqMNIL58NKrj9nap9fg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 09, 2009 at 05:13:10PM +0200, Ivan Yosifov wrote:
> Sounds encouraging. Just to clarify, I assume local writers don't pass
> through NFS. 
> 
> Out of curiosity, do you know how it's implemented ? 
> 
> I looked at fs/nfsd and fs/nfs in the kernel source but didn't really
> understand a lot. I got the impression that nfs clients and the server
> pass nfsd4_change_info objects ( defined in include/linux/nfsd/xdr4.h )
> around with the before_change and after_change fields being "file
> version" of sorts - ie. they are changed when the file is changed and
> don't depend on timestamp resolution or anything like that.
> 
> My concern is that the normal fs has only timestamps ( right ? ) which
> have a finite resolution and can't be used as file version indicators.
> So it seems necessary for the normal fs code to notify the NFS code for
> every write/change to a file that's also opened through NFS. Such a
> tight coupling both seems hard to get and I didn't notice anything like
> it in the source. 

Right, the linux server is designed to support concurrent local and nfs
access, but there are two problems that I know of:

	- timestamp granularity: ext3's timestamps only had 1-second
	  granularity.  Ext4's appear to be a jiffy, but that's still
	  coarse enough that it could miss an update.  There's a special
	  mount option for ext4 that will cause it to update an
	  i_version field on every update, in which case the nfsv4
	  server will use that as its change attribute.  We should fix
	  that to not require a mount option.

	- delegations are not revoked on all operations: we use leases
	  to implement delegations.  That insures that if you open a
	  file locally, any delegations will be revoked.  However, we
	  should also be revoking delegations on operations other than
	  open (such as rename and unlink).  I have some patches that do
	  this, but they still have bugs, and need some more work.

--b.
