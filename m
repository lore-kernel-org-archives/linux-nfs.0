From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: Re: rpc.mountd: getfh failed: Operation not permitted
Date: Tue, 19 Aug 2003 16:50:48 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F423948.9090204@inf.ethz.ch>
References: <3F3119E5.2040207@inf.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from medoc.inf.ethz.ch ([129.132.178.200])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19p7p7-0007Yc-00
	for <nfs@lists.sourceforge.net>; Tue, 19 Aug 2003 07:51:01 -0700
Received: from localhost (localhost [127.0.0.1])
	by medoc.inf.ethz.ch (Postfix) with ESMTP id E6D0A59E7F
	for <nfs@lists.sourceforge.net>; Tue, 19 Aug 2003 16:50:48 +0200 (MEST)
Received: from medoc.inf.ethz.ch ([127.0.0.1])
 by localhost (medoc [127.0.0.1]) (amavisd-new, port 10024) with LMTP
 id 11625-01-8 for <nfs@lists.sourceforge.net>;
 Tue, 19 Aug 2003 16:50:48 +0200 (MEST)
Received: from inf.ethz.ch (ikarus.inf.ethz.ch [129.132.10.58])
	by medoc.inf.ethz.ch (Postfix) with ESMTP id 6BDA759E68
	for <nfs@lists.sourceforge.net>; Tue, 19 Aug 2003 16:50:48 +0200 (MEST)
In-Reply-To: <3F3119E5.2040207@inf.ethz.ch>
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

Marc Schmitt wrote:

> - upgrade to kernel >= 2.4.20 (which is something I have to do tonight 
> anyway, the server currently suffers from the quota bug in 2.4.18-27 
> that was solved in 2.4.20-18, too: "kernel: VFS: find_free_dqentry(): 
> Data block full but it shouldn't. kernel: VFS: Error -5 occured while 
> creating quota.") 

:(
The upgrade to kernel 2.4.20-19 did not help, today again, I had to 
restart the NFS service due to the "getfh failed: Operation not 
permitted." error.
I've compared the logs (Aug 4th and today). What is interesting is that 
the VFS quota error appeared again today, too. The quota bug occured 
first at 6am and continued happening about once an hour till  11:45am. 
45' later, the first getfh error appears in the logs. Short after that, 
I've restarted the NFS service.

I'd love to help debugging this problem. I'd appreciate some pointers 
where to start, though. How can I provide debugging infos while still 
keeping the machine in production?

What I may try is running vanilla kernel 2.4.22 (once it's out), too, I 
saw that there are improvements for machines with heavy I/O load.

TIA

Regards,

    Marc



-------------------------------------------------------
This SF.net email is sponsored by Dice.com.
Did you know that Dice has over 25,000 tech jobs available today? From
careers in IT to Engineering to Tech Sales, Dice has tech jobs from the
best hiring companies. http://www.dice.com/index.epl?rel_code=104
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
