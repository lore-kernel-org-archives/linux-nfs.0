From: Brian Tinsley <btinsley@emageon.com>
Subject: Re: Adapter teaming
Date: Mon, 06 Jan 2003 11:04:31 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E19B71F.6060905@emageon.com>
References: <17110141.1041869610713.JavaMail.www-data@moksha.oddpost.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [63.162.183.250] (helo=emgw2ksrv001.emgdom001.emageon.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Vag4-0002uO-00
	for <nfs@lists.sourceforge.net>; Mon, 06 Jan 2003 09:04:40 -0800
To: Joseph Marshall <joseph@oddpost.com>
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

Yes, we use both the Intel driver (iANS) and the stock bonding driver on 
our NFS servers and have had no problems. More specifics on your 
configuration would help.


Joseph Marshall wrote:

>Has anyone had any success using NFS on a server that is also doing Adapter teaming?  For some reason when if I have adapter teaming set-up and an NFS share mounted my entire server will "lock-up".  If I turn adpater teaming off, the NFS mount works fine.  Any insight would be greatly appreciated.  
>  
> Joe 
>
>
>-------------------------------------------------------
>This sf.net email is sponsored by:ThinkGeek
>Welcome to geek heaven.
>http://thinkgeek.com/sf
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>  
>

-- 

-[========================]-
-[      Brian Tinsley     ]-
-[ Chief Systems Engineer ]-
-[        Emageon         ]-
-[========================]-






-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
