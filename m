From: Rex Dieter <rdieter@math.unl.edu>
Subject: Re: redhat 2.4.18-5 client huge slowdownB
Date: Wed, 10 Jul 2002 14:46:51 -0500 (CDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0207101440370.7151-100000@duran.unl.edu>
References: <E17SMj4-0006L1-00@usw-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mathstat.unl.edu ([129.93.48.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17SNQO-0004Tj-00
	for <nfs@lists.sourceforge.net>; Wed, 10 Jul 2002 12:46:56 -0700
Received: from duran.unl.edu (IDENT:9AtTk6HHKVHJMo54D3uJouioTDKoGA7j@duran.unl.edu [129.93.50.93])
	by mathstat.unl.edu (8.9.3/8.9.3) with ESMTP id OAA15162
	for <nfs@lists.sourceforge.net>; Wed, 10 Jul 2002 14:46:54 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <E17SMj4-0006L1-00@usw-sf-list2.sourceforge.net>
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

Raphael Clifford wrote:
> I was wondering if everyone else is experiencing huge nfs write 
> slowdowns using redhat kernel 2.4.18-5 (as opposed to 2.4.18-4).  I am 

Yes, I've also experienced a huge nfs client slowdown (~50k/sec writes) on 
'sync' nfs mounts with the 2.4.18-5 kernel... See me bugzilla report:
http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=67199
and a similar report as well:
http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=67461

The only way I found to get any sort of respectable performance out of 
2.4.18-5 was to mount 'async'. *ack*

-- 
Rex A. Dieter			rdieter@unl.edu 
Computer System Administrator 	http://www.math.unl.edu/~rdieter/
Mathematics and Statistics  		 
University of Nebraska Lincoln



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Two, two, TWO treats in one.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
