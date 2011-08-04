Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65353 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751612Ab1HDRKV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Aug 2011 13:10:21 -0400
Subject: Re: [NLM] fcntl(F_SETLKW) yields -ENOLCK when grace period expires.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Date: Thu, 04 Aug 2011 13:10:20 -0400
In-Reply-To: <20110804164913.GG12445@fieldses.org>
References: <20110804103018.GA11727@janus>
	 <20110804163452.GE12445@fieldses.org> <20110804164313.GA17572@janus>
	 <20110804164913.GG12445@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1312477820.8919.5.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-08-04 at 12:49 -0400, J. Bruce Fields wrote: 
> On Thu, Aug 04, 2011 at 06:43:13PM +0200, Frank van Maarseveen wrote:
> > On Thu, Aug 04, 2011 at 12:34:52PM -0400, J. Bruce Fields wrote:
> > > On Thu, Aug 04, 2011 at 12:30:19PM +0200, Frank van Maarseveen wrote:
> > > > Both client- and server run 2.6.39.3, NFSv3 over UDP (without the
> > > > relock_filesystem patch proposed earlier).
> > > > 
> > > > A second client has an exclusive lock on a file on the server. The
> > > > client under test calls fcntl(F_SETLKW) to wait for the same exclusive
> > > > lock. Wireshark sees NLM V4 LOCK calls resulting in NLM_BLOCKED.
> > > > 
> > > > Next the server is rebooted. The second client recovers the lock
> > > > correctly. The client under test now receives NLM_DENIED_GRACE_PERIOD for
> > > > every NLM V4 LOCK request resulting from the waiting fcntl(F_SETLKW). When
> > > > this changes to NLM_BLOCKED after grace period expiration the fcntl
> > > > returns -ENOLCK ("No locks available.") instead of continuing to wait.
> > > 
> > > So that sounds like a client bug, and correct behavior from the server
> > > (assuming the second client was still holding the lock throughout).
> > 
> > yes.

Is the client actually asking for a blocking lock after the grace period
expires?

> > > 
> > > > server:/proc/locks shows two entries for the file after the -ENOLCK. When
> > > > the second client gives up its lock because the program running there
> > > > is killed one entry in server:/proc/locks remains indefinately: as a
> > > > result no NFS client can lock the file anymore.
> > > 
> > > But that sounds like a server bug--what do the two entries look like?
> > 
> > I think the server assumes correct client behavior; the client under
> > test resulted in a '->' prefixed entry. The fcntl at the client just
> > shouldn't have returned yet.
> 
> Oh, right, so did you see a granted callback returned to the client?

The client will reject any unsolicited GRANTED callbacks with an
NLM_LCK_DENIED. As far as I can see, nlmsvc_grant_reply() then only
removes the block, it doesn't cancel the lock...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

