From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 1 Aug 2007 14:50:52 -0400
Message-ID: <20070801185052.GG13441@fieldses.org>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
	<Pine.BSO.4.64.0708011347200.25204@citi.umich.edu>
	<01AE8AF878612047A442668306EAEB05DD298B@SACEXMV01.hq.netapp.com>
	<Pine.BSO.4.64.0708011425580.25204@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>, Neil Brown <neilb@suse.de>,
	"Muntz,  Daniel" <Dan.Muntz@netapp.com>,
	Alex Soule <soule@umich.edu>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Andrew Richardson <chardson@umich.edu>, nfs@lists.sourceforge.net
To: "david m. richter" <richterd@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGJIB-0005m7-Rz
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 11:51:32 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGJHk-0002zI-RO
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 11:51:05 -0700
In-Reply-To: <Pine.BSO.4.64.0708011425580.25204@citi.umich.edu>
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

On Wed, Aug 01, 2007 at 02:37:09PM -0400, david m. richter wrote:
> 	i think that zeroing all the counters is too much of a "big 
> hammer" approach to what was intended to be a quick and simple use-case.  
> if there's a kernel interface for zeroing stuff, then maybe that could be 
> added, too; someone should have-at.
> 
> 	thoughts, neil?

I think it was Steve that tried that a couple years ago.  I objected,
and feel like a bit of a jerk for it, because the fact is he did a fine
job of it as far as I could tell.

But I'd still object, for the same reasons; global zeroing of the in-kernel
stats is an operation that:

	- isn't friendly to concurrent processes gathering stats:
	  someone might want to run a cron job that summarizes the day's
	  nfs stats, but still be able to log in and get a quick
	  snapshot of current activity.
	- requires special privileges: you may be comfortable allowing
	  anyone to read the stats, but you probably won't allow anyone
	  to zero them.
	- requires a new kernel interface, when you could just do
	  everything in userspace and get something that works for free
	  on older kernels too....

But I think more snapshot-and-diff operations would be a fine idea.
And probably easy and fun to implement.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
