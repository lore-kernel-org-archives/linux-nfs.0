Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:42382 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849Ab3KEIXI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Nov 2013 03:23:08 -0500
Date: Tue, 5 Nov 2013 00:23:04 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "Haynes, Tom" <Tom.Haynes@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFSD: Implement SEEK
Message-ID: <20131105082304.GA17793@infradead.org>
References: <526FB180.1060003@netapp.com>
 <20131029130721.GA32094@infradead.org>
 <20131029133006.GB29606@fieldses.org>
 <20131102134837.GA18961@infradead.org>
 <20131102143729.GA26983@fieldses.org>
 <20131102144107.GA28743@infradead.org>
 <20131104164658.GA4427@fieldses.org>
 <5BAB86A3-045A-4CA9-A08F-7B0E38DBAC7D@excfb.com>
 <20131105010332.GA32189@infradead.org>
 <12D9C342-D7DC-41B1-B2D5-C13A89E5BDE1@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <12D9C342-D7DC-41B1-B2D5-C13A89E5BDE1@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 05, 2013 at 02:07:15AM +0000, Haynes, Tom wrote:
> We did not want many new operators and also wanted the operators to
> be extensible. With this approach, you can define a new arm of the
> discriminated union, not have to implement it, and not burn an
> operator.

That seems very much like a non-argument.  If saving operators was a
good argument the NFS operations should be

MULTIPLEX1 with many sub opcodes, followed by MULTIPLEX2 once it fills
up.

> Some of the history is captured here:
> 
> http://www.ietf.org/mail-archive/web/nfsv4/current/msg11235.html

That mail seems to draw the wrong conclusion that a hole punching
or a preallocation are equivalent to a server side copy from /dev/zero.

Treating a pattern write as a server side copy is fine and I'd fully
support that.  Hole punching and preallocation on the other hand are
primarily metadata operations that reserve or free space.  They only
happen to zero out the range as zero is the most convenient well known
pattern to avoid stale data exposure.

> http://www.ietf.org/mail-archive/web/nfsv4/current/msg11470.html

I think Chuck's reply summarizes very well why a pattern initialization
should not be mixed with an actual data write.  

> http://www.ietf.org/proceedings/84/slides/slides-84-nfsv4-1.pdf (slide 6)

That side seems to inadvertently sum up a lot of what's wrong with merging
hole punching and preallocations into some form of super write:

 - COMMIT doesn't really apply to pure metadata operations like a hole
   punch and preallocation, so fitting it into a WRITE that expects
   COMMIT causes all kinds of problems (as we saw in the thread about
   Annas implementation).
 - requiring the server to be able to handle offloads for these
   operations does not make any sense, because they are again very
   quick metadata operation, and not long running operation like
   a pattern initialization on the server.

Note that the arbitrary pattern initialization over multiple blocks is
a very different operation from a space allocation even if the latter
happens to also zero the range as a side effect.


> 
> It doesn't capture the intent of NFS4ERR_UNION_NOTSUPP in
> this decision.
> 
> 11.1.1.1.  NFS4ERR_UNION_NOTSUPP (Error Code 10090)
> 
>    One of the arguments to the operation is a discriminated union and
>    while the server supports the given operation, it does not support
>    the selected arm of the discriminated union.  For an example, see
>    READ_PLUS (Section 14.10).

Btw, there is an odd use of this error in 14.7.3.:

 "WRITE_PLUS has to support all of the errors which are returned by
  WRITE plus NFS4ERR_UNION_NOTSUPP.  If the client asks for a hole and
  the server does not support that arm of the discriminated union, but
  does support one or more additional arms, it can signal to the
  client that it supports the operation, but not the arm with
  NFS4ERR_UNION_NOTSUPP."

This does not specicly writes but appears to assume hole punching
is the only optional arm.  On the other hand to me it appears the only
interesting arm, with the data arm buying nothing over WRITE in 4.2 and
thus being entirely superflous, and ADHs being a complicated map to Unix
filesystems on the backend.
