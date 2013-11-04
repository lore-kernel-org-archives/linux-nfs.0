Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:56096 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751558Ab3KDUD6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Nov 2013 15:03:58 -0500
From: "Haynes, Tom" <Tom.Haynes@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Christoph Hellwig <hch@infradead.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
Date: Mon, 4 Nov 2013 20:03:58 +0000
Message-ID: <1A74FF84-00E2-4C5F-A209-350792D2E0AE@netapp.com>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-4-git-send-email-bjschuma@netapp.com>
 <20131102135238.GB18961@infradead.org> <5277CE23.6010207@netapp.com>
 <20131104170345.GA31499@infradead.org> <5277D80F.8050106@netapp.com>
 <20131104185309.GA14378@infradead.org>
 <3AC4ECC6-0496-4593-8791-92BCAD2567CC@oracle.com>
 <20131104191907.GA9337@infradead.org>
 <8EB0049A-9225-4C4A-8099-774B2EB48323@oracle.com>
In-Reply-To: <8EB0049A-9225-4C4A-8099-774B2EB48323@oracle.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 4, 2013, at 11:50 AM, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Nov 4, 2013, at 11:19 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
>> On Mon, Nov 04, 2013 at 11:16:13AM -0800, Chuck Lever wrote:
>>>> I still don't understand why anyone would phase out WRITE in favour of
>>>> something that doesn't actually add any value for the write case.
>>> 
>>> Protocol extensibility.  WRITE_PLUS adds a discriminated union of data types that can be extended easily to include initialization patterns, integrity metadata, and other things like holes.  It's entirely another question as to whether any particular extension is tasteful.
>> 
>> Maybe I'm missing something, but what does multiplexing entirely
>> different operation actually buy you?  It is different operation after
>> all.


Do you have an issue with READ_PLUS?

I.e., are you okay with that operation because the answer is not known beforehand?


> 
> I think a successful argument could be made that initialization or hole punching may not belong in a WRITE_PLUS operation.  For example, using a COMMIT for a long-running server-performed file initialization doesn't make sense to me.  The infrastructure we introduced for COPY_OFFLOAD seems better suited for file initialization.

WRITE_PLUS does utilize COPY_OFFLOAD for such actions.


> 
>> It's not like adding new operations to NFS is all that hard.
> 
> Actually, it is harder than you think.  For various reasons, it takes five or more years to create a new NFS protocol specification, something we hope to address.
> 
>>> The mailing list is not the only place where they are discussed.  We also use conference calls, and there are face-to-face meetings too.  Not all of that content is distilled into a public record.  Very much like Linux kernel development.
>> 
>> Linux development strives very hard documenting rationales, something I
>> haven't found on the NFS list or in the repository.


There was a strong consensus in the biweekly calls to merge all of the operations together into WRITE_PLUS.
I think we also voted on this at one of the meetings.

But in any event, the document is still open and I'm glad Anna is funneling implementation experience into
it. 



