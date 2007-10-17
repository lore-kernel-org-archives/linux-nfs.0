From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH RFC 1/1] NLM GRANTED callback race
Date: Wed, 17 Oct 2007 17:15:10 -0400
Message-ID: <EXNANE01NMjiGwYt7yi00000750@exnane01.hq.netapp.com>
References: <EXNANE01OSQeSOzNCWb00000734@exnane01.hq.netapp.com>
	<1192639478.7573.50.camel@heimdal.trondhjem.org>
	<EXNANE013Bma4RCIlWr00000742@exnane01.hq.netapp.com>
	<20071017192340.GK2328@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IiGLW-0000Hh-Kd
	for nfs@lists.sourceforge.net; Wed, 17 Oct 2007 14:22:30 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IiGLb-0003hY-Ul
	for nfs@lists.sourceforge.net; Wed, 17 Oct 2007 14:22:36 -0700
In-Reply-To: <20071017192340.GK2328@fieldses.org>
References: <EXNANE01OSQeSOzNCWb00000734@exnane01.hq.netapp.com>
	<1192639478.7573.50.camel@heimdal.trondhjem.org>
	<EXNANE013Bma4RCIlWr00000742@exnane01.hq.netapp.com>
	<20071017192340.GK2328@fieldses.org>
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

At 03:23 PM 10/17/2007, J. Bruce Fields wrote:
>> BTW, the Linux server discards unsent NLM_GRANTED callbacks when
>> the client is granted a lock in its retry case. But it performs no such
>> checking on any responses that arrive from prior sends (see
>> fs/lockd/svclock.c nlmsvc_grant_reply() and nlmsvc_unlink_block()).
>> It simply processes the next blocked lock, as I described.
>
>I don't understand.  As far as I can tell, the server acquires a lock
>locally at the time it sends the GRANT, and it never unlocks in the code
>that handles replies to the grant.  Note that nlmsvc_unlink_block() just
>remove the data structures that track the blocked (not-yet-acquired)
>lock, and is (err, I hope) more or less a no-op in the case the lock in
>question is already acquired.

I don't fully understand the Linux server nlm code either, but I am sure
it suffers a similar problem, because it ends up with locks in different
state between client and server. I'm happy to help you with fixing the
server in conjunction with this. It's relatively easy to recreate it with
a couple of clients and some error injection.

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
