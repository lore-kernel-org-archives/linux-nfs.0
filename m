From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 04/20] svc: xpt_has_wspace
Date: Wed, 29 Aug 2007 15:11:16 -0500
Message-ID: <1188418276.7502.29.camel@trinity.ogc.int>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
	<20070820162329.15224.29032.stgit@dell3.ogc.int>
	<20070829185323.GF23541@fieldses.org>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQTuE-00016M-VG
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 13:12:51 -0700
Received: from ms-smtp-04.texas.rr.com ([24.93.47.43])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQTuI-0006D8-61
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 13:12:55 -0700
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

On Wed, 2007-08-29 at 14:53 -0400, J. Bruce Fields wrote:
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

Here's my understanding of the code...

This code combines checks for listening endpoints and connected
endpoints in the same function (_has_wspace). 

The SK_CONN check is for listening endpoints. SK_CONN is only set on
listening endpoints when there is a connection request outstanding. I
think of it as the SK_DATA bit for listening endpoints. The intent is
that the thread accepting connections continues to do so until there are
no more connection requests outstanding, at which point it clears
SK_CONN and calls svc_sock_enqueue. The goal is that no more than one
thread is handling new connection requests on a transport. 

SK_CONN should never be set on a connected socket. The _has_wspace
function doesn't really have any meaning for listening endpoints and
should always return 'true'.

A second check is for connected endpoints. In this case, the _has_wspace
check is to ensure that there is enough write space to reply to the
request. If there's not, don't enqueue the transport and schedule a
thread because it will just block in send.

The SK_CLOSE check applies to both types, although a listening endpoint
doesn't ever really close unless knsfd is shut down or an error occurs.
It's there to ensure we always fall through to handle clean up on a
closed socket.

Perhaps I don't understand the nuances fully, but since all the terms in
the condition are AND, they will all be tested and unless there is a
race I'm missing the order doesn't matter. 

In any event, I think it would be easier to understand if we broken the
tests up into two if-statements with a simple comment for each.

> I must be missing something obvious.  Or the test is reversed.
> 
> --b.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
