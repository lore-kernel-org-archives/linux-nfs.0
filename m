From: Neil Brown <neilb@suse.de>
Subject: Re: nfsd bugfixes
Date: Tue, 13 Nov 2007 09:35:01 +1100
Message-ID: <18232.54549.271030.214405@notabene.brown>
References: <1194901503-23105-1-git-send-email-bfields@citi.umich.edu>
	<18232.52970.213438.902011@notabene.brown>
	<20071112221349.GA2645@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Irhs8-00056n-46
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 14:35:12 -0800
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IrhsC-0002fs-CY
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 14:35:18 -0800
In-Reply-To: message from J. Bruce Fields on Monday November 12
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


(CC: trimmed - as Bruce says: separate discussion)

On Monday November 12, bfields@fieldses.org wrote:
> On Tue, Nov 13, 2007 at 09:08:42AM +1100, Neil Brown wrote:
> > Calling nfsd_setuser an extra time does open us up for a very tiny
> > possibility of an ENOMEM at an awkward time.
> 
> Hm.  Could you give an example of possible consequences?

Just that you could get an ENOMEM in the middle of a NFSv4 COMPOUND.
I guess that should result in NFSERR_RESOURCE and we just hope the
client is able to cope and resend the remainder of the compound.
Though looking at the code, ENOMEM becomes nfserr_dropit... does that
mean the we would drop the whole request and the client would need to
resend, possibly duplicating non-idempotent portions?

Mainly, it just feels unclean.

> 
> (Though note this is somewhat of a separate discussion, since this
> particular patch doesn't add a call to nfsd_setuser().)

Hmm, you are right, we already call nfsd_setuser in both paths, you we
just adding the check for privileged port - doh ;-)

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
