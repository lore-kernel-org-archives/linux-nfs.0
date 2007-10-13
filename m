From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,
	PATCH 0/3] svc: gnb review cleanup for transport switch
Date: Fri, 12 Oct 2007 23:48:42 -0400
Message-ID: <20071013034842.GA13453@fieldses.org>
References: <20071011022356.3501.63859.stgit@dell3.ogc.int>
	<20071011203029.GE22823@fieldses.org>
	<1192225226.30080.34.camel@trinity.ogc.int>
	<20071012220300.GH1025@fieldses.org>
	<20071012223000.GI1025@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net, gnb@sgi.com
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IgXzm-0006oK-Cw
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 20:48:58 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IgXzo-000558-L4
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 20:49:02 -0700
In-Reply-To: <20071012223000.GI1025@fieldses.org>
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

On Fri, Oct 12, 2007 at 06:30:00PM -0400, bfields wrote:
> On Fri, Oct 12, 2007 at 06:03:00PM -0400, bfields wrote:
> > Sorry, yes, it's currently in "master" in my git tree:
> > 
> > 	git://linux-nfs.org/~bfields/linux.git master
> > 
> > I believe it's got everything you've sent me so far except the three
> > patches from today.  I haven't looked at it again since yesterday.
> 
> Bah, don't spend any time on this.  I took another look, and it seems
> the problem is in the exported filesystem itself, not in the server.

Yeah, there were some filesystem errors in the logs, and after
reformatting that partition I can't reproduce the problem.  I think that
one machine may just have an unreliable drive.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
