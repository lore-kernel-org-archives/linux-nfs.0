Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:36426 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751762Ab3KDRX3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Nov 2013 12:23:29 -0500
Message-ID: <5277D80F.8050106@netapp.com>
Date: Mon, 4 Nov 2013 12:23:27 -0500
From: Anna Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com> <1382972247-1108-4-git-send-email-bjschuma@netapp.com> <20131102135238.GB18961@infradead.org> <5277CE23.6010207@netapp.com> <20131104170345.GA31499@infradead.org>
In-Reply-To: <20131104170345.GA31499@infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/04/2013 12:03 PM, Christoph Hellwig wrote:
> On Mon, Nov 04, 2013 at 11:41:07AM -0500, Anna Schumaker wrote:
>>> what else it would be for.
>>
>> My understanding is that if I call fallocate with a mode of "0" it will write a range of 0s to the file.
> 
> While writing zeroes to the file would be a correct implementation,
> that's now how the operation is defined or usually implemented.  The
> defintion is that the blocks in the range will be allocated, and reads
> from it will return zero (and the file size will be updated if needed).
> 
> The usual way to implement it is to created extents in an "unwritten
> state" that will return zeroes when read, even if those zeroes didn't
> make it to disk.

And that's all done through metadata?  Doing the commit_metadata() call makes a bit more sense now.

> 
>> I'll move the fsync() call here and only do it if the client doesn't ask for NFS_UNSTABLE.
> 
> As said the right way to handle it would be to use commit_metadata, as
> the cache flushes a fsync does would be unessecary and too expensive for
> many workloads typically using fallocate.

Okay, sorry for me not understanding earlier!

> 
>>>
>>> Btw, how did anyone come up with the name WRITE PLUS for something that
>>> doesn't actually involve any writes?
>>>
>>
>> Write plus does write more than just holes, I just didn't implement that part of the spec.  I'm implementing the NFS4_CONTENT_HOLE arm, but NFS4_CONTENT_DATA is intended to eventually replace the WRITE operation.
> 
> Where is WRITE PLUS defined?  I the various
> draft-ietf-nfsv4-minorversion2-*.txt I can only find what appears to be
> the predecessor, but that doesn't have a data arm.
> 
> Also what does the data arm buy us over good old WRITE?
> 

I've been working off of draft #21, the most recent commit is 2b3ab1740b1ea843faa59566fb4213a42d8c724a from Aug 19.  The eventual goal is to phase out WRITE and replace it with WRITE_PLUS, but that won't happen until at least 4.3.  I don't know why it's being done this way instead of just adding an FALLOCATE operation.

