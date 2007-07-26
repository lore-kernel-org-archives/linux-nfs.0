From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Exportfs not showing exported file systems (was RE:	stdio
	and nfs-utils)
Date: Thu, 26 Jul 2007 16:04:31 -0400
Message-ID: <20070726200431.GE8125@fieldses.org>
References: <20070725223723.GH7943@fieldses.org>
	<20070726000700.GK7943@fieldses.org>
	<18088.3581.647761.879253@notabene.brown>
	<20070726031755.GB19901@fieldses.org>
	<01AE8AF878612047A442668306EAEB05D02161@SACEXMV01.hq.netapp.com>
	<20070726154806.ed0afdfd.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	"Muntz,  Daniel" <Dan.Muntz@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IE9ZZ-00077X-Ng
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 13:04:33 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IE9Zd-0002nE-Aw
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 13:04:37 -0700
In-Reply-To: <20070726154806.ed0afdfd.jlayton@redhat.com>
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

On Thu, Jul 26, 2007 at 03:48:06PM -0400, Jeff Layton wrote:
> I saw a very similar problem with RHEL5 prior to its release. It turned
> out to be a selinux policy issue. I believe the latest selinux-policy
> packages in Fedora and RHEL have fixed it if it's the same problem.

That makes sense.  I don't remember for sure where I saw this, but it
may well have been on my Fedora (rawhide) desktop, and I haven't seen it
recently.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
