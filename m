From: Olof Johansson <olof@austin.ibm.com>
Subject: Re: [PATCH] SVC sockets don't disable Nagle
Date: Wed, 30 Apr 2003 09:58:58 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EAFE4B2.1080707@austin.ibm.com>
References: <Pine.LNX.4.44.0304301356400.15733-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: trond.myklebust@fys.uio.no, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e32.co.us.ibm.com ([32.97.110.130])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19At3M-0001a8-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Apr 2003 07:59:24 -0700
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0304301356400.15733-100000@kenzo.iwr.uni-heidelberg.de>
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

Bogdan Costescu wrote:
> On Tue, 29 Apr 2003, Olof Johansson wrote:
> 
> 
>>There is a chance that small requests and replies (~100 bytes) will not
>>be aggregated into the same segments but instead sent out separately.
> 
> Although I haven't looked at the code recently, I think that what you said 
> is true when this is the only request from the client. But what happens 
> when there are several requests or when GETATTR calls happen at the same 
> time with some data transfer (which is normally the case for a multiuser 
> NFS client) ?

This is exactly what I meant. There is a chance that the GETATTR (or 
other small request and/or reply) will be sent out in an individual 
segment instead of being aggregated. This will give some additional 
network overhead, but give latency improvement. Actually, for a busy NFS 
connection the small requests/replies will still be aggregated without 
Nagle. At least that's what I've been seeing here.

>>In essence, this will result in some additional network overhead due to
>>headers, but the response times will be perceived as faster even for
>>slower networks.
> 
> True, until the network becomes too slow, then you see "server not 
> responding" messages...

I can't see how disabling Nagle would lead to RPC timeouts:

Lower network overhead during congestion is taken care of automatically: 
As the network throughput decreases, TCP segments will be sent out at a 
lower pace and/or smaller size (due to window sizes going down). There 
will be more time to wait for more data to fill the segment with, even 
without having Nagle enabled.

>>I think it would just clutter the documentation and list of options,
> 
> 
> Yes, but Samba has this option and many others and still lots of people 
> are using it :-)

I didn't say that Samba is better than NFS :-)

Seriously: Samba has a configuration file, while NFS needs to stuff all 
the options into a line or two of export and/or mount options. Option 
bloat is not as big a problem when you have a large configuration file.

>>since I don't forsee any practical scenarios in which anyone would have
>>a positive performance impact from having Nagle enabled.
> 
> Well, my previous message included this question: "What is the impact of 
> this change for a slower/congested network ?" So I'll rephrase it: do you 
> have some data to show that disabling Nagle does not have a negative 
> impact ?

No, this would be to prove a negative which is always hard. But the same 
reasoning as above regarding congested networks apply. Actually, it 
applies to any scenario where the machine can process requests faster 
than the network can send the replies.

>>On a side note: As far as I know, most (all?) other NFS implementations 
>>out there already disable Nagle.
> 
> I didn't say that the other NFS implementations are better than the Linux 
> implementation :-)

I'm of the humble opinion that there is still a bit of room for 
improvement in the Linux implementation, but it's continuosly getting 
better. :-)


-Olof


-- 
Olof Johansson                                        Office: 4E002/905
pSeries Linux Development                             IBM Systems Group
Email: olof@austin.ibm.com                          Phone: 512-838-9858
All opinions are my own and not those of IBM



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
