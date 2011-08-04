Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([83.163.148.79]:60217 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754522Ab1HDR1M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Aug 2011 13:27:12 -0400
Date: Thu, 4 Aug 2011 19:27:10 +0200
From: Frank van Maarseveen <frankvm@frankvm.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [NLM] fcntl(F_SETLKW) yields -ENOLCK when grace period expires.
Message-ID: <20110804172710.GB18087@janus>
References: <20110804103018.GA11727@janus>
 <20110804163452.GE12445@fieldses.org>
 <20110804164313.GA17572@janus>
 <20110804164913.GG12445@fieldses.org>
 <1312477820.8919.5.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1312477820.8919.5.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 04, 2011 at 01:10:20PM -0400, Trond Myklebust wrote:
> On Thu, 2011-08-04 at 12:49 -0400, J. Bruce Fields wrote: 
> > On Thu, Aug 04, 2011 at 06:43:13PM +0200, Frank van Maarseveen wrote:
> > > On Thu, Aug 04, 2011 at 12:34:52PM -0400, J. Bruce Fields wrote:
> > > > On Thu, Aug 04, 2011 at 12:30:19PM +0200, Frank van Maarseveen wrote:
> > > > > Both client- and server run 2.6.39.3, NFSv3 over UDP (without the
> > > > > relock_filesystem patch proposed earlier).
> > > > > 
> > > > > A second client has an exclusive lock on a file on the server. The
> > > > > client under test calls fcntl(F_SETLKW) to wait for the same exclusive
> > > > > lock. Wireshark sees NLM V4 LOCK calls resulting in NLM_BLOCKED.
> > > > > 
> > > > > Next the server is rebooted. The second client recovers the lock
> > > > > correctly. The client under test now receives NLM_DENIED_GRACE_PERIOD for
> > > > > every NLM V4 LOCK request resulting from the waiting fcntl(F_SETLKW). When
> > > > > this changes to NLM_BLOCKED after grace period expiration the fcntl
> > > > > returns -ENOLCK ("No locks available.") instead of continuing to wait.
> > > > 
> > > > So that sounds like a client bug, and correct behavior from the server
> > > > (assuming the second client was still holding the lock throughout).
> > > 
> > > yes.
> 
> Is the client actually asking for a blocking lock after the grace period
> expires?

yes, according to my interpretation of that of wireshark, see reply to Bruce.

-- 
Frank
