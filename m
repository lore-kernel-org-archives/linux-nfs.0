Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:44823 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752327AbaFWS0X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 14:26:23 -0400
Received: by mail-qg0-f48.google.com with SMTP id q108so6186794qgd.21
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 11:26:22 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 23 Jun 2014 14:26:20 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 000/104] nfsd: eliminate the client_mutex
Message-ID: <20140623142620.17cff7d2@tlielax.poochiereds.net>
In-Reply-To: <20140623161026.GA5898@fieldses.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
	<20140623133926.GA32746@infradead.org>
	<20140623095645.1fc23e9c@tlielax.poochiereds.net>
	<20140623160001.GA24193@infradead.org>
	<20140623161026.GA5898@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 23 Jun 2014 12:10:26 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

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
> 
> $ git log --pretty=format:"%s" fs/nfsd|cut -d: -f1|grep -v '^Merge'|sed 's/\[PATCH\] //'|sort|uniq -c|sort -n|tail
>       8 sunrpc
>      12 fs
>      13 locks
>      15 NFSd
>      30 SUNRPC
>      89 nfsd41
>     107 NFSD
>     228 knfsd
>     449 nfsd
>     594 nfsd4
> 
> Anyway, I don't care.
> 
> --b.

In that case, I'll go with what I prefer -- "nfsd:". But I will at
least go through and make them all consistent.

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>
