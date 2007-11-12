From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd bugfixes
Date: Mon, 12 Nov 2007 17:13:49 -0500
Message-ID: <20071112221349.GA2645@fieldses.org>
References: <1194901503-23105-1-git-send-email-bfields@citi.umich.edu>
	<18232.52970.213438.902011@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, stable@kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IrhXT-0002ue-Rq
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 14:13:51 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IrhXY-00051q-3o
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 14:13:57 -0800
In-Reply-To: <18232.52970.213438.902011@notabene.brown>
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

On Tue, Nov 13, 2007 at 09:08:42AM +1100, Neil Brown wrote:
> On Monday November 12, bfields@citi.umich.edu wrote:
> > The following two patches are nfsd bugfixes that I believe are
> > appropriate for 2.6.24 and 2.6.23.y.
> > 
> > --b.
> > 
> 
> Both
>   Reviewed-By: NeilBrown <neilb@suse.de>

Thanks, Neil.

> Calling nfsd_setuser an extra time does open us up for a very tiny
> possibility of an ENOMEM at an awkward time.

Hm.  Could you give an example of possible consequences?

(Though note this is somewhat of a separate discussion, since this
particular patch doesn't add a call to nfsd_setuser().)

> We could remove that entirely for NFSEXP_ALLSQUASH by allocating an
> empty group_info at export time and just using a reference to that.
> It would be more awkward to pre-allocate for the NFSEXP_ROOTSQUASH
> case as the group_info has to be at least as big as the one in the RPC
> request, and would could need a different one of each concurrent
> request.... not sure if that is worth "fixing".

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
