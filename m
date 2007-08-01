From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 01 Aug 2007 18:40:13 -0400
Message-ID: <1186008013.6700.244.camel@localhost>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
	<Pine.BSO.4.64.0708011347200.25204@citi.umich.edu>
	<01AE8AF878612047A442668306EAEB05DD298B@SACEXMV01.hq.netapp.com>
	<Pine.BSO.4.64.0708011425580.25204@citi.umich.edu>
	<20070801185052.GG13441@fieldses.org> <46B0E701.6010801@RedHat.com>
	<20070801204824.GI13441@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>,
	Steve Dickson <SteveD@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGMrl-00053b-Nz
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 15:40:29 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+Dzl8XywtDyusbP7H1HjWDD3LHnxq6IQI=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGMrm-00067s-FT
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 15:40:33 -0700
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

On Wed, 2007-08-01 at 16:48 -0400, J. Bruce Fields wrote:

> What would you tell them to do instead?  Parsing the nfsstat output and
> doing the subtraction yourself is a little tedious, so it's not
> suprising if they both try to use -z, if that's all we provide.

The entire point of 'nfsstat' is to act as a parser. Otherwise we'd just
be all be reading the raw output from /proc/net/rpc/*... It makes sense
to add other parsing options to it. I'm a lot more sceptical about
attempts to add non-parsing options.

> Which is why I'd really rather not even emulate zeroing in userspace,
> and instead have two alternatives:
> 
> 	- --sleep: quick and convenient, no concurrency problems.

Has nothing to do with parsing.

> 	- --since: or other operations that do the subtraction for you
> 	  and take explicit paths for saved snapshots.  That allows you
> 	  to do everything you could do with -z and more, and makes any
> 	  problems with concurrency or privileges solvable by choice of
> 	  appropriate paths to store the snapshots in.
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

Parsing already-parsed output is IMO less useful. Just have it be able
to take input from somewhere other than just /proc/net/rpc/*

> > > But I think more snapshot-and-diff operations would be a fine idea.
> > > And probably easy and fun to implement.
> > Why not point that snapshot at /proc/self/mountstats? Those stats
> > will never be zero and the wealth of information in there truly
> > an untaped gold mine....
> 
> Yeah, that'd be great.  We'll still need nfsstat for the server at
> least, I guess?  Does it still provide anything useful on the client
> side, or does mountstats supercede it completely?




-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
