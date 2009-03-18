From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS4ERR_SYMLINK  error
Date: Wed, 18 Mar 2009 19:06:21 -0400
Message-ID: <20090318230621.GK18894@fieldses.org>
References: <49AF9C28.8030603@cn.fujitsu.com> <49AFA4E4.50207@panasas.com> <20090306213234.GB1779@fieldses.org> <49B2C404.3060907@panasas.com> <20090309180643.GB9408@fieldses.org> <49BA15B3.2040904@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Ni Wenjuan <niwj@cn.fujitsu.com>, linux-nfs@vger.kernel.org
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:55560 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753836AbZCRXG3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 19:06:29 -0400
In-Reply-To: <49BA15B3.2040904@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 13, 2009 at 04:13:39PM +0800, Yang Hongyang wrote:
> J. Bruce Fields wrote:
> > On Sat, Mar 07, 2009 at 08:59:16PM +0200, Benny Halevy wrote:
> >> On Mar. 06, 2009, 23:32 +0200, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> >>> On Thu, Mar 05, 2009 at 12:09:40PM +0200, Benny Halevy wrote:
> >>>> On Mar. 05, 2009, 11:32 +0200, Ni Wenjuan <niwj@cn.fujitsu.com> wrote:
> >>>>> the result of newpynfs test case of  LINK4a .  if you link with target directoty
> >>>>>  is a symbole file,it should get NFS4ERR_NOTDIR ,instead got NFS4ERR_SYMLINK.
> >>>>>
> >>>>> THE LINK operation  don't list NFS4ERR_SYMLINK as valid errors in the spec. But
> >>>>> NFS4ERR_SYMLINK seems like a reasonable error.  Is this an oversight
> >>>>> in the spec, or something we need to fix?
> >>>> Although NFSv4.1 adds NFS4ERR_SYMLINK to LINK's allowed errors list
> >>>> (and this might be an indication for it being an oversight in rfc3530),
> >>> The error lists in rfc3530 are known to be incomplete in some cases, so
> >>> before adding an exception like this I'd like something more.  (E.g.:
> >>> does this cause any client or application to fail?  Is there some
> >>> logical reason notdir is a more useful error than symlink?)
> >> FWIW, the linux nfs client translates NFS4ERR_SYMLINK to -ELOOP
> >> which is awkward and less descriptive to the app / user than
> >> -ENOTDIR.
> > 
> > Hm, OK.  If we fix this will -ELOOP then become reasonable for our
> > remaining NFS4ERR_SYMLINK returns?
> 
> Bruce,Do you think we do not need to fix this?

Given the spec and the client behavior, I guess it sounds reasonable to
fix it, if Benny could just resend with a new comment and signed-off-by.

--b.
