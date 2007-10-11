From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,
	PATCH 3/3] knfsd: Modify write_ports to use	svc_find_xprt service
Date: Thu, 11 Oct 2007 10:56:23 -0400
Message-ID: <20071011145623.GA17468@fieldses.org>
References: <20071011022356.3501.63859.stgit@dell3.ogc.int>
	<20071011022901.3501.5244.stgit@dell3.ogc.int>
	<18189.37354.527748.91357@notabene.brown>
	<20071011034608.GC6684@fieldses.org>
	<18189.45080.324267.923517@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, gnb@sgi.com
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfzSb-0003Ta-IQ
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 07:56:25 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfzSf-000574-Gr
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 07:56:30 -0700
In-Reply-To: <18189.45080.324267.923517@notabene.brown>
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

On Thu, Oct 11, 2007 at 03:09:44PM +1000, Neil Brown wrote:
> On Wednesday October 10, bfields@fieldses.org wrote:
> > 
> > If this isn't all ready by Friday (OK, maybe Monday) then I think we're
> > out of time.
> 
> Sorry, when I said "2.6.24-rc1" previously, I was failing to do
> correct addition.  I meant 2.6.25-rc1.
>
> I really don't think it is appropriate to submit these for 2.6.24.
> And I cannot see any real need to do that.

OK.  That takes some pressure off!

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
