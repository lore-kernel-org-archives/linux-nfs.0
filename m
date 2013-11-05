Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:59622 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750732Ab3KECHQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Nov 2013 21:07:16 -0500
From: "Haynes, Tom" <Tom.Haynes@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFSD: Implement SEEK
Date: Tue, 5 Nov 2013 02:07:15 +0000
Message-ID: <12D9C342-D7DC-41B1-B2D5-C13A89E5BDE1@netapp.com>
References: <1382972247-1108-5-git-send-email-bjschuma@netapp.com>
 <20131029073558.GA10889@infradead.org> <526FB180.1060003@netapp.com>
 <20131029130721.GA32094@infradead.org> <20131029133006.GB29606@fieldses.org>
 <20131102134837.GA18961@infradead.org> <20131102143729.GA26983@fieldses.org>
 <20131102144107.GA28743@infradead.org> <20131104164658.GA4427@fieldses.org>
 <5BAB86A3-045A-4CA9-A08F-7B0E38DBAC7D@excfb.com>
 <20131105010332.GA32189@infradead.org>
In-Reply-To: <20131105010332.GA32189@infradead.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 4, 2013, at 5:03 PM, Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Nov 04, 2013 at 01:56:39PM -0800, Thomas Haynes wrote:
>> Nah, most likely me, no imagination needed.
>> 
>> We were also looking at bringing larger WRITEs during 4.3 and I wanted
>> to have WRITE_PLUS already in place for that.
> 
> What exactly does a WRITE PLUS with various non-related overloads in 4.2
> buy you for introducing large writes in 4.3?

In 4.3, READ_PLUS would be extended for large reads. We would at that
time need a WRITE_PLUS to be extended for large writes.

The relationship falls from having WRITE_PLUS handle all of the variants
handled by READ_PLUS. It needs to accept all of them because it
does not know what will be returned.

We did not want many new operators and also wanted the operators to
be extensible. With this approach, you can define a new arm of the
discriminated union, not have to implement it, and not burn an
operator.

Some of the history is captured here:

http://www.ietf.org/mail-archive/web/nfsv4/current/msg11235.html
http://www.ietf.org/mail-archive/web/nfsv4/current/msg11470.html
http://www.ietf.org/proceedings/84/slides/slides-84-nfsv4-1.pdf (slide 6)

It doesn't capture the intent of NFS4ERR_UNION_NOTSUPP in
this decision.

11.1.1.1.  NFS4ERR_UNION_NOTSUPP (Error Code 10090)

   One of the arguments to the operation is a discriminated union and
   while the server supports the given operation, it does not support
   the selected arm of the discriminated union.  For an example, see
   READ_PLUS (Section 14.10).
