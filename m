From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 01 Aug 2007 16:03:13 -0400
Message-ID: <46B0E701.6010801@RedHat.com>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>	<Pine.BSO.4.64.0708011347200.25204@citi.umich.edu>	<01AE8AF878612047A442668306EAEB05DD298B@SACEXMV01.hq.netapp.com>	<Pine.BSO.4.64.0708011425580.25204@citi.umich.edu>
	<20070801185052.GG13441@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: "J. Bruce Fields" <bfields@fieldses.org>,
	"'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGKPf-00059D-Gk
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 13:03:19 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IGKPh-0005Xd-3r
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 13:03:23 -0700
In-Reply-To: <20070801185052.GG13441@fieldses.org>
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
> On Wed, Aug 01, 2007 at 02:37:09PM -0400, david m. richter wrote:
>> 	i think that zeroing all the counters is too much of a "big 
>> hammer" approach to what was intended to be a quick and simple use-case.  
>> if there's a kernel interface for zeroing stuff, then maybe that could be 
>> added, too; someone should have-at.
>>
>> 	thoughts, neil?
> 
> I think it was Steve that tried that a couple years ago.  I objected,
> and feel like a bit of a jerk for it, because the fact is he did a fine
> job of it as far as I could tell.
Yeah it was me.... and I should have fought harder because since then
I've had numerous requests and there has been a number of time I could
have used that functionality in my own debugging... Heck I think the
patch is still in the rhel3 nfs-utils...

> 
> But I'd still object, for the same reasons; global zeroing of the in-kernel
> stats is an operation that:
> 
> 	- isn't friendly to concurrent processes gathering stats:
> 	  someone might want to run a cron job that summarizes the day's
> 	  nfs stats, but still be able to log in and get a quick
> 	  snapshot of current activity.
So then don't zero them out... and if some one comes a long and
does zero them out, thats a communication problem.. not a
technical one... ;-)


> 	- requires special privileges: you may be comfortable allowing
> 	  anyone to read the stats, but you probably won't allow anyone
> 	  to zero them.
This is a nit, imho... you could use groups to allow access to clearing
the stats...

> 	- requires a new kernel interface, when you could just do
> 	  everything in userspace and get something that works for free
> 	  on older kernels too....
While its true there there was kernel changes needed... but those
changes very small and self-contained and they made the entire
process much much simpler....

> 
> But I think more snapshot-and-diff operations would be a fine idea.
> And probably easy and fun to implement.
Why not point that snapshot at /proc/self/mountstats? Those stats
will never be zero and the wealth of information in there truly
an untaped gold mine....

steved.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
