From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH RFC v2 06/21] nfs: nfs4xdr: optimize RESERVE_SPACE in
 encode_create_session and encode_sequence
Date: Fri, 14 Aug 2009 15:28:03 -0400
Message-ID: <1250278083.5476.51.camel@heimdal.trondhjem.org>
References: <4A8571E2.8020800@panasas.com>
	 <1250259553-13672-1-git-send-email-bhalevy@panasas.com>
	 <9734995E-20F8-4E53-83CD-BA95145D15ED@oracle.com>
	 <1250269055.5476.11.camel@heimdal.trondhjem.org>
	 <10346A84-B1F3-4161-B518-0F5D68D2DC9B@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12612 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756271AbZHNT2T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Aug 2009 15:28:19 -0400
In-Reply-To: <10346A84-B1F3-4161-B518-0F5D68D2DC9B@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-08-14 at 14:49 -0400, Chuck Lever wrote:
> The effective difference between foo_maxsz and the other macros is  
> only in the variable size parts of each argument set.  maxsz can be  
> constructed with a number of fixed size pieces that can be used  
> separately or combined into a single macro that _is_ appropriate to  
> use in the XDR routines.  Since we are explicitly adding the actual  
> lengths of variable sized arguments before calling reserve_space(), I  
> don't see a problem with using length macros for each argument.
> 
> The risk of using naked integers in the XDR routines is that if  
> there's a length bug in the maxsz macros, we also need to visit the  
> XDR routines carefully to find other instances of the same problem.   
> If we use macros everywhere, then fixing one length macro will address  
> all similar instances at once...

No, it won't. The encode_*/decode_* routines reflect unique operations.
There is little or no overlap between what they encode/decode, so there
isn't much room for sharing macros between them.
Instead, we attempt to describe each encode_*/decode_* routine using its
own *maxsz macro.

The exceptions to the 'no sharing' rule are sub-objects like stateids,
verifiers, and session ids. There we _do_ use macros both in the
reserve_space() calls, and in the ensuing opaque_encode/decode call.
However as you saw in the patch series, a better alternative is to give
them their own unique encode_stateid/decode_stateid routine that can be
checked once and for all against
encode_stateid_maxsz/decode_stateid_maxsz.

> Benny has combined the reserve_space() calls into a single call in  
> each XDR routine, thus visually separating the marshalling of each  
> argument from its related XDR buffer management.  If you already know  
> what you're looking at, that's not much of an issue.  But for those  
> who have never seen this code before, I think this reduces legibility  
> in favor of a slight code optimization.  Using length macros would  
> make it easier to understand the relationship between marshalling and  
> buffer management in each routine.

I'm really not that concerned about the woeful tale of the troubles of
the first-time reader.

What do I care about is that someone who knows what they are doing can
check the code and see at a glance whether or not there is a discrepancy
between the reserve_space() call, and what is actually attempted read
using the resulting pointer.

If the reserve_space() call uses numerical values, then you can do that.
If it uses macros all over the place, then you can't...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
