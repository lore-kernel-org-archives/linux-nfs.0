From: Jeff Layton <jlayton@redhat.com>
Subject: Re: lockd not responding
Date: Wed, 12 Sep 2007 20:27:21 -0400
Message-ID: <20070912202721.d8f70ac1.jlayton@redhat.com>
References: <fc84aa$o11$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: kenneth johansson <ken@kenjo.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVcYK-0002Rb-29
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 17:27:28 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVcYO-0006wN-Jq
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 17:27:32 -0700
In-Reply-To: <fc84aa$o11$1@sea.gmane.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 12 Sep 2007 07:26:02 +0000 (UTC)
kenneth johansson <ken@kenjo.org> wrote:

> Got a warning from the lock validating check again and
> later a unresponsive lockd with a backtrace this time
> actually at the same place the lock warning was on.

FWIW, I think I ran into the exact same problem recently. I opened a
BZ case for it so I wouldn't forget about it, but haven't had time to
track it down:

https://bugzilla.redhat.com/show_bug.cgi?id=280311

I'm not certain that lockd was stuck at the time, since I had some
other things going on with the box, but it may have been...

-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
