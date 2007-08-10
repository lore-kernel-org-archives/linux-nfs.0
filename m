From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/5] nfsstat: more --diff-stat/--sleep items
Date: Fri, 10 Aug 2007 15:13:39 +1000
Message-ID: <18107.62467.713097.170392@notabene.brown>
References: <Pine.BSO.4.64.0708071928330.26009@citi.umich.edu>
	<18106.27209.93060.7817@notabene.brown>
	<Pine.BSO.4.64.0708091111450.27071@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "david m. richter" <richterd@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJMor-0003Ml-IH
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 22:13:53 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IJMov-00038Z-6T
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 22:13:57 -0700
In-Reply-To: message from david m. richter on Thursday August 9
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

On Thursday August 9, richterd@citi.umich.edu wrote:
> 
> 	i'd like some input on your idea of adding a timeout to --sleep: i 
> took 5 minutes and dropped it in yesterday, but ran into a getopt_long(3) 
> issue.  i had wanted to just add the timeout as an optional argument to 
> --sleep, as opposed to adding a separate timeout flag (ugh).
> 
> 	unless i'm doing something wrong (and i'll poke at it now, maybe 
> i'm being dumb), it seems that getopt wants to see those optional args in 
> the forms:
> 
> nfsstat --sleep=5
> nfsstat -Z5
> 
> .. but doesn't grok the optarg in these, which are more natural to me:
> 
> nfsstat --sleep 5
> nfsstat -Z 5
> 
> 	if i'm not doing something wrong, what's the feeling about going 
> with -Z5 versus adding -t/--timeout 5?   i don't like an extra flag like 
> that, but the main reason i don't like the -Z5/--sleep=5 requirement is 
> that getopt seems to silently swallow the time argument if one does -Z 
> 5/--sleep 5; that is, it just pauses and waits for ^C -- and so it may 
> appear to a user like the timeout thing is just broken/unimplemented.

You are not doing anything wrong.  If the arg to --sleep is
optional, then the 5 in
     --sleep 5
must be interpreted as a separate option.  You need something
unambiguous like an '=' to say that there really is an arg.

I'm quite comfortable with --sleep=5 for myself.

However having followed the discussion, I really like the idea of
storing info in a file.
Something like:

   nfsstat  --since=/some/file

where the semantics are:
  - load the stats from the kernel (as 'new').
  - if /some/file exists and contains stats, load them (as 'old') and
     print the difference between 'old' and 'new'.
  - write 'new' to /some/file

Then you could
  watch -n10  nfsstat --since=/tmp/mystats

to see stats collected over 10second intervals.
(maybe you could have --no-update to inhibit the write...)

I think that would be more useful to scripts even than --sleep=N

Thanks,
NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
