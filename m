Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx4.framestore.com ([193.203.83.5]:43732 "EHLO
	mx4.framestore.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162AbaETNPA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 May 2014 09:15:00 -0400
Subject: NFS (or RPC) batching of calls over TCP results in 'unmatched'
 replies?
From: Jim Vanns <james.vanns@framestore.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 20 May 2014 13:29:26 +0100
Message-ID: <1400588966.13140.22.camel@sys304.ldn.framestore.com>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello list.

I wonder if anyone here could confirm my suspicions (and lack of
understanding) re. batched RPC calls? Especially in the context of NFS
reads.

--[ Background;
Initially I was to believe that for every dispatched RPC call (say an
NFS read) a reply message from the server was expected - so that the
client can use the XID to match it to the call.

However, when capturing traffic using libpcap (tcpdump, wireshark, gulp
and in-house software all exhibit this behaviour) during peak workloads
(100MB/s read - 1600 64k NFS read calls per second) , later analysis
shows that the number of identified RPC replies is significantly less
than the number of calls. This is despite libpcap reporting no packet
loss
at either the NIC or kernel level. For example, using the tshark display
filter rpc.msgtyp==0 and rpc.msgtyp==1 respectively;

Calls: 250364
Replies: 83419

Calls: 165770
Replies: 48488

Calls: 171208
Replies: 14861

This is against 3 different NFS servers (the last being Linux knfsd). 

This was, to me, unexpected and so I read more and came across the
rather tiny amount of information on RPC batching in the RFCs (section
7.4.1 - a small paragraph). The IBM and Oracle websites also have some
info but not much. I have found nothing that enables
me to identify batched requests (or rather the replies for a batch) in
the protocol itself. Wireshark seems unable to do this also.

I realise this is a bit off-topic but I was hoping someone might be able
to point me in the right direction? Am I barking up the wrong tree? Is
this behaviour expected - am I unable to match calls to replies when
batching is used? The IBM website suggests;

'Batching assumes the following:

Each remote procedure call in the pipeline requires no response from the
server, and the server does not send a response message.'

This sounds a bit awkward! It then goes on to suggest that;

'The remote procedure call's time out must be 0'

For batched calls. But there is no call timeout in the RPC protocol
right? Again, this must be up to the client implementation I suspect?

Any help appreciated.

Regards,

Jim

PS. I may well join the Linux RPC mailing list and direct this question
at them instead.

-- 
Senior Software Engineer
Systems Development
Framestore


