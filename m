Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:37939 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819Ab3KDTvW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Nov 2013 14:51:22 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20131104191907.GA9337@infradead.org>
Date: Mon, 4 Nov 2013 11:50:51 -0800
Cc: Anna Schumaker <bjschuma@netapp.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Message-Id: <8EB0049A-9225-4C4A-8099-774B2EB48323@oracle.com>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com> <1382972247-1108-4-git-send-email-bjschuma@netapp.com> <20131102135238.GB18961@infradead.org> <5277CE23.6010207@netapp.com> <20131104170345.GA31499@infradead.org> <5277D80F.8050106@netapp.com> <20131104185309.GA14378@infradead.org> <3AC4ECC6-0496-4593-8791-92BCAD2567CC@oracle.com> <20131104191907.GA9337@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 4, 2013, at 11:19 AM, Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Nov 04, 2013 at 11:16:13AM -0800, Chuck Lever wrote:
>>> I still don't understand why anyone would phase out WRITE in favour of
>>> something that doesn't actually add any value for the write case.
>> 
>> Protocol extensibility.  WRITE_PLUS adds a discriminated union of data types that can be extended easily to include initialization patterns, integrity metadata, and other things like holes.  It's entirely another question as to whether any particular extension is tasteful.
> 
> Maybe I'm missing something, but what does multiplexing entirely
> different operation actually buy you?  It is different operation after
> all.

I think a successful argument could be made that initialization or hole punching may not belong in a WRITE_PLUS operation.  For example, using a COMMIT for a long-running server-performed file initialization doesn't make sense to me.  The infrastructure we introduced for COPY_OFFLOAD seems better suited for file initialization.

> It's not like adding new operations to NFS is all that hard.

Actually, it is harder than you think.  For various reasons, it takes five or more years to create a new NFS protocol specification, something we hope to address.

>> The mailing list is not the only place where they are discussed.  We also use conference calls, and there are face-to-face meetings too.  Not all of that content is distilled into a public record.  Very much like Linux kernel development.
> 
> Linux development strives very hard documenting rationales, something I
> haven't found on the NFS list or in the repository.

There are plenty of times where I find the kernel git log or e-mail archives entirely unhelpful in understanding the why's and wherefor's.  It's a human endeavor, and like all such things, is imperfect, and is often a matter of knowing who to ask rather than where to look.

By the way, e-mail from non-members to nfsv4@ietf.org is moderated.  The moderator may be traveling or otherwise unavailable, as IETF 88 is happening this week.  If you subscribe to the list, you should be able to post without restriction.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

