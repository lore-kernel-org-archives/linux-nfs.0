Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([134.215.213.37]:2434 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933827Ab1JaSYY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Oct 2011 14:24:24 -0400
Date: Mon, 31 Oct 2011 14:23:10 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, nfsv4 list <nfsv4@ietf.org>,
        Benny Halevy <bhalevy@tonian.com>
Message-ID: <553963112.119.1320085390187.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <1320085212.4714.48.camel@lade.trondhjem.org>
Subject: Re: [nfsv4] [PATCH 2/2] nfs41: handle BLK_LAYOUT CB_RECALL_ANY
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Such a server implementation will certainly not be long in coming.

Matt

----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2011-10-31 at 19:57 +0200, Benny Halevy wrote: 

> > 
> > Waiting for revocation may work well with some servers but would be
> disastrous in
> > terms of performance and responsiveness with others.
> 
> I don't necessarily disagree with what you are saying, but I have yet
> to
> see a single server side implementation of CB_RECALL_ANY, let alone
> any
> numbers that indicate performance or responsiveness problems
> resulting
> from our existing client-side implementation.
> 
> I therefore find it hard to understand why optimising this particular
> code is such a high priority, or why a patch that is adding per-file
> layoutreturns to initiate_bulk_draining() is going to help anything
> at
> all.
> 
>    Trond
> 


-- 

Matt Benjamin

The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel. 734-761-4689
fax. 734-769-8938
cel. 734-216-5309
