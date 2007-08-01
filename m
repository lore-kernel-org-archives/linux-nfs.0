From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 01 Aug 2007 17:50:32 -0400
Message-ID: <46B10028.8080106@RedHat.com>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
	<Pine.BSO.4.64.0708011347200.25204@citi.umich.edu>
	<01AE8AF878612047A442668306EAEB05DD298B@SACEXMV01.hq.netapp.com>
	<Pine.BSO.4.64.0708011425580.25204@citi.umich.edu>
	<20070801185052.GG13441@fieldses.org> <46B0E701.6010801@RedHat.com>
	<20070801204824.GI13441@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGM5S-0008St-9G
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 14:50:34 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IGM5T-0006bN-Vs
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 14:50:38 -0700
In-Reply-To: <20070801204824.GI13441@fieldses.org>
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



J. Bruce Fields wrote:
> 
> Does it look like the nfsstat --sleep/--diff-stats/whatever would have
> done the job in the cases you're thinking of?
It would a bit more awkward... but I'm sure I could make it work...

> 
>>> But I'd still object, for the same reasons; global zeroing of the in-kernel
>>> stats is an operation that:
>>>
>>> 	- isn't friendly to concurrent processes gathering stats:
>>> 	  someone might want to run a cron job that summarizes the day's
>>> 	  nfs stats, but still be able to log in and get a quick
>>> 	  snapshot of current activity.
>> So then don't zero them out... and if some one comes a long and
>> does zero them out, thats a communication problem.. not a
>> technical one... ;-)
> 
> What would you tell them to do instead?  Parsing the nfsstat output and
> doing the subtraction yourself is a little tedious, so it's not
> suprising if they both try to use -z, if that's all we provide.
A *little* tedious??? :-) I don't know how I would tell them
to solve that problem esp with the current tools... I would
probably tell to see if they could get the mountstats numbers
to do what they wanted... and then tell them to send me the patch! 8-)

> 
> Which is why I'd really rather not even emulate zeroing in userspace,
> and instead have two alternatives:
> 
> 	- --sleep: quick and convenient, no concurrency problems.
> 
> 	- --since: or other operations that do the subtraction for you
> 	  and take explicit paths for saved snapshots.  That allows you
> 	  to do everything you could do with -z and more, and makes any
> 	  problems with concurrency or privileges solvable by choice of
> 	  appropriate paths to store the snapshots in.
Understood and I can see how these would be useful in
long term system analyzation but they would be awkward for
short term system debugging... which I think is the real difference
in these approaches...

> 
> Actually the only operation you *really* need is one that parses two
> nfsstat outputs and subtracts:
> 
> 	nfsstat >tmp1
> 	...
> 	nfsstat >tmp2
> 	nfsstat --diff tmp1 tmp2
> 
> and then anything else you can easily script.
Personally I would make the output binary (with a -b flag) since
it seem like it would be easier to do binary compares than
string... But of course that would be giving you more ammo
and I would not want to do that... ;-)


> 
>>> But I think more snapshot-and-diff operations would be a fine idea.
>>> And probably easy and fun to implement.
>> Why not point that snapshot at /proc/self/mountstats? Those stats
>> will never be zero and the wealth of information in there truly
>> an untaped gold mine....
> 
> Yeah, that'd be great.  We'll still need nfsstat for the server at
> least, I guess?  
Good point...

> Does it still provide anything useful on the client
> side, or does mountstats supercede it completely?
I think the both are needed since they provide  different
types of information... The nfsstat stats are basically
"hello world" counters that show there is NFS activity....
The mountstats are much more granular and are per mount
which could be used  to for many different things... like
server responsive for an example...


steved.




-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
