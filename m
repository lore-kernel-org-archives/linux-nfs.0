From: Andrew Ryan <andrewr@nam-shub.com>
Subject: Re: NFS over TCP test results from bakerg3@yahoo
Date: Wed, 23 Apr 2003 18:38:38 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.40.0304231835270.28802-100000@bolt.sonic.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from b.smtp-out.sonic.net ([208.201.224.39])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 198Vh8-0001W3-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Apr 2003 18:38:38 -0700
Received: from newbolt (bolt.sonic.net [208.201.242.18])
	by sub.sonic.net (8.11.6p2/8.8.5) with ESMTP id h3O1ccW23354
	for <nfs@lists.sourceforge.net>; Wed, 23 Apr 2003 18:38:38 -0700
To: nfs@lists.sourceforge.net
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I agree with Charles and Trond's earlier comments, and would like to add
that if you share your exact test cases and more details about your setup,
there are at least a few of us who also use TCP mounts with linux clients
and netapp filers who would be interested in replicating and testing, and
ferreting out any bugs which may exist.

To call TCP nfs client mounts "not production worthy" at this stage is
irresponsible and not really true. We use them in production against
Netapp filers and have had great success since 2.4.20+NFSALL. Obviously
your mileage is varying but I just wanted to weigh in with our experience.

If there are bugs, and that's a distinct possibility, we want to help find
and fix them. Essentially flaming the people that are going to do the
analysis and write the patches isn't the best way to get this done.


cheers,
andrew



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
