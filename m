Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42289 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755717Ab3CSOci (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Mar 2013 10:32:38 -0400
Date: Tue, 19 Mar 2013 10:32:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/11] NFSv4.1: Enable open-by-filehandle
Message-ID: <20130319143236.GD7912@fieldses.org>
References: <1363698463-3681-3-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-4-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-5-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-6-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-7-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-8-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-9-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-10-git-send-email-Trond.Myklebust@netapp.com>
 <20130319140901.GB7912@fieldses.org>
 <1363702570.7515.6.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1363702570.7515.6.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 19, 2013 at 02:16:15PM +0000, Myklebust, Trond wrote:
> On Tue, 2013-03-19 at 10:09 -0400, J. Bruce Fields wrote:
> > On Tue, Mar 19, 2013 at 09:07:42AM -0400, Trond Myklebust wrote:
> > > Sometimes, we actually _want_ to do open-by-filehandle, for instance
> > > when recovering opens after a network partition, or when called
> > > from nfs4_file_open.
> > > Enable that functionality using a new capability NFS_CAP_ATOMIC_OPEN_V1,
> > > and which is only enabled for NFSv4.1 servers that support it.
> > 
> > So you're assuming NFS4ERR_INVAL is how the server indicates lack of
> > support?
> 
> Looking at the list of valid errors for OPEN in section 15.2 of RFC5661,
> I don't see what else fits the bill.

OK, fair enough.

> > Looking back at NFS server history.... I think that's what it did before
> > supporting these types, but I wonder if that was really right.  Possibly
> > it's just a bug not to support the new claim types in a 4.1 server.
> 
> I've assumed that it isn't. NFSv4.1 is the very first minor version, so
> it's not supposed to contain any mandatory new features. Yes, I know we
> broke the rules on that one in spectacular fashion with sessions, but
> I'm assuming that is the only exception...

It's really unclear.  There's a lot of stuff like this that aren't
clearly identified as optional or given an obvious way to negotiate.
And which sessions features are mandatory?  Even where the spec clearly
makes things mandatory for servers to implement (SSV, trunking) I wonder
whether servers are actually complying.

(Sorry for the digression, I was just trying to decide whether I can get
away with turning on 4.1 by default before implementing SP4_MACH_CRED or
GSS on the backchannel....)

--b.
