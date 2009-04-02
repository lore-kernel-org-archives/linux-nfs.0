From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH v2 06/47] nfsd41: Add Kconfig symbols for NFSv4.1
Date: Thu, 2 Apr 2009 12:54:27 -0400
Message-ID: <20090402165427.GA32533@fieldses.org>
References: <49D3752E.7060708@panasas.com> <49D38924.9020105@panasas.com> <49D482F6.5090000@panasas.com> <20090402132742.GA24124@fieldses.org> <49D4C19F.7090608@panasas.com> <1238681800.6191.5.camel@heimdal.trondhjem.org> <20090402142256.GF24124@fieldses.org> <1238682355.6191.6.camel@heimdal.trondhjem.org> <20090402143141.GG24124@fieldses.org> <49D4E915.40705@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:34408 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933587AbZDBQya (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 12:54:30 -0400
In-Reply-To: <49D4E915.40705@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 02, 2009 at 07:34:29PM +0300, Benny Halevy wrote:
> On Apr. 02, 2009, 17:31 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Thu, Apr 02, 2009 at 10:25:55AM -0400, Trond Myklebust wrote:
> >> On Thu, 2009-04-02 at 10:22 -0400, J. Bruce Fields wrote:
> >>> On Thu, Apr 02, 2009 at 10:16:40AM -0400, Trond Myklebust wrote:
> >>>> On Thu, 2009-04-02 at 16:46 +0300, Benny Halevy wrote:
> >>>>> Trond, please speak up if you want to remove CONFIG_NFS_V4_1 as well.
> >>>>> On the client side minorversion 1 will be used only if the user
> >>>>> explicitly asked for it with mount -o minorversion=1.
> >>>> I'd feel more comfortable with being able to compile it out until the
> >>>> stability of the code has been established. I'd certainly want to be
> >>>> able to do that on the server side, since it has no other means to
> >>>> restrict the protocol version should it turn out that NFSv4.1 has some
> >>>> fatal condition.
> >>> I think it's acceptable given an interface that allows choosing the
> >>> supported minorversion at runtime (and that defaults 4.1 to off).
> >> Is there such an interface on the server?
> > 
> > That's the patch Benny just posted.  It seems like a pretty simple
> > extension of the existing version-choosing interface
> > (/proc/fs/nfsd/versions), though I think the version he posted defaults
> > 4.1 to on?  I need to take another look.
> 
> That's right.  This can be changed trivially,
> but I'll have to find and work the reason why the settings reset on
> service nfs restart, otherwise it will reset itself.

Maybe you're starting and stopping the server using distro init scripts
that load and unload the nfsd module?

--b.
