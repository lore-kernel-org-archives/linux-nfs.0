From: Andreas Behnert <abehn@gmx.net>
Subject: Re: Need help
Date: Fri, 09 Aug 2002 16:24:59 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D53D0BB.9040400@gmx.net>
References: <028b01c2400b$3e4b10c0$df0838d2@bhatti>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.gmx.net ([213.165.64.20])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17dAh0-0002Uz-00
	for <nfs@lists.sourceforge.net>; Fri, 09 Aug 2002 07:24:42 -0700
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Muhammad Farooq Bhatti wrote:
> Hi all
>  
> My both client and server are Linux redhat 7.2 box and
> I am getting following error when I mount the file system
>  
> mount: RPC: Program not registered
>  
> what could be the reason please help
>  
> Thanx in advance
>  
> Muhammad Farooq Bhatti


Please verify that your portmapper is running, server and client:
http://nfs.sourceforge.net/nfs-howto/server.html#PORTMAPPER

and this exactly describes your problem:
http://nfs.sourceforge.net/nfs-howto/troubleshooting.html#SYMPTOM3


Regards,

Andreas



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
