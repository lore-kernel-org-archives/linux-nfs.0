From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Exportfs not showing exported file systems (was RE: stdio
	and nfs-utils)
Date: Thu, 26 Jul 2007 15:36:38 -0400
Message-ID: <20070726193638.GC8125@fieldses.org>
References: <20070726031755.GB19901@fieldses.org>
	<01AE8AF878612047A442668306EAEB05D02161@SACEXMV01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IE98Z-0003cX-8G
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 12:36:39 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IE98c-0003a5-0u
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 12:36:43 -0700
In-Reply-To: <01AE8AF878612047A442668306EAEB05D02161@SACEXMV01.hq.netapp.com>
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

On Thu, Jul 26, 2007 at 11:43:10AM -0700, Muntz, Daniel wrote:
> Could all this be related to a problem that we've been seeing while
> working on v4/4.1 at netapp, where exportfs doesn't show any output even
> when there are exported file systems?  Ricardo recently observed that if
> you redirect the output of 'exportfs' then you actually do get the
> correct output (e.g., exportfs > afile, or exportfs | more).

I wouldn't expect that to be related to the problem with i/o to these
proc files.

But, yes, I've seen the same problem with exportfs output.  (Shame on me
for not reporting it at at the time.... And thanks for looking into it!)
But I don't know what the problem is.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
