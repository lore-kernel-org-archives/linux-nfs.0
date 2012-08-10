Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40404 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759963Ab2HJTME (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Aug 2012 15:12:04 -0400
Date: Fri, 10 Aug 2012 15:11:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "H. Peter Anvin" <hpa@zytor.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Trond.Myklebust@netapp.com, davem@davemloft.net,
        linux-nfs@vger.kernel.org, eric.dumazet@gmail.com, xemul@parallels.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, tim.c.chen@linux.intel.com, devel@openvz.org
Subject: Re: [RFC PATCH 0/2] net: connect to UNIX sockets from specified
 root
Message-ID: <20120810191149.GA17985@fieldses.org>
References: <20120810125701.7115.71612.stgit@localhost.localdomain>
 <50254FA6.3060806@zytor.com>
 <20120810192628.79a34d28@pyramind.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120810192628.79a34d28@pyramind.ukuu.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 10, 2012 at 07:26:28PM +0100, Alan Cox wrote:
> > On that whole subject...
> > 
> > Do we need a Unix domain socket equivalent to openat()?
> 
> I don't think so. The name is just a file system indexing trick, it's not
> really the socket proper. It's little more than "ascii string with
> permissions attached"

That's overstating the case.  As I understand it the address is resolved
by a pathname lookup like any other--it can follow symlinks, is relative
to the current working directory and filesystem namespace, etc.  So a
unix-domain socket equivalent to openat() would at least be
well-defined--whether it's needed or not, I don't know.

--b.
