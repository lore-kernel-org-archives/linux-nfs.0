From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] Timeouts gone wild on ia64
Date: Thu, 15 May 2003 11:16:24 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EC3AF48.8020400@RedHat.com>
References: <482A3FA0050D21419C269D13989C6113127DCE@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GKT7-0007ra-00
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 08:16:29 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C6113127DCE@lavender-fe.eng.netapp.com>
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

>you want to keep the retransmit timeout as short as possible,
>just before things start timing out.  this means you get the fastest
>possible recovery when the server drops a request.  
>
That's assuming server drops the request... now if the server is
simply buzy because its severing hundreds of clients and it
takes 6ms to respond, you now have hundreds of clients retransmitting
very 4ms (for basically for no reason) which is just adding to the 
problem...
I'm sure the RTO code would eventually increase the timeout which
would smooth everything out but before that happens you would be
blasting the network with a ton of unnecessary retransmits... True?

>but what i'm hearing is the starting RTO is probably not
>optimal for slow servers.  right now the initial value is:
> 
>  #define RPC_RTO_INIT (HZ/5)
> 
>(200ms) which is perhaps too small.  a better value for
>general use might be HZ/2 (half a second).  then the
>estimator can adjust downward for faster servers while
>behaving practically for slow ones.
>
By increasing the initial timeout, ISTM, that the client
is assuming a slower server verses a fast one... which will
probably work as well... Its just that I thought making
all of the RTO constants value relative to HZ was a good idea...

SteveD.




-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
