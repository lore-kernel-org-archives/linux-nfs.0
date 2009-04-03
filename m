From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH v2 06/47] nfsd41: Add Kconfig symbols for NFSv4.1
Date: Thu, 2 Apr 2009 22:29:35 -0400
Message-ID: <20090403022935.GB30324@fieldses.org>
References: <20090402165427.GA32533@fieldses.org> <49D4F9BE.3010102@panasas.com> <49D4FB68.20502@panasas.com> <20090402175517.GA5560@fieldses.org> <20090402175806.GB5560@fieldses.org> <49D506DD.8040705@panasas.com> <20090402184629.GF5560@fieldses.org> <49D50C91.7060707@panasas.com> <20090402224920.GG18195@fieldses.org> <49D55447.2050400@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org, Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:60730 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752215AbZDCC3k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 22:29:40 -0400
In-Reply-To: <49D55447.2050400@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 03, 2009 at 03:11:51AM +0300, Benny Halevy wrote:
> On Apr. 03, 2009, 1:49 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Thu, Apr 02, 2009 at 10:05:53PM +0300, Benny Halevy wrote:
> >> On Apr. 02, 2009, 21:46 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> >>> On Thu, Apr 02, 2009 at 09:41:33PM +0300, Benny Halevy wrote:
> >>>> It looks like rpc.nfsd's command line syntax is all negative.
> >>>> I.e. all versions are on by default and they can be turned off
> >>>> using the -N option.  I can either add an option to enable minorversion
> >>>> or have it enabled by default and add an option to disable it.
> >>> I'm not a big fan of that commandline syntax--seems to me it should give
> >>> a range rather than a list of versions not to support.
> >>>
> >>> For now the important thing is that the kernel default minorversion 1 to
> >>> off.  We can worry about what rpc.nfsd should do later--I guess a
> >>> commandline option to turn on specific minor versions would work....
> >>> Maybe allow --nfs-version as well as --no-nfs-version?
> >> Sounds like a good idea.
> >> How about --nfs-versions (in plural) to correspond to /proc/fs/nfsd/versions
> >> and then pass the whole versions string?
> > 
> > I suppose that would work, but it seems a little inconsistent with the
> > current syntax, and with the way unix commandlines works in general.
> > Something a little less idiosyncratic would be easier to document and
> > remember.
> 
> OK.  I'm trying to develop such an option but I'm having trouble
> with ./configure on Fedora 9. didn't find libwrap (which exists
> in /lib and /lib64) and --without-tcp-wrappers it can't find
> libevent, which is in /usr/lib64.
> 
> Anything special I need to do to make the nfs utils on Fedora 9?

Steved's the expert, but one approach might be just to get the source
rpm.

Obviously this doesn't have to be done before the kernel submission; all
I care about is that nobody get a server that accepts 4.1 calls by
default.

If you just need something for testing, I think you can do the job of
rpc.nfsd by hand with just:

	echo <version string> >/proc/fs/nfsd/versions
	echo <number of threads> >/proc/fs/nfsd/threads

rpc.nfsd isn't exactly the sharpest knife in the drawer.

--b.
