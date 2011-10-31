Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:46437 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752978Ab1JaX7u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 19:59:50 -0400
Message-ID: <4EAF366C.8040504@panasas.com>
Date: Mon, 31 Oct 2011 16:59:40 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Brent Welch <welch@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: Re: [PATCH 1/8] pnfs-obj: Remove redundant EOF from objlayout_io_state
References: <4EAF146D.5060507@panasas.com>   <1320097506-734-1-git-send-email-bharrosh@panasas.com>  <1320099857.10028.6.camel@lade.trondhjem.org>  <4EAF2521.2010204@panasas.com> <1320103768.10028.25.camel@lade.trondhjem.org>
In-Reply-To: <1320103768.10028.25.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/31/2011 04:29 PM, Trond Myklebust wrote:
>> In files-type reads in a "condense" layout. You should be careful
>> because in striping it is common place to have eof on some DSs because
>> of file holes even though there are more bits higher on in the file
>> at other DSs. You should check to return back only the answer from the
>> highest logical read DS. (Or I'm wrong in my interpretation?)
> 
> In the close-to-open cache consistency, O_DIRECT database, or file
> locking cases, then either the data has been committed, the file size
> extended and the DSes updated, 

I meant in the case all that as happened (Just opened the file) but
any particular DS can return EOF. Example:
I have 3 DSs, with stripe unit of say 1K for example.

The file has been written to 0K..1K and 2K..3K. In dense layout file-size
on DS2 is zero, right? because it was never written too. So if the client
is reading 0K..3K (All file), Will it get eof from DS2?

> or our client must know that the server
> has incomplete information because it is holding cached writes or
> layoutcommits that extend the file. In either case, the meaning of the
> eofs should be obvious.
> 

I hope that is taken care of, surly?

> Benny's old pet project of making 'tail -f' work on a log file that is
> being extended by someone else is, OTOH, subject to screwiness. However
> that case can be screwy on ordinary read-through-MDS too.
> 

Ye that one was me too. I still think file length can easily be extended
only on commit/layout_commit and not on any random write. So the above can
work. I think there is all that is needed within the protocol for servers that
*want* to support this. With any compliant client. (Ask me if you don't know how,
it involves keeping a shadow length per client up until commit, actually with
pnfs it is easier)

Thanks
Boaz
