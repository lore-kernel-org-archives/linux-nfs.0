From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Question: NFS behaviour in case of concurrent local and remote
	access
Date: Tue, 10 Nov 2009 09:44:27 -0500
Message-ID: <20091110144427.GB10665@fieldses.org>
References: <1257770569.7276.31.camel@home.yosifov.net> <1257773136.3754.17.camel@heimdal.trondhjem.org> <1257779590.9200.28.camel@home.yosifov.net> <20091109182409.GA22652@fieldses.org> <1257861096.19058.7.camel@home.yosifov.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Ivan Yosifov <iyosifov@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34941 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756449AbZKJOoN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Nov 2009 09:44:13 -0500
In-Reply-To: <1257861096.19058.7.camel-+yaoqMNIL58NKrj9nap9fg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 10, 2009 at 03:51:36PM +0200, Ivan Yosifov wrote:
> On Mon, 2009-11-09 at 13:24 -0500, J. Bruce Fields wrote:
> > On Mon, Nov 09, 2009 at 05:13:10PM +0200, Ivan Yosifov wrote:
> > > Sounds encouraging. Just to clarify, I assume local writers don't pass
> > > through NFS. 
> > > 
> > > Out of curiosity, do you know how it's implemented ? 
> > > 
> > > I looked at fs/nfsd and fs/nfs in the kernel source but didn't really
> > > understand a lot. I got the impression that nfs clients and the server
> > > pass nfsd4_change_info objects ( defined in include/linux/nfsd/xdr4.h )
> > > around with the before_change and after_change fields being "file
> > > version" of sorts - ie. they are changed when the file is changed and
> > > don't depend on timestamp resolution or anything like that.
> > > 
> > > My concern is that the normal fs has only timestamps ( right ? ) which
> > > have a finite resolution and can't be used as file version indicators.
> > > So it seems necessary for the normal fs code to notify the NFS code for
> > > every write/change to a file that's also opened through NFS. Such a
> > > tight coupling both seems hard to get and I didn't notice anything like
> > > it in the source. 
> > 
> > Right, the linux server is designed to support concurrent local and nfs
> > access, but there are two problems that I know of:
> > 
> > 	- timestamp granularity: ext3's timestamps only had 1-second
> > 	  granularity.  Ext4's appear to be a jiffy, but that's still
> > 	  coarse enough that it could miss an update.  There's a special
> > 	  mount option for ext4 that will cause it to update an
> > 	  i_version field on every update, in which case the nfsv4
> > 	  server will use that as its change attribute.  We should fix
> > 	  that to not require a mount option.
> 
> Thanks for the tip. I didn't know of the i_version mount option but it
> seems quite useful. I could think of some other uses for such a field.
> Is it currently readable from user space ?

No.  I agree that it could have uses outside of nfsd.

> > 	- delegations are not revoked on all operations: we use leases
> > 	  to implement delegations.  That insures that if you open a
> > 	  file locally, any delegations will be revoked.  However, we
> > 	  should also be revoking delegations on operations other than
> > 	  open (such as rename and unlink).  I have some patches that do
> > 	  this, but they still have bugs, and need some more work.
> 
> Is this a serious problem ? My understanding is that renaming or
> unlinking a file in use should simply result in a stale handle, access
> to which will return an error anyway.

Unlinking will eventually result in a stale filehandle, yes.  (I don't
know about "should"--the nfs protocol has historically made it hard or
impossible to avoid that situation, but with 4.1 I think it may be
easier to fix.)  Renaming shouldn't result in a stale filehandle.

But that's not the point.  The problem is that new opens of "/dir/foo"
will continue to return the old file, even after "/dir/foo" has been
renamed elsewhere (or removed completely), because the delegation gives
the client the right to assume that "/dir/foo" still points to the same
file, without consulting the server.  One possible way to reproduce the
problem: cat a file on the client, edit the file with a text editor on
the server, then cat the file on the client again.  With no overlapping
opens, close-to-open consistency should assure that last "cat" sees the
modified result.  But if your editor actually moved/unliked the old
file, and if your client holds a delegation, you may still see the old
data....

--b.
