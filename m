From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: slowness due to splitting into pages
	in	nfs3svc_decode_writeargs()
Date: Fri, 31 Aug 2007 15:00:01 -0400
Message-ID: <20070831190001.GD11165@fieldses.org>
References: <200708312003.30446.bernd-schubert@gmx.de>
	<20070831184515.GC11165@fieldses.org>
	<1188586335.26165.104.camel@pc.ilinx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs <nfs@lists.sourceforge.net>
To: "Brian J. Murrell" <brian@interlinx.bc.ca>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IRBip-0005KB-Td
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 12:00:00 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IRBiu-0004Ud-1h
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 12:00:04 -0700
In-Reply-To: <1188586335.26165.104.camel@pc.ilinx>
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

On Fri, Aug 31, 2007 at 02:52:15PM -0400, Brian J. Murrell wrote:
> On Fri, 2007-08-31 at 14:45 -0400, J. Bruce Fields wrote:
> > 
> > Hm.  Any chance this is the same problem?:
> > 
> > 	http://marc.info/?l=linux-nfs&m=112289652218095&w=2
> 
> Did this ever land anywhere?

No--I think there were some discussion of problems in the followup
posts.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
