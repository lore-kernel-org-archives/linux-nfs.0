From: Steve Dickson <SteveD@redhat.com>
Subject: Re: profiling the nfs client
Date: Wed, 05 Mar 2003 07:08:16 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E65E8B0.4040904@RedHat.com>
References: <20030304192758.47715.qmail@web11407.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18qXds-0005ZO-00
	for <nfs@lists.sourceforge.net>; Wed, 05 Mar 2003 04:05:00 -0800
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.9.3) with ESMTP id h25C4qo08748
	for <nfs@lists.sourceforge.net>; Wed, 5 Mar 2003 07:04:52 -0500
To: nfs <nfs@lists.sourceforge.net>
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

Try http://oprofile.sourceforge.net/

Abhishek Rai wrote:

>hi,
>i need a profiling tool for profiling the nfs client
>preferrably for 2.4.18
>i tried kernprof but it doesn't serve the purpose as
>kernprof seems to be giving the execution profile of
>the core kernel image and not any modules (as is the
>nfs client on my machine)
>
>can anybody suggest one/give pointers etc
>
>Thanks a lot
>Abhishek
>
>=====
>"They thought to use and shame me but I win out by nature, because a true
>freak cannot be made.  A true freak must be born." - K. Dunn
>============================================================
>Abhishek Rai
>Final year,B.Tech, Computer Science and Engineering
>IIT KGP,India
>abbashake007@yahoo.com 
>============================================================ 
>
>
>__________________________________________________
>Do you Yahoo!?
>Yahoo! Tax Center - forms, calculators, tips, more
>http://taxes.yahoo.com/
>
>
>-------------------------------------------------------
>This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
>for complex code. Debugging C/C++ programs can leave you feeling lost and 
>disoriented. TotalView can help you find your way. Available on major UNIX 
>and Linux platforms. Try it free. www.etnus.com
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>  
>




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
