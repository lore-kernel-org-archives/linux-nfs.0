Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:43771 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756769AbaAFWt7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jan 2014 17:49:59 -0500
Received: by mail-ie0-f173.google.com with SMTP id to1so19456872ieb.32
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jan 2014 14:49:58 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH 0/3] READ_PLUS rough draft
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140106223201.GA3342@fieldses.org>
Date: Mon, 6 Jan 2014 17:49:56 -0500
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <634D69C0-6B86-4FCE-80E4-C66F131F0ED3@primarydata.com>
References: <1389045433-22990-1-git-send-email-Anna.Schumaker@netapp.com> <20140106223201.GA3342@fieldses.org>
To: Dr Fields James Bruce <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 6, 2014, at 17:32, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Mon, Jan 06, 2014 at 04:57:10PM -0500, Anna Schumaker wrote:
>> These patches are my initial implementation of READ_PLUS.  I still have a
>> few issues to work out before they can be applied, but I wanted to submit
>> them anyway to get feedback before going much further.  These patches were
>> developed on top of my earlier SEEK and WRITE_PLUS patches, and probably
>> won't apply cleanly without them (I am willing to reorder things if necessary!).
>> 
>> On the server side, I handle the cases where a file is 100% hole, 100% data
>> or hole followed by data.  Any holes after a data segment will be expanded
>> to zeros on the wire.
> 
> I assume that for "a file" I should read "the requested range of the
> file"?
> 
> hole+data+hole should also be doable, shouldn't it?  I'd think the real
> problem would be multiple data extents.
> 
>> This is due to a limitation in the the NFSD
>> encode-to-page function that will adjust pointers to point to the xdr tail
>> after reading a file to the "pages" section.  Bruce, do you have any
>> suggestions here?
> 
> The server xdr encoding needs a rewrite.  I'll see if I can ignore you
> all and put my head down and get a version of that posted this week.
> 
> That should make it easier to return all the data, though it will turn
> off zero-copy in the case of multiple data extents.
> 
> If we want READ_PLUS to support zero copy in the case of multiple
> extents then I think we need a new data structure to represent the
> resulting rpc reply.  An xdr buf only knows how to insert one array of
> pages in the middle of the data.  Maybe a list of xdr bufs?
> 
> But that's an annoying job and possibly a premature optimization.
> 
> It might be useful to first understand the typical distribution of holes
> in a file and how likely various workloads are to produce reads with
> multiple holes in the middle.

Right. The main purpose of this patch set is to demonstrate that READ PLUS hole feature is pretty much useless in the cases you list above.

Cheers
  Trond