From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 0/5] nfsstat: adding -S/--since
Date: Mon, 13 Aug 2007 15:15:16 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708131440190.6965@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKfNn-0001vp-Jg
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 12:15:19 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IKfNq-0000ty-Gq
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 12:15:23 -0700
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

	Hello, Neil,

	As per your and other folks' suggestions, this set of patches adds 
the -S/--since flag, which takes a stats file and then displays the 
difference between them and the current stats.  It accepts the raw stats 
formats of /proc/net/rpc/nfs{,d} as well as "pretty" nfsstat output saved 
to a file (so you can have both client and server stats in the same file).

	This doesn't save the current statistics back to a tempfile like 
one of the ideas mentioned, but one can still use it in conjunction with 
watch(1); e.g.:

$ watch "nfsstat --since /tmp/stats; nfsstat >/tmp/stats" 


- patch 1 just renames some existing variables to clarify their purpose.

- patch 2 adds a few pointers to help with --since and obviates 
copy_stats().

- patch 3 removes some comparisons against global struct statinfos.

- patch 4 adds #defines for the output labels and adds them to struct 
statinfo.

- patch 5 uses the rest and adds -S/--since.

	
	thanks kindly,

	d
	.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
