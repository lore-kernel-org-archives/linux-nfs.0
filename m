From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/11] nfsd: ADD data structure infrastructure
Date: Wed, 22 Apr 2009 15:43:13 -0400
Message-ID: <20090422194313.GG9541@fieldses.org>
References: <20090325133607.16437.33288.sendpatchset@localhost.localdomain> <20090325133628.16437.11092.sendpatchset@localhost.localdomain> <20090421224838.GH27411@fieldses.org> <OFC3F6A1EF.6F01ED4C-ON652575A0.001BD4E4-652575A0.001ED00D@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jlayton@redhat.com, Krishna Kumar <krikku@gmail.com>,
	linux-nfs@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:34494 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbZDVTnS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 15:43:18 -0400
In-Reply-To: <OFC3F6A1EF.6F01ED4C-ON652575A0.001BD4E4-652575A0.001ED00D@in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 22, 2009 at 11:06:33AM +0530, Krishna Kumar2 wrote:
> "J. Bruce Fields" <bfields@fieldses.org> wrote on 04/22/2009 04:18:38 AM:
> 
> > > +/*
> > > + * This is a cache of file handles to quicken file lookup. This also
> > > + * helps prevent multiple open/close of a file when a client reads it.
> > > + *
> > > + * If you increase the number of cached files very much, you'll need
> to
> > > + * add a hash table here.
> >
> > I'm a little confused here--what do you mean by "add a hash table here"?
> 
> That is also in the original code. I feel the comment is wrong as we
> already have a hash table in raparm_hbucket, but I didn't want to change
> typos as part of this patch.

This patch doesn't change anything--it only adds new lines.  If you're
trying to make minimal changes, that's admirable, but break up the
patches in such a way that each patch shows that minimal change.

--b.

> 
> thanks,
> 
> - KK
> 
