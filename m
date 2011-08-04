Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([83.163.148.79]:60215 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752359Ab1HDRYy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Aug 2011 13:24:54 -0400
Date: Thu, 4 Aug 2011 19:24:52 +0200
From: Frank van Maarseveen <frankvm@frankvm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [NLM] fcntl(F_SETLKW) yields -ENOLCK when grace period expires.
Message-ID: <20110804172452.GA18087@janus>
References: <20110804103018.GA11727@janus>
 <20110804163452.GE12445@fieldses.org>
 <20110804164313.GA17572@janus>
 <20110804164913.GG12445@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110804164913.GG12445@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 04, 2011 at 12:49:13PM -0400, J. Bruce Fields wrote:
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
> > 
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

Hmm no, maybe it is a server bug. These are the final request and reply
(which result in the incorrect -ENOLCK for F_SETLKW at the client under
test), decoded by wireshark:

No.     Time        Source                Destination           Protocol Info
    529 225.386189  172.17.1.124          172.17.1.49           NLM      V4 LOCK Call (Reply In 530) FH:0xb17f38ea svid:10 pos:0-0

Frame 529: 246 bytes on wire (1968 bits), 246 bytes captured (1968 bits)
Network Lock Manager Protocol
    [Program Version: 4]
    [V4 Procedure: LOCK (2)]
    cookie: <DATA>
        length: 4
        contents: <DATA>
    block: Yes
    exclusive: Yes
    lock
        caller_name: lokka.tasking.nl
            length: 16
            contents: lokka.tasking.nl
        fh
            length: 28
            [hash (CRC-32): 0xb17f38ea]
            decode type as: unknown
            filehandle: 01000601e66f5c256cb3414eba710fcd882a67201b000000...
        owner: <DATA>
            length: 19
            contents: <DATA>
            fill bytes: opaque data
        svid: 10
        l_offset: 0
        l_len: 0
    reclaim: No
    state: 87

No.     Time        Source                Destination           Protocol Info
    530 225.386368  172.17.1.49           172.17.1.124          NLM      V4 LOCK Reply (Call In 529) NLM_BLOCKED

Frame 530: 78 bytes on wire (624 bits), 78 bytes captured (624 bits)
Network Lock Manager Protocol
    [Program Version: 4]
    [V4 Procedure: LOCK (2)]
    cookie: <DATA>
        length: 4
        contents: <DATA>
    stat: NLM_BLOCKED (3)


-- 
Frank
