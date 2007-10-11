From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,
	PATCH 0/3] svc: gnb review cleanup for transport switch
Date: Thu, 11 Oct 2007 13:09:59 -0400
Message-ID: <20071011170959.GB22823@fieldses.org>
References: <20071011022356.3501.63859.stgit@dell3.ogc.int>
	<20071011052510.GD31422@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ig1Xu-0003tw-AH
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 10:10:02 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ig1Xu-0005vs-FG
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 10:10:07 -0700
In-Reply-To: <20071011052510.GD31422@sgi.com>
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

On Thu, Oct 11, 2007 at 03:25:10PM +1000, Greg Banks wrote:
> Compendium reply.
> 
> On Wed, Oct 10, 2007 at 09:23:56PM -0500, Tom Tucker wrote:
> > Subject: [RFC,PATCH 3/3] knfsd: Modify write_ports to use
> > svc_find_xprt service
> 
> ok by me, but Neil makes a good point about designing this interface
> carefully.

The important point being that the kernel is required to stay backwards
compatible with older user utilities--we can't tell people "oh, if
you're upgrading from 2.6.25 to 2.6.26 and you want nfs/rdma to keep
working then you'll also have to upgrade to nfs-utils-1.3.0."

(With maybe some leeway if rdma is still in such an experimental state
that there aren't yet any real users....)

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
