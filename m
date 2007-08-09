From: "david m. richter" <richterd@citi.umich.edu>
Subject: Re: [PATCH 0/5] nfsstat: more --diff-stat/--sleep items
Date: Thu, 9 Aug 2007 11:29:54 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708091111450.27071@citi.umich.edu>
References: <Pine.BSO.4.64.0708071928330.26009@citi.umich.edu>
	<18106.27209.93060.7817@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJAAm-0000fg-B7
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 08:43:41 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IJ9xU-0003G2-EF
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 08:29:57 -0700
In-Reply-To: <18106.27209.93060.7817@notabene.brown>
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

On Thu, 9 Aug 2007, Neil Brown wrote:
<snip>
> Thanks.  All applied (after I wraps your comments to 80 columns, and
> removed white space at the end of lines).
> 
> NeilBrown


	thank you -- and sorry about that; i'll be more assiduous in style 
issues in the future.  :-/

	i'd like some input on your idea of adding a timeout to --sleep: i 
took 5 minutes and dropped it in yesterday, but ran into a getopt_long(3) 
issue.  i had wanted to just add the timeout as an optional argument to 
--sleep, as opposed to adding a separate timeout flag (ugh).

	unless i'm doing something wrong (and i'll poke at it now, maybe 
i'm being dumb), it seems that getopt wants to see those optional args in 
the forms:

nfsstat --sleep=5
nfsstat -Z5

.. but doesn't grok the optarg in these, which are more natural to me:

nfsstat --sleep 5
nfsstat -Z 5

	if i'm not doing something wrong, what's the feeling about going 
with -Z5 versus adding -t/--timeout 5?   i don't like an extra flag like 
that, but the main reason i don't like the -Z5/--sleep=5 requirement is 
that getopt seems to silently swallow the time argument if one does -Z 
5/--sleep 5; that is, it just pauses and waits for ^C -- and so it may 
appear to a user like the timeout thing is just broken/unimplemented.
	

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
