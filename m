From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 20/35] svc: Make svc_send transport neutral
Date: Thu, 4 Oct 2007 12:59:08 +1000
Message-ID: <20071004025908.GX21388@sgi.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192814.3250.76840.stgit@dell3.ogc.int>
	<F39B3C28-FF6B-4513-853F-121130E70932@oracle.com>
	<1191343596.1565.30.camel@trinity.ogc.int>
	<AD252E26-A2D6-4B02-AB06-36EE400B2F58@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdGqh-00012t-DH
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 19:54:06 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1IdGqm-0000T8-Ct
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 19:54:08 -0700
In-Reply-To: <AD252E26-A2D6-4B02-AB06-36EE400B2F58@oracle.com>
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

On Tue, Oct 02, 2007 at 12:54:32PM -0400, Chuck Lever wrote:
> 
> On Oct 2, 2007, at 12:46 PM, Tom Tucker wrote:
> 
> >On Tue, 2007-10-02 at 12:15 -0400, Chuck Lever wrote:
> >>On Oct 1, 2007, at 3:28 PM, Tom Tucker wrote:
> >>>
> >
> >[...snip...]
> >
> >>>-	if ((svsk = rqstp->rq_sock) == NULL) {
> >>>-		printk(KERN_WARNING "NULL socket pointer in %s:%d\n",
> >>>+	if ((xprt = rqstp->rq_xprt) == NULL) {
> >>>+		printk(KERN_WARNING "NULL transport pointer in %s:%d\n",
> >>> 				__FILE__, __LINE__);
> >>> 		return -EFAULT;
> >>> 	}
> >>
> >>Do we still want this printk here?  Maybe it can be removed.
> >
> >I don't know why it's here. Maybe replace it with a BUG_ON?
> 
> /me makes an X with his fingers and hisses like a cat....
> 
> BUG_ON is heavyweight and often makes the system unusable after a  
> short while by leaving a lot of bogus state (like held locks).   
> Unless a NULL here is a real sign of a software fault that requires a  
> hard stop, simply returning EFAULT makes sense.

#define EFAULT          14      /* Bad address */

"Bad address" ?  Even EBADF would be a better approximation.
Fmeh, if only we had EINTERNALERROR.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
