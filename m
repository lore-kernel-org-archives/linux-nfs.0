From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 1 Aug 2007 16:48:24 -0400
Message-ID: <20070801204824.GI13441@fieldses.org>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
	<Pine.BSO.4.64.0708011347200.25204@citi.umich.edu>
	<01AE8AF878612047A442668306EAEB05DD298B@SACEXMV01.hq.netapp.com>
	<Pine.BSO.4.64.0708011425580.25204@citi.umich.edu>
	<20070801185052.GG13441@fieldses.org> <46B0E701.6010801@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGL7J-0001ra-41
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 13:48:25 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGL7K-0003m2-O5
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 13:48:29 -0700
In-Reply-To: <46B0E701.6010801@RedHat.com>
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

On Wed, Aug 01, 2007 at 04:03:13PM -0400, Steve Dickson wrote:
> Yeah it was me.... and I should have fought harder because since then
> I've had numerous requests and there has been a number of time I could
> have used that functionality in my own debugging...

I do feel bad about that.  So poking David and the others to do this bit
of nfsstat hacking was partly my attempt to make up for it (and to
provide something I'd personally like).

Does it look like the nfsstat --sleep/--diff-stats/whatever would have
done the job in the cases you're thinking of?

> > But I'd still object, for the same reasons; global zeroing of the in-kernel
> > stats is an operation that:
> > 
> > 	- isn't friendly to concurrent processes gathering stats:
> > 	  someone might want to run a cron job that summarizes the day's
> > 	  nfs stats, but still be able to log in and get a quick
> > 	  snapshot of current activity.
> So then don't zero them out... and if some one comes a long and
> does zero them out, thats a communication problem.. not a
> technical one... ;-)

What would you tell them to do instead?  Parsing the nfsstat output and
doing the subtraction yourself is a little tedious, so it's not
suprising if they both try to use -z, if that's all we provide.

Which is why I'd really rather not even emulate zeroing in userspace,
and instead have two alternatives:

	- --sleep: quick and convenient, no concurrency problems.

	- --since: or other operations that do the subtraction for you
	  and take explicit paths for saved snapshots.  That allows you
	  to do everything you could do with -z and more, and makes any
	  problems with concurrency or privileges solvable by choice of
	  appropriate paths to store the snapshots in.

Actually the only operation you *really* need is one that parses two
nfsstat outputs and subtracts:

	nfsstat >tmp1
	...
	nfsstat >tmp2
	nfsstat --diff tmp1 tmp2

and then anything else you can easily script.

> > But I think more snapshot-and-diff operations would be a fine idea.
> > And probably easy and fun to implement.
> Why not point that snapshot at /proc/self/mountstats? Those stats
> will never be zero and the wealth of information in there truly
> an untaped gold mine....

Yeah, that'd be great.  We'll still need nfsstat for the server at
least, I guess?  Does it still provide anything useful on the client
side, or does mountstats supercede it completely?

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
