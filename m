From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: redhat 2.4.18-5 client huge slowdown
Date: 12 Jul 2002 14:07:13 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shslm8hw3ny.fsf@charged.uio.no>
References: <E17SjDh-00067R-00@usw-sf-list2.sourceforge.net>
	<200207111429.34983.rdieter@math.unl.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17SzCp-000797-00
	for <nfs@lists.sourceforge.net>; Fri, 12 Jul 2002 05:07:28 -0700
To: Rex Dieter <rdieter@math.unl.edu>
In-Reply-To: <200207111429.34983.rdieter@math.unl.edu>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

>>>>> " " == Rex Dieter <rdieter@math.unl.edu> writes:

     > Here's some interesting data (on switched fast ethernet) to
     > chew on (using Redhat's 2.4.18-5 kernel on both server and
     > client): Server(1) Client(2) Speed async async ~8.5MB/sec async
     > sync ~6.5MB/sec sync async ~350K/sec sync sync ~50k/sec
 
If you switch off write caching using the '-o sync' mount option then
of course you will see a dramatic slowdown. Where's the beef?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Gadgets, caffeine, t-shirts, fun stuff.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
