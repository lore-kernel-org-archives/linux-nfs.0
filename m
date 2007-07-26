From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Exportfs not showing exported file systems (was RE:	stdio
	and nfs-utils)
Date: Thu, 26 Jul 2007 17:16:40 -0400
Message-ID: <20070726211640.GK8125@fieldses.org>
References: <20070725223723.GH7943@fieldses.org>
	<20070726000700.GK7943@fieldses.org>
	<18088.3581.647761.879253@notabene.brown>
	<20070726031755.GB19901@fieldses.org>
	<01AE8AF878612047A442668306EAEB05D02161@SACEXMV01.hq.netapp.com>
	<20070726154806.ed0afdfd.jlayton@redhat.com>
	<01AE8AF878612047A442668306EAEB05D0219C@SACEXMV01.hq.netapp.com>
	<20070726171209.6fbccdd3.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	"Muntz,  Daniel" <Dan.Muntz@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEAhO-0006lM-3p
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 14:16:42 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IEAhQ-0008Mu-NX
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 14:16:46 -0700
In-Reply-To: <20070726171209.6fbccdd3.jlayton@redhat.com>
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

On Thu, Jul 26, 2007 at 05:12:09PM -0400, Jeff Layton wrote:
> ...if you find that selinux is at fault then you may want to reopen it.
> It might also be worthwhile to do the same with Bruce's original
> problem and see if it behaves any differently.

The system where I was seeing the problem was a debian system without
selinux.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
