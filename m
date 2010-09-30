Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24423 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932309Ab0I3Rj7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 13:39:59 -0400
Subject: Re: [PATCH] nfs-utils: Add nfs.upcall for idmapper
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        SteveD@redhat.com
In-Reply-To: <20100930172336.GA9385@fieldses.org>
References: <4CA39681.3000104@netapp.com>
	 <1285798396.3557.18.camel@heimdal.trondhjem.org>
	 <4CA48CEF.9060600@netapp.com>
	 <59CA8CDE-0A68-4F99-BB09-804D24452148@oracle.com>
	 <1285866437.14635.27.camel@heimdal.trondhjem.org>
	 <20100930172336.GA9385@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 30 Sep 2010 13:39:20 -0400
Message-ID: <1285868360.14635.42.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-09-30 at 13:23 -0400, J. Bruce Fields wrote:
> On Thu, Sep 30, 2010 at 01:07:17PM -0400, Trond Myklebust wrote:
> > On Thu, 2010-09-30 at 11:42 -0400, Chuck Lever wrote:
> > > Finally, if at all possible, it would be better if the kernel could automatically recognize and use nfs.upcall rather than the legacy idmapping mechanism.  My experience with CONFIG options is that people will almost always choose the wrong setting no matter how many large neon arrows you add.  I know there are likely some technical challenges here.
> > 
> > I don't think that is easy to do. The keyring upcall mechanism will
> > almost always succeed, no matter whether or not there is a handler for
> > the type of key requested. Instead, it will result in a negative lookup.
> > Unfortunately, seeing a negative key isn't sufficient to determine that
> > no handler exists.
> 
> If we could just find out whether there's an executable at the right
> path, that would be enough to catch most misconfigurations.  Would it be
> hard to get back at least that much information?

AFAICS, the lookup can return ENOENT or EACCES if the key-utils package
is missing.

However, as I said above, the fact that the exec succeeds is not
sufficient to determine whether or not the user has installed our upcall
handler in their /etc/request-key.conf.

> I'm inclined to agree with Chuck that this is a likely trap for the
> unwary....

That's why the help text for the config option states explicitly that
you need new tools, and points you to the correct Documentation file...

Cheers
  Trond

