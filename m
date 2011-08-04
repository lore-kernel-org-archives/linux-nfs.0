Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([83.163.148.79]:59711 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751903Ab1HDQnP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Aug 2011 12:43:15 -0400
Date: Thu, 4 Aug 2011 18:43:13 +0200
From: Frank van Maarseveen <frankvm@frankvm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [NLM] fcntl(F_SETLKW) yields -ENOLCK when grace period expires.
Message-ID: <20110804164313.GA17572@janus>
References: <20110804103018.GA11727@janus>
 <20110804163452.GE12445@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110804163452.GE12445@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 04, 2011 at 12:34:52PM -0400, J. Bruce Fields wrote:
> On Thu, Aug 04, 2011 at 12:30:19PM +0200, Frank van Maarseveen wrote:
> > Both client- and server run 2.6.39.3, NFSv3 over UDP (without the
> > relock_filesystem patch proposed earlier).
> > 
> > A second client has an exclusive lock on a file on the server. The
> > client under test calls fcntl(F_SETLKW) to wait for the same exclusive
> > lock. Wireshark sees NLM V4 LOCK calls resulting in NLM_BLOCKED.
> > 
> > Next the server is rebooted. The second client recovers the lock
> > correctly. The client under test now receives NLM_DENIED_GRACE_PERIOD for
> > every NLM V4 LOCK request resulting from the waiting fcntl(F_SETLKW). When
> > this changes to NLM_BLOCKED after grace period expiration the fcntl
> > returns -ENOLCK ("No locks available.") instead of continuing to wait.
> 
> So that sounds like a client bug, and correct behavior from the server
> (assuming the second client was still holding the lock throughout).

yes.

> 
> > server:/proc/locks shows two entries for the file after the -ENOLCK. When
> > the second client gives up its lock because the program running there
> > is killed one entry in server:/proc/locks remains indefinately: as a
> > result no NFS client can lock the file anymore.
> 
> But that sounds like a server bug--what do the two entries look like?

I think the server assumes correct client behavior; the client under
test resulted in a '->' prefixed entry. The fcntl at the client just
shouldn't have returned yet.

> 
> Also, what filesystem are you exporting?

ext4

-- 
Frank
