From: Ian Holsman <lists@holsman.net>
Subject: a nfs configuration scalability question
Date: Mon, 16 Sep 2002 12:11:59 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D862CFF.6080908@holsman.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-206-16-4-197.cnet.com ([206.16.4.197] helo=localhost.localdomain)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17r1IB-0000vD-00
	for <nfs@lists.sourceforge.net>; Mon, 16 Sep 2002 12:12:20 -0700
Received: from holsman.net (localhost [127.0.0.1])
	by localhost.localdomain (Postfix) with ESMTP id 57BFB1004F9
	for <nfs@lists.sourceforge.net>; Mon, 16 Sep 2002 12:11:59 -0700 (PDT)
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

OK..
first of all my apolagies if this is a *developer* only list.

I'm running apache2 on  rh-kernel on a quad processor machine.
the docroot (where it grabs the HTML files) is being served off a 
netapp750 filer.

what I'm finding is that under *any* load the runqueue goes up to ~700
and the cpu shows 100% idle. vmstat shows that all the procs are in 
'blocked' state.

now.. I've tweaked the nfs mount a tiny bit to make it read only, and 
have a rsize of 8k, but it didn't seem to make any difference.

$ mount
cn-sfo1-pma-filer1:/docroot on /var/httpd/online/docroot type nfs 
(ro,rsize=8192,nolock,addr=10.10.112.27,addr=10.10.112.27)


the actual benchmark involves a HTTP client requesting a random URL 
which reads in 10 files (9 of which are the same for each request)

on Solaris (where it is currenlty running) I can get ~1000 nfs 
ops/second (mainly lookups)

so my questions:

* what tools are there for me to monitor WTF is going on  (ie.. cache 
hit rates inode hit rates)
* can I tweak the cache/inode size
* are there tweaks/kernel patches which will help client performance for 
my type of workload
* am I being a complete dunderhead and missing something completely 
obivous (if so where should I RTFM ?)

Thanks
this nfs problem is a major roadblock for me, and would appreciate ANY 
pointers

Ian Holsman




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
