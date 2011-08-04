Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33841 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751084Ab1HDQex (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Aug 2011 12:34:53 -0400
Date: Thu, 4 Aug 2011 12:34:52 -0400
To: Frank van Maarseveen <frankvm@frankvm.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [NLM] fcntl(F_SETLKW) yields -ENOLCK when grace period expires.
Message-ID: <20110804163452.GE12445@fieldses.org>
References: <20110804103018.GA11727@janus>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110804103018.GA11727@janus>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 04, 2011 at 12:30:19PM +0200, Frank van Maarseveen wrote:
> Both client- and server run 2.6.39.3, NFSv3 over UDP (without the
> relock_filesystem patch proposed earlier).
> 
> A second client has an exclusive lock on a file on the server. The
> client under test calls fcntl(F_SETLKW) to wait for the same exclusive
> lock. Wireshark sees NLM V4 LOCK calls resulting in NLM_BLOCKED.
> 
> Next the server is rebooted. The second client recovers the lock
> correctly. The client under test now receives NLM_DENIED_GRACE_PERIOD for
> every NLM V4 LOCK request resulting from the waiting fcntl(F_SETLKW). When
> this changes to NLM_BLOCKED after grace period expiration the fcntl
> returns -ENOLCK ("No locks available.") instead of continuing to wait.

So that sounds like a client bug, and correct behavior from the server
(assuming the second client was still holding the lock throughout).

> server:/proc/locks shows two entries for the file after the -ENOLCK. When
> the second client gives up its lock because the program running there
> is killed one entry in server:/proc/locks remains indefinately: as a
> result no NFS client can lock the file anymore.

But that sounds like a server bug--what do the two entries look like?

Also, what filesystem are you exporting?

--b.
