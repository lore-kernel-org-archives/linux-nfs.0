Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48529 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932136AbaFWQK1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jun 2014 12:10:27 -0400
Date: Mon, 23 Jun 2014 12:10:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 000/104] nfsd: eliminate the client_mutex
Message-ID: <20140623161026.GA5898@fieldses.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
 <20140623133926.GA32746@infradead.org>
 <20140623095645.1fc23e9c@tlielax.poochiereds.net>
 <20140623160001.GA24193@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140623160001.GA24193@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 23, 2014 at 09:00:01AM -0700, Christoph Hellwig wrote:
> On Mon, Jun 23, 2014 at 09:56:45AM -0400, Jeff Layton wrote:
> > >  - there is some confusion of NFSd vs nfsd in the subsystem prefixes.
> > >    While it seems odd and against the usual naming NFSd seems to be
> > >    the common one for nfs patches.
> > > 
> > 
> > I tend to prefer "nfsd", but ok -- "NFSd" it is.
> 
> I'd prefer nfsd as well, but in Rome do as the Romans do, so..

These Romans?:

$ git log --pretty=format:"%s" fs/nfsd|cut -d: -f1|grep -v '^Merge'|sed 's/\[PATCH\] //'|sort|uniq -c|sort -n|tail
      8 sunrpc
     12 fs
     13 locks
     15 NFSd
     30 SUNRPC
     89 nfsd41
    107 NFSD
    228 knfsd
    449 nfsd
    594 nfsd4

Anyway, I don't care.

--b.
