From: psz@maths.usyd.edu.au (Paul Szabo)
Subject: Re: DoS lockd
Date: Fri, 20 Sep 2002 06:53:31 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200209192053.g8JKrVn124134@milan.maths.usyd.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from talus.maths.usyd.edu.au ([129.78.68.1])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17s8Iv-00010u-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Sep 2002 13:53:41 -0700
To: neilb@cse.unsw.edu.au
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

Neil,

>>>> A Tru64 client may accidentally crash the lockd process on a Debian server.
>>>> I wonder if this "works" on other Linux versions, and if this attack may be
>>>> exploited to more than a DoS.
>>> Looks like Trond submitted a fix for this on 10th July this year.
>> Thanks for your reply. However, could you please point me to this patch as
>> I cannot find it?
> 
> http://linux.bkbits.net:8080/linux-2.4/cset@1.555.4.8

Thank you very much for that pointer. Just to confirm: I now tried the
patch and it works as claimed, no more lockd crash.

Cheers,

Paul Szabo - psz@maths.usyd.edu.au  http://www.maths.usyd.edu.au:8000/u/psz/
School of Mathematics and Statistics  University of Sydney   2006  Australia


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
