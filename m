From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: mount: RPC: Timed out
Date: Fri, 15 Aug 2003 07:05:48 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F3CBE8C.5040905@RedHat.com>
References: <000601c36286$b6e4e620$8c35a8c0@peter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ncPG-0003DL-00
	for <nfs@lists.sourceforge.net>; Fri, 15 Aug 2003 04:06:06 -0700
To: Peter Albertsson <Peter.Albertsson@naturesown.se>
In-Reply-To: <000601c36286$b6e4e620$8c35a8c0@peter>
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

Is mountd running on the server?

SteveD.

Peter Albertsson wrote:

>Could someone please help me with the following problem.
>
>This is what happens when I try to mount a nfs share on a client.
>
>
>[root@frankenstein3 etc]# mount -t nfs 192.168.53.200:/var/www /var/www
>mount: RPC: Timed out
>[root@frankenstein3 etc]#
>
>If I mount the share on the same server it works fine.
>
>
>Netstat on client:
>
>[root@frankenstein3 root]# netstat -n
>Active Internet connections (w/o servers)
>Proto Recv-Q Send-Q Local Address           Foreign Address
>State
>tcp        0      0 192.168.53.136:895      192.168.53.200:111
>TIME_WAIT
>
>On server no connections show up at all.
>
>I've seen this problem being discussed on this mailing list and some
>other places, but I haven't found a solution.
>
>The server is running on Red Hat 9.0.
>
>Thanks,
>  // Peter
>
>
>
>
>-------------------------------------------------------
>This SF.Net email sponsored by: Free pre-built ASP.NET sites including
>Data Reports, E-commerce, Portals, and Forums are available now.
>Download today and enter to win an XBOX or Visual Studio .NET.
>http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>  
>



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
