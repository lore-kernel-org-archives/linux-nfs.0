From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 01 Aug 2007 14:02:31 -0400
Message-ID: <1185991351.6700.203.camel@localhost>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
	<46B074A2.4010909@redhat.com>
	<Pine.BSO.4.64.0708011149240.25204@citi.umich.edu>
	<20070801165033.GA13441@fieldses.org>
	<Pine.BSO.4.64.0708011333100.25204@citi.umich.edu>
	<1185990384.6700.188.camel@localhost>
	<Pine.BSO.4.64.0708011347200.25204@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>, Neil Brown <neilb@suse.de>,
	Alex Soule <soule@umich.edu>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Andrew Richardson <chardson@umich.edu>, nfs@lists.sourceforge.net
To: "david m. richter" <richterd@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGIWv-00011s-5X
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 11:02:41 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18muBzX6EG9oRpi9gUJqWevXJjB2OdfUmc=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGIWx-0008EJ-CJ
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 11:02:45 -0700
In-Reply-To: <Pine.BSO.4.64.0708011347200.25204@citi.umich.edu>
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

On Wed, 2007-08-01 at 13:48 -0400, david m. richter wrote:
> On Wed, 1 Aug 2007, Trond Myklebust wrote:
> 
> > On Wed, 2007-08-01 at 13:35 -0400, david m. richter wrote:
> > > > Can I make one more attempt to interest someone in implementing the
> > > > --since=baseline-file approach?  It'd be fun, and would make some more
> > > > flexible use cases very simple.  You could still get a time interval:
> > > > 
> > > > 	nfsstat >tmp
> > > > 	sleep 30
> > > > 	nfsstat --since=tmp
> > > > 
> > > > or you could do other stuff:
> > > > 
> > > > 	nfsstat >tmp
> > > > 	run-my-weird-test-case-here
> > > > 	nfsstat --since=tmp
> > 
> > Exactly. Being able to zero out the stats is way more flexible than the
> > -D stuff...
> 
> 	perhaps i don't follow: how is zeroing the stats address the same 
> use-case as --diff-stat/--sleep?  one can already zero the stats by 
> unmounting, e.g., but that's a pain.  ?  i'm missing something.

You can emulate the --sleep stuff using a simple script:

while true
do
	nfsstat >tmp
	sleep 30
	nfsstat --since=tmp
done

Actually, you can do better if you also introduce an '--input' command
which causes nfsstat to read from a file instead of reading
from /proc/net/rpc/nfs and /proc/net/rpc/nfsd. That could be used to
eliminate a race in the above using something like the following script
to return client diff output.

cat /proc/sys/rpc/nfs >prev
while true
	sleep 30
	cat /proc/sys/rpc/nfs >new
	nfsstat -c --since=prev --input=new
	mv new prev
done

Unfortunately the client and server raw formats differ, so you probably
need to require the user to specify '-c' and '-s' in order to tell
nfsstat what kind of file you are giving it.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
