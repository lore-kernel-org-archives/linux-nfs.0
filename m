Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:40032 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909AbaFWQN4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 12:13:56 -0400
Date: Mon, 23 Jun 2014 09:13:55 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 000/104] nfsd: eliminate the client_mutex
Message-ID: <20140623161355.GA11047@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
 <20140623133926.GA32746@infradead.org>
 <20140623095645.1fc23e9c@tlielax.poochiereds.net>
 <20140623160001.GA24193@infradead.org>
 <20140623161026.GA5898@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140623161026.GA5898@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 23, 2014 at 12:10:26PM -0400, J. Bruce Fields wrote:
> On Mon, Jun 23, 2014 at 09:00:01AM -0700, Christoph Hellwig wrote:
> > On Mon, Jun 23, 2014 at 09:56:45AM -0400, Jeff Layton wrote:
> > > >  - there is some confusion of NFSd vs nfsd in the subsystem prefixes.
> > > >    While it seems odd and against the usual naming NFSd seems to be
> > > >    the common one for nfs patches.
> > > > 
> > > 
> > > I tend to prefer "nfsd", but ok -- "NFSd" it is.
> > 
> > I'd prefer nfsd as well, but in Rome do as the Romans do, so..
> 
> These Romans?:

Oops, sorry.  It's mostly Trond for the client who is using the upper
case NFS*.

