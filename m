Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49093 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751424Ab3EISRk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 May 2013 14:17:40 -0400
Date: Thu, 9 May 2013 14:16:47 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Vyacheslav Dubeyko <slava@dubeyko.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>,
        Hin-Tak Leung <htl10@users.sourceforge.net>,
        Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 0/5] nfsd + hfsplus: introduce generalized version of
 NFSv4 ACLs <-> POSIX ACLs mapping algorithms
Message-ID: <20130509181647.GA18541@pad.fieldses.org>
References: <1368117430.5695.30.camel@slavad-ubuntu-12.04>
 <1368118877.3282.104.camel@leira.trondhjem.org>
 <9841F318-DA62-4ACF-AA33-0474DBC2B107@dubeyko.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <9841F318-DA62-4ACF-AA33-0474DBC2B107@dubeyko.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 09, 2013 at 09:34:50PM +0400, Vyacheslav Dubeyko wrote:
> On May 9, 2013, at 9:01 PM, Myklebust, Trond wrote:
> 
> [snip]
> > 
> > How does this make sense? There is no lossless mapping of NFSv4 acls
> > into POSIX acls; the latter doesn't have any equivalent of the DENY
> > aces so you cannot represent the full set of acls that can be set
> > using MacOS on the same filesystem.
> > 
> > Shouldn't you rather be looking at the richacl patch sets?
> > 
> 
> Yes, I understand the nature of such mapping and impossibility of
> mapping NFSv4 ACLs to POSIX ACLs in some cases. But, as I understand,
> the richacl patch set is not mainline yet.

Neither are these patches.  You could pick up the richacl patches and
work on them instead.  That might be more work, I don't know, but the
result would certainly be more useful, to many more people....

> And even if it will be in mainline then a user can have choice to use
> POSIX ACLs or richacls.

I actually kinda like the idea of allowing people to use either model
and translating automatically between them.  But it is complicated, and
I'm not convinced it's necessary.

> So, we need to map NFSv4 ACLs <-> POSIX ACLs in hfsplus for the case
> of using POSIX ACLs model. I think that to have such mapping is better
> than to have nothing.

So, in the "better than nothing" spirit, I'll take a look at these, but
I would still rather we get the richacl stuff done....

--b.

> Moreover, a user can use HFS+ filesystem with
> using POSIX ACLs only under Linux. Thereby, the generalization of
> mapping NFSv4 ACLs <-> POSIX ACLs makes sense, from my viewpoint.
> 
> With the best regards, Vyacheslav Dubeyko.
> 
> > -- Trond Myklebust Linux NFS client maintainer
> > 
> > NetApp Trond.Myklebust@netapp.com www.netapp.com
> 
