From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH RFC 1/1] NLM GRANTED callback race
Date: Wed, 17 Oct 2007 18:25:49 -0400
Message-ID: <20071017222549.GQ2328@fieldses.org>
References: <EXNANE01OSQeSOzNCWb00000734@exnane01.hq.netapp.com>
	<1192639478.7573.50.camel@heimdal.trondhjem.org>
	<EXNANE013Bma4RCIlWr00000742@exnane01.hq.netapp.com>
	<20071017192340.GK2328@fieldses.org>
	<EXNANE01NMjiGwYt7yi00000750@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IiHKl-0006MV-VC
	for nfs@lists.sourceforge.net; Wed, 17 Oct 2007 15:25:48 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IiHKp-00084U-2b
	for nfs@lists.sourceforge.net; Wed, 17 Oct 2007 15:25:53 -0700
In-Reply-To: <EXNANE01NMjiGwYt7yi00000750@exnane01.hq.netapp.com>
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

On Wed, Oct 17, 2007 at 05:15:10PM -0400, Talpey, Thomas wrote:
> At 03:23 PM 10/17/2007, J. Bruce Fields wrote:
> >> BTW, the Linux server discards unsent NLM_GRANTED callbacks when
> >> the client is granted a lock in its retry case. But it performs no such
> >> checking on any responses that arrive from prior sends (see
> >> fs/lockd/svclock.c nlmsvc_grant_reply() and nlmsvc_unlink_block()).
> >> It simply processes the next blocked lock, as I described.
> >
> >I don't understand.  As far as I can tell, the server acquires a lock
> >locally at the time it sends the GRANT, and it never unlocks in the code
> >that handles replies to the grant.  Note that nlmsvc_unlink_block() just
> >remove the data structures that track the blocked (not-yet-acquired)
> >lock, and is (err, I hope) more or less a no-op in the case the lock in
> >question is already acquired.
> 
> I don't fully understand the Linux server nlm code either, but I am sure
> it suffers a similar problem, because it ends up with locks in different
> state between client and server.

OK.  But it's possible it might be a slightly different race?  Your
description of the race certainly doesn't match my understanding of the
server nlm code, but of course it's possible I could be missing
something.

> I'm happy to help you with fixing the server in conjunction with this.
> It's relatively easy to recreate it with a couple of clients and some
> error injection.

That would be great, thanks!

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
