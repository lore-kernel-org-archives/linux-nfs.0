Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:37512 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752642Ab1KACZy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 22:25:54 -0400
Subject: Re: [PATCH 1/8] pnfs-obj: Remove redundant EOF from
 objlayout_io_state
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Brent Welch <welch@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Date: Mon, 31 Oct 2011 22:25:52 -0400
In-Reply-To: <4EAF366C.8040504@panasas.com>
References: <4EAF146D.5060507@panasas.com>
	   <1320097506-734-1-git-send-email-bharrosh@panasas.com>
	  <1320099857.10028.6.camel@lade.trondhjem.org>
	  <4EAF2521.2010204@panasas.com>
	 <1320103768.10028.25.camel@lade.trondhjem.org>
	 <4EAF366C.8040504@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1320114352.10028.33.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-10-31 at 16:59 -0700, Boaz Harrosh wrote: 
> On 10/31/2011 04:29 PM, Trond Myklebust wrote:
> >> In files-type reads in a "condense" layout. You should be careful
> >> because in striping it is common place to have eof on some DSs because
> >> of file holes even though there are more bits higher on in the file
> >> at other DSs. You should check to return back only the answer from the
> >> highest logical read DS. (Or I'm wrong in my interpretation?)
> > 
> > In the close-to-open cache consistency, O_DIRECT database, or file
> > locking cases, then either the data has been committed, the file size
> > extended and the DSes updated, 
> 
> I meant in the case all that as happened (Just opened the file) but
> any particular DS can return EOF. Example:
> I have 3 DSs, with stripe unit of say 1K for example.
> 
> The file has been written to 0K..1K and 2K..3K. In dense layout file-size
> on DS2 is zero, right? because it was never written too. So if the client
> is reading 0K..3K (All file), Will it get eof from DS2?

Once the client issues LAYOUTCOMMIT, the server will need to ensure that
DS2 gets filled too. Dense file layouts aren't supposed to have holes
according to 13.4.4. (the whole point is to support filesystems like
NTFS that don't do sparse files).

> > or our client must know that the server
> > has incomplete information because it is holding cached writes or
> > layoutcommits that extend the file. In either case, the meaning of the
> > eofs should be obvious.
> > 
> 
> I hope that is taken care of, surly?
> 
> > Benny's old pet project of making 'tail -f' work on a log file that is
> > being extended by someone else is, OTOH, subject to screwiness. However
> > that case can be screwy on ordinary read-through-MDS too.
> > 
> 
> Ye that one was me too. I still think file length can easily be extended
> only on commit/layout_commit and not on any random write. So the above can
> work. I think there is all that is needed within the protocol for servers that
> *want* to support this. With any compliant client. (Ask me if you don't know how,
> it involves keeping a shadow length per client up until commit, actually with
> pnfs it is easier)

You can't do it safely with MDS only due to the issue of WRITE
reordering on the wire+server and pNFS just adds more ways to reorder
those writes. So unless you play games with layout recalls etc. in order
to order the READs and WRITEs from different clients (which goes against
the premise that layouts do not constitute a caching protocol) then I
fail to see how pNFS can help.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

