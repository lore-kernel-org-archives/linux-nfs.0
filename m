From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/5] nfsstat: more --diff-stat/--sleep items
Date: Thu, 9 Aug 2007 11:13:45 +1000
Message-ID: <18106.27209.93060.7817@notabene.brown>
References: <Pine.BSO.4.64.0708071928330.26009@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "david m. richter" <richterd@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIwbD-0006XR-Fp
	for nfs@lists.sourceforge.net; Wed, 08 Aug 2007 18:14:03 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IIwbG-0005VS-4w
	for nfs@lists.sourceforge.net; Wed, 08 Aug 2007 18:14:07 -0700
In-Reply-To: message from david m. richter on Tuesday August 7
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

On Tuesday August 7, richterd@citi.umich.edu wrote:
> 	Hello, Neil, 
> 
> 	This set of patches fills in some holes from the initial 
> --diff-stat work.  The first patch maybe should be separate, but the third 
> patch makes use of it (but could easily be reworked).
> 
> 
> - patch 1 adds three counters to the client v4 ops display -- GETACL, 
> SETACL, and FS_LOCATIONS, which are available in /proc/net/rpc/nfs but 
> haven't been used.
> 
> - patch 2 adds, at your suggestion, a comment clarifying what has_stats() 
> is actually doing.
> 
> - patch 3 fixes a bug in diff_stats() that causes false-positives in 
> has_stats().
> 
> - patch 4, as Bruce Fields suggested, renames -D/--diff-stat to 
> the (hopefully) more intuitive -Z/--sleep.
> 
> - patch 5 adds -Z/--sleep to the nfsstat manpage.
> 

Thanks.  All applied (after I wraps your comments to 80 columns, and
removed white space at the end of lines).

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
