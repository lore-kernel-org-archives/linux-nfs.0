From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd bugfixes
Date: Mon, 12 Nov 2007 18:17:03 -0500
Message-ID: <20071112231703.GD2645@fieldses.org>
References: <1194901503-23105-1-git-send-email-bfields@citi.umich.edu>
	<18232.52970.213438.902011@notabene.brown>
	<20071112221349.GA2645@fieldses.org>
	<18232.54549.271030.214405@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IriWj-0000rK-3r
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 15:17:09 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IriWm-0004dC-Tj
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 15:17:15 -0800
In-Reply-To: <18232.54549.271030.214405@notabene.brown>
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

On Tue, Nov 13, 2007 at 09:35:01AM +1100, Neil Brown wrote:
> 
> (CC: trimmed - as Bruce says: separate discussion)
> 
> On Monday November 12, bfields@fieldses.org wrote:
> > On Tue, Nov 13, 2007 at 09:08:42AM +1100, Neil Brown wrote:
> > > Calling nfsd_setuser an extra time does open us up for a very tiny
> > > possibility of an ENOMEM at an awkward time.
> > 
> > Hm.  Could you give an example of possible consequences?
> 
> Just that you could get an ENOMEM in the middle of a NFSv4 COMPOUND.
> I guess that should result in NFSERR_RESOURCE and we just hope the
> client is able to cope and resend the remainder of the compound.
> Though looking at the code, ENOMEM becomes nfserr_dropit... does that
> mean the we would drop the whole request and the client would need to
> resend, possibly duplicating non-idempotent portions?

Yeah, OK, that's another one for my list of compound processing problems
to worry about.  (Others:

	- a deferral for an export upcall can similarly lead to
	  incorrect behavior on nonidempotent operations; if we could
	  fix this we could also eliminate the nfs4idmap.c special case,
	  which would probably enable some other cleanup.  I've made a
	  couple half-hearted attempts to fix this but don't have
	  anything finished yet.

	- We've still got the reply cache turned off for nfsv4!  I think
	  it was originally turned off just because whoever did it
	  didn't want to figure out which compounds to cache.  That's
	  probably not hard to fix, but last I checked I didn't think
	  our reply cache actually helped much in the tcp case (the only
	  case we care about).  So that needs to be fixed first.  I've
	  done no work on this yet.

)--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
