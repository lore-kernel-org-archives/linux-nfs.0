From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFSD Flow Control Using the TCP Transport
Date: Mon, 24 Mar 2003 10:07:09 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E7F1F1D.8090206@RedHat.com>
References: <3E78872B.5020702@RedHat.com> <20030320042454.496801DA3E6@brer.local.valinux.co.jp> <3E7B7853.4020605@RedHat.com> <20030324025133.924651DA3E6@brer.local.valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net, taka@valinux.co.jp, yamamoto@valinux.co.jp
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18xTQA-0005VQ-00
	for <nfs@lists.sourceforge.net>; Mon, 24 Mar 2003 06:59:30 -0800
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

Yes I understand its a RPC issue not an NFS issue.
I guess I should have made it clear that I think
that the _RPC_ layer should be able to handle
EAGAINs (using the TCP transport).

The patch you provided does indeed stop the RPC
layer from returning EAGAINs but also stops the flow
of traffic because the sockets with are no longer
being enqueued which in turn means there are no
threads sleeping/waiting (in tcp_sendmsg) when
the svc_write_space routine is called. So once
this flow condition hits, the replys stop which
means the incoming requests also stop and all
the nfsds end up sitting in svc_recv() waiting
for something to do....

0bviously, there is another issue in player here
(which I'm currently debugging), since I do think your
patch make sense....

SteveD.

MINOURA Makoto wrote:

>|> In <3E7B7853.4020605@RedHat.com>
>|>  Steve Dickson <SteveD@redhat.com> wrote:
>
>  
>
>>So If I understand what your saying, EAGAINs or partial writes are 
>>interpreted
>>as fatal errors. This confuse me. EAGAINs or partial writes are flow 
>>control
>>issues not fatal errors. Just like on the client side, shouldn't the
>>thread sleep until there is room? Closing down the socket seems a
>>bit drastic... Or am I missing something?
>>    
>>
>
>In general you are right, but as of Linux kNFSd something
>like a flow control is done in the RPC layer.
>
>In kNFSd multiple nfsd threads share a single socket and to
>avoid data mixture a sendto call must be atomic.  In order
>to guarantee this the threads sleep in the RPC layer until
>there is enough TCP write space.  By doing so EAGAIN can be
>interpreted as something wrong is going on.
>
>But since the free space calculation was wrong this
>assumption was broken.  The patch attached in my previous
>mail corrects this.
>
>  
>




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
