From: gb <bakerg3@yahoo.com>
Subject: Re: NFS over TCP test results / NetApp / Linux
Date: Wed, 23 Apr 2003 20:24:13 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030424032413.11640.qmail@web41302.mail.yahoo.com>
References: <6440EA1A6AA1D5118C6900902745938E07D5555A@black.eng.netapp.com>
Reply-To: greg@bakers.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web41302.mail.yahoo.com ([66.218.93.51])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 198XLO-0002Q2-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Apr 2003 20:24:18 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D5555A@black.eng.netapp.com>
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


My apologies to the linux-nfs community.

I forwarded an email I sent to my peers at the company
without proper editing for a more global audience.

Please allow me to restate,

"Linux tcp-nfs is not ready for production in __our__
large scale distributed environment with the current
set of NetApp filers...Until this critical problem is
resolved, it is a moot point to argue the advantages
of tcp-nfs vs. udp-nfs regarding network traffic or
CPU usage __in our environment__."

Our environment is a number of NetApp filers running
6.2.2 with hundreds of linux clients recently upgraded
to 2.4.18 (RedHat 7.3 base) using tcp-nfs.

Upgrading to 2.4.21pre7 
+ linux-2.4.21-01-call_reserve1.dif
+ linux-2.4.21-02-call_reserve2.dif
+ linux-2.4.21-03-noac.dif
+ linux-2.4.21-07-rdplus.dif
+ linux-2.4.21-14-xprt_fixes.dif 

Produced the same results using the testbed and
procedures summarized in my first email.

I've taken the kind suggestions by Trond and Charles,
collected the requested data, sent this to the
individuals who offered advice, and looked more
closely at the tcpdump packets that occur during the
failure.

Hopefully I/We will have more to report in the future
related to my original email.

Thanks,

--Greg





__________________________________________________
Do you Yahoo!?
The New Yahoo! Search - Faster. Easier. Bingo
http://search.yahoo.com


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
