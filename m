From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFSD Flow Control Using the TCP Transport
Date: Fri, 21 Mar 2003 15:38:43 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E7B7853.4020605@RedHat.com>
References: <3E78872B.5020702@RedHat.com> <20030320042454.496801DA3E6@brer.local.valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net, taka@valinux.co.jp, yamamoto@valinux.co.jp
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18wTB0-0002l4-00
	for <nfs@lists.sourceforge.net>; Fri, 21 Mar 2003 12:31:42 -0800
To: MINOURA Makoto <minoura@valinux.co.jp>
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



MINOURA Makoto wrote:

>Current implementation closes the socket on EAGAIN/partial
>write, but has some delay.  During this delay on-queue
>messages are unintentionally sent (in case the NFS traffic
>is busy).  We addressed this problem by removing the delay
>(close the socket immediatly) but sending the remaining
>correctly should be better.
>
So If I understand what your saying, EAGAINs or partial writes are 
interpreted
as fatal errors. This confuse me. EAGAINs or partial writes are flow 
control
issues not fatal errors. Just like on the client side, shouldn't the
thread sleep until there is room? Closing down the socket seems a
bit drastic... Or am I missing something?

SteveD.



-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
