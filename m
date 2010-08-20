Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53128 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753084Ab0HTQAV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Aug 2010 12:00:21 -0400
Date: Fri, 20 Aug 2010 11:58:09 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: david.noveck@emc.com
Cc: Trond.Myklebust@netapp.com, nfsv4@ietf.org, linux-nfs@vger.kernel.org
Subject: Re: [nfsv4] OPEN_DOWNGRADE and posix byte range locking issue
Message-ID: <20100820155809.GA10280@fieldses.org>
References: <1278545423.15524.26.camel@heimdal.trondhjem.org>
 <BF3BB6D12298F54B89C8DCC1E4073D8001ADE6C8@CORPUSMX50A.corp.emc.com>
 <1278623332.13551.47.camel@heimdal.trondhjem.org>
 <20100819164448.GF30151@fieldses.org>
 <BF3BB6D12298F54B89C8DCC1E4073D80024B7187@CORPUSMX50A.corp.emc.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BF3BB6D12298F54B89C8DCC1E4073D80024B7187@CORPUSMX50A.corp.emc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 20, 2010 at 11:35:02AM -0400, david.noveck@emc.com wrote:
> It isn't the server's problem.  There is no way the server has access to
> the Vfs opens as visible objects

I was talking about how our server maps incoming open requests to vfs
opens when talking to its own vfs layer.

Whatever, it's my problem--I can deal with it.

> or as having the assignment of locks to
> such fine-grained opens.
> 
> I'm kind of thinking that this shows we (Bruce, me, and rest of the
> working group) made a mistake in that sort of a design in which we do
> not allow multiple distinguished open objects for a given fh-owner pair.
> Anyway the problems that it caused are pretty minor and we don't know
> what problems would have been generated with an alternate design.  I
> think this is something to look at in NFSv5 or the next NFSv4.1-style
> minor version, if any. 

But, yes, I have found the open upgrade/downgrade behavior confusing.

--b.

> 
> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org] 
> Sent: Thursday, August 19, 2010 12:45 PM
> To: Trond Myklebust
> Cc: Noveck, David; nfsv4@ietf.org; linux-nfs@vger.kernel.org
> Subject: Re: [nfsv4] OPEN_DOWNGRADE and posix byte range locking issue
> 
> > > -----Original Message-----
> > > From: nfsv4-bounces@ietf.org [mailto:nfsv4-bounces@ietf.org] On
> Behalf
> > > Of Trond Myklebust
> > > Sent: Wednesday, July 07, 2010 7:30 PM
> > > To: nfsv4@ietf.org
> > > Subject: [nfsv4] OPEN_DOWNGRADE and posix byte range locking issue
> > > 
> > > Neither RFC3530, nor RFC5661 appear to list NFS4ERR_LOCKS_HELD as a
> > > valid response when the client calls OPEN_DOWNGRADE.
> > > 
> > > The question is: what should the server then do if the NFS client
> holds
> > > a WRITE_LT lock, but then asks for an OPEN_DOWNGRADE to
> > > OPEN4_SHARE_ACCESS_READ. I understand that this is sanctioned in
> Windows
> > > server environments, but it should definitely be forbidden in a
> POSIX
> > > environment, and NFS4ERR_LOCKS_HELD would appear to fit the bill...
> 
> A bizarre variation: the linux server associates vfs opens with
> stateid's.  Locks are performed on vfs opens, and the vfs will complain
> if you attempt to close a file that still has locks associated with it.
> 
> The sequence
> 
> 	open RW
> 	lock R
> 	open R
> 	open downgrade to R
> 
> would therefore be implemented at the vfs level as:
> 
> 	open RW -> f
> 	lock R on f
> 	open R -> g
> 	close f
> 
> Oops.  We're stuck with ditching the lock (or erroring out) even though
> it's still compatible with the new config option.
> 
> Well, I suppose this is my problem: either I should get a new vfs open
> for the use of the lock, or represent the original RW open by two vfs
> open's.
> 
> It's not something a unix-like client could do, I think, but I don't
> think it's safe for me to assume I can reject it?
> 
> --b.
> 
