From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH RFC 1/1] NLM GRANTED callback race
Date: Wed, 17 Oct 2007 15:23:40 -0400
Message-ID: <20071017192340.GK2328@fieldses.org>
References: <EXNANE01OSQeSOzNCWb00000734@exnane01.hq.netapp.com>
	<1192639478.7573.50.camel@heimdal.trondhjem.org>
	<EXNANE013Bma4RCIlWr00000742@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IiEUm-0005Vx-ET
	for nfs@lists.sourceforge.net; Wed, 17 Oct 2007 12:23:56 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IiEUr-0001JV-C3
	for nfs@lists.sourceforge.net; Wed, 17 Oct 2007 12:24:01 -0700
In-Reply-To: <EXNANE013Bma4RCIlWr00000742@exnane01.hq.netapp.com>
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

On Wed, Oct 17, 2007 at 01:30:27PM -0400, Talpey, Thomas wrote:
> At 12:44 PM 10/17/2007, Trond Myklebust wrote:
> >So what will happen in this case if the NLM_GRANTED reply races with my
> >UNLOCK call to release the lock?
> 
> Alas, that is the beast which is NLM. The callback reply can race the UNLOCK
> even without this change. I can't fix that, it's a protocol issue. Wait a sec
> yes I can, it's called NFSv4.1 Sessions. :-)
> 
> >Servers have to perform consistency checks on NLM_GRANTED, or the
> >protocol will break. Once the client has been granted the lock via a
> >separate LOCK call, then the result of the NLM_GRANTED request _MUST_ be
> >ignored on the server.
> 
> I agree the server should do this, but the spec doesn't say so, there are
> servers out there who don't, and the protocol itself doesn't help. So the
> intent of this fix is to restore order, even though there are perhaps
> better-but-still-imperfect fixes that require global change.
> 
> BTW, the Linux server discards unsent NLM_GRANTED callbacks when
> the client is granted a lock in its retry case. But it performs no such
> checking on any responses that arrive from prior sends (see
> fs/lockd/svclock.c nlmsvc_grant_reply() and nlmsvc_unlink_block()).
> It simply processes the next blocked lock, as I described.

I don't understand.  As far as I can tell, the server acquires a lock
locally at the time it sends the GRANT, and it never unlocks in the code
that handles replies to the grant.  Note that nlmsvc_unlink_block() just
remove the data structures that track the blocked (not-yet-acquired)
lock, and is (err, I hope) more or less a no-op in the case the lock in
question is already acquired.

But that's just based on a quick look at the code, and I haven't tested
it.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
