From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Maximum number of nfsd daemons?
Date: Sat, 3 Aug 2002 07:18:27 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15690.63267.834217.481574@notabene.cse.unsw.edu.au>
References: <15689.54017.692185.573037@notabene.cse.unsw.edu.au>
	<200208021705.g72H5e204213@roo.greatbasin.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ajoA-0002Q0-00
	for <nfs@lists.sourceforge.net>; Fri, 02 Aug 2002 14:18:02 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <bruce@greatbasin.net>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Sat, 3 Aug 2002 07:17:52 +1000
To: Bruce Robertson <bruce@greatbasin.net>
In-Reply-To: message from Bruce Robertson on Friday August 2
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

On Friday August 2, bruce@greatbasin.net wrote:
> Would you bother with more threads in this situation?  The server's been
> up 133 days; doesn't seem like it's worth messing with it if the last
> thread has only been used for 11 seconds.  I might increase it for the next
> reboot (if ever :-), but I don't really want to bother with restarting nfsd:

1/ It looks OK.  I wouldn't bother increasing the number of threads.
2/ It is actualy 'any of the last 2 (10%)' that have been use for only
   11 seconds.
3/ The second number is a good one to look at, 802 in this case.
   It is the number of times that the last thread has been used.
   Out of 200 million requests, 802 of them did use the last available
   thread at the time.  On those occasions it might have been helpful
   to have another thread or 2, but it might not.  So increasing the
   number of threads wouldn't make a significant difference.
4/ In 2.4 you can increase or decrease the number of threads at any
   time.  You don't need to reboot.  Just run
      rpc.nfsd desired-number-of-threads
   This will change the number of threads to the target.
   e.g.
      rpc.nfsd 0
   will kill all threads.
      rpc.nfsd 128
   will give you the max.

NeilBrown


> 
> rc 253405 247133819 2102736339
> fh 164627 2388074384 0 0 0
> io 1879707623 1245239505
> th 20 802 499059.350 179740.290 95589.220 38896.840 13428.490 4192.740 1125.820 239.110 45.190 11.020
> ra 40 205615873 1051844 560093 330858 220535 154846 109266 81350 66170 63103 0
> net -1944843733 -1944843733 0 0
> rpc -1944843733 0 0 0 0
> proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
> proc3 22 0 42738275 24032239 215924238 1550591333 20714 233998756 172948575 24818081 13323 20691 0 24789604 13179 733268 18264 74781 0 171980 110430 0 59105832
> 
> 
> 
> --
> Bruce Robertson, President/CEO				     +1-775-348-7299
> Great Basin Internet Services, Inc.			fax: +1-775-348-9412
> http://www.greatbasin.net
> 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
