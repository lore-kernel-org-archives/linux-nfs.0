Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38128 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753026Ab0I3RXu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 13:23:50 -0400
Date: Thu, 30 Sep 2010 13:23:37 -0400
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        SteveD@redhat.com
Subject: Re: [PATCH] nfs-utils: Add nfs.upcall for idmapper
Message-ID: <20100930172336.GA9385@fieldses.org>
References: <4CA39681.3000104@netapp.com>
 <1285798396.3557.18.camel@heimdal.trondhjem.org>
 <4CA48CEF.9060600@netapp.com>
 <59CA8CDE-0A68-4F99-BB09-804D24452148@oracle.com>
 <1285866437.14635.27.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1285866437.14635.27.camel@heimdal.trondhjem.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 30, 2010 at 01:07:17PM -0400, Trond Myklebust wrote:
> On Thu, 2010-09-30 at 11:42 -0400, Chuck Lever wrote:
> > Finally, if at all possible, it would be better if the kernel could automatically recognize and use nfs.upcall rather than the legacy idmapping mechanism.  My experience with CONFIG options is that people will almost always choose the wrong setting no matter how many large neon arrows you add.  I know there are likely some technical challenges here.
> 
> I don't think that is easy to do. The keyring upcall mechanism will
> almost always succeed, no matter whether or not there is a handler for
> the type of key requested. Instead, it will result in a negative lookup.
> Unfortunately, seeing a negative key isn't sufficient to determine that
> no handler exists.

If we could just find out whether there's an executable at the right
path, that would be enough to catch most misconfigurations.  Would it be
hard to get back at least that much information?

I'm inclined to agree with Chuck that this is a likely trap for the
unwary....

--b.
