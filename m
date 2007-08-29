From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 04/20] svc: xpt_has_wspace
Date: Wed, 29 Aug 2007 15:31:56 -0400
Message-ID: <20070829193156.GH23541@fieldses.org>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
	<20070820162329.15224.29032.stgit@dell3.ogc.int>
	<20070829185323.GF23541@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQTGd-0005KN-7M
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 12:31:55 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQTGg-0003Yg-E7
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 12:31:59 -0700
In-Reply-To: <20070829185323.GF23541@fieldses.org>
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

On Wed, Aug 29, 2007 at 02:53:23PM -0400, bfields wrote:
> On Mon, Aug 20, 2007 at 11:23:30AM -0500, Tom Tucker wrote:
> > -	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> > -	if (((atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg)*2
> > -	     > svc_sock_wspace(svsk))
> > -	    && !test_bit(SK_CLOSE, &svsk->sk_flags)
> > -	    && !test_bit(SK_CONN, &svsk->sk_flags)) {
> > -		/* Don't enqueue while not enough space for reply */
> > -		dprintk("svc: socket %p  no space, %d*2 > %ld, not enqueued\n",
> > -			svsk->sk_sk, atomic_read(&svsk->sk_reserved)+serv->sv_max_mesg,
> > -			svc_sock_wspace(svsk));
> 
> Actually, I'm confused by the existing code here.  The intention seems
> to be to stop accepting requests until we have adequate space for the
> reply.  But the (&& !test_bit(SK_CONN, &svsk->sk_flags)) means that the
> condition always fails on a socket with SK_CONN set.  From a quick skim
> of uses of SK_CONN in svcsock.c it looks SK_CONN is normally set on an
> established connection.
> 
> I must be missing something obvious.  Or the test is reversed.

Oh, wait, so SK_CONN is also always cleared for UDP.  Is there some
reason we only want to do this test in the UDP case?  If so, then I
don't know why svc_sock_wspace() is bothering with the TCP case.  Hm.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
