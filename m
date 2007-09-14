From: Greg Banks <gnb@sgi.com>
Subject: Re: Question about svc_age_temp_sockets
Date: Fri, 14 Sep 2007 19:16:44 +1000
Message-ID: <20070914091644.GD21965@sgi.com>
References: <C30998A8.138C0%tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IW7I7-0001DZ-OJ
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 02:16:48 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1IW7I8-0007m6-Vo
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 02:16:50 -0700
In-Reply-To: <C30998A8.138C0%tom@opengridcomputing.com>
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

On Sun, Sep 09, 2007 at 12:33:44PM -0500, Tom Tucker wrote:
> 
> I'm confused about how svc_age_temp_sockets is supposed to work. [...]
> - There's a check for a zero sk_inuse count. I don't see a legitimate way
> for a socket to be on the tempsocks list with a zero refcount.
> 
> Am I just hopelessly confused here or is this code broken?

When the code was written, the natural idle state of a svcsock
was sk_inuse == 0.  Later, in commit

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=aaf68cfbf2241d24d46583423f6bff5c47e088b3

Neil changed this so the natural idle state is sk_inuse == 1 and
the sk_inuse == 0 condition only happens transiently during socket
shutdown.  This is a far better design, but it seems the check
in svc_age_temp_sockets() wasn't updated at the time and is now
dead code.  It could probably be removed.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
