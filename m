From: Matthew Boeckman <matthewb@saepio.com>
Subject: linux cache question
Date: Fri, 31 May 2002 14:36:26 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CF7D0BA.5090505@saepio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [208.10.117.3] (helo=velocity.saepio.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17DsET-00028M-00
	for <nfs@lists.sourceforge.net>; Fri, 31 May 2002 12:38:41 -0700
Received: from saepio.com (leto-ii [10.1.1.100])
	by velocity.saepio.com (8.11.2/8.9.3) with ESMTP id g4VJl5g07258
	for <nfs@lists.sourceforge.net>; Fri, 31 May 2002 14:47:05 -0500
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

I'm trying to understand client caching under linux, and tune my mount 
command to increase my performance. A little background: several 2.4.17 
boxes with nfs-utils 0.3.1 (RH7.1) accessing a common mountpoint from a 
Solaris 7 box, NFS3 over UDP. Each client accesses specific directories 
under that mount point, but no overlap, so client a only reads and 
writes to directories that b and c do not. Our application does TONS of 
attribute lookups, often in trees with 80k+ files in them. Default 
attribute caching is a nighmare, as we can wait 10minutes or more for 
the operation to return.

I've tried various options of actimeo, acregmin/max. Currently actimeo 
is set to 3600 (1 hour), I then have a find cronjob that goes back out 
and re-caches the directories so endusers don't have to wait. I notice 
that according to update -d that my "Time for data buffers to age before 
flushing" is 3000. Am I correct in assuming that this means that the 
kernel is flushing the nfs cache before my min timeout value?

If that is the case, what if any are the ramifications of upping that 
value in the kernel? If not, how do I affect the cache sizes for NFS?

The real prompter to this question is that we had been seeing decent 
performance with the above setup, and last night I tried to extend that 
cache to 18000 (5 hours). The unexpected result of this is that my nfs 
call rate went through the ceiling and performance degraded significantly.

Any suggestions?

-- 
Matthew Boeckman			(816) 777-2160
Manager - Systems Integration		Saepio Technologies
== 
						==
...Many say that DOS is the dark side, but actually UNIX is more like 
the dark side: It's less likely to find the one way to destroy your 
incredibly powerful machine, and more likely to make upper management choke.
			-Lore Sjoberg


_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
