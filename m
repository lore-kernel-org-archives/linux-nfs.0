From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] Timeouts gone wild on ia64
Date: Fri, 09 May 2003 13:19:45 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EBBE331.5000207@RedHat.com>
References: <482A3FA0050D21419C269D13989C6113127DB4@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19EBWq-0008Oz-00
	for <nfs@lists.sourceforge.net>; Fri, 09 May 2003 10:19:28 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
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

Lever, Charles wrote:

>however, equivalent behavior would be:
>
>  #define RPC_RTO_MIN (HZ/50)
>
>not HZ/30.  why did you choose 30?
>
I realize this but... I figured waiting a
a few extra ticks of time before timing
out was probably a good thing with respect
to soft mounts on slow servers... Especially
since EIO errors can be pretty disruptive... ;-)\

SteveD.



-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
