From: Olof Johansson <olof@austin.ibm.com>
Subject: Re: [PATCH] SVC sockets don't disable Nagle
Date: Tue, 29 Apr 2003 19:07:21 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EAF13B9.8040402@austin.ibm.com>
References: <Pine.LNX.4.44.0304300029360.8473-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: trond.myklebust@fys.uio.no, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e31.co.us.ibm.com ([32.97.110.129])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Af8W-0002nb-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 17:07:49 -0700
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0304300029360.8473-100000@kenzo.iwr.uni-heidelberg.de>
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
>>Below patch disables it on the server side as well. For latency reasons, 
>>this should be the desired behaviour NFS at both client and server.
> 
> 
> I disagree with this general statement. Nagle is there in the TCP protocol 
> for a specific reason and enabling or disabling it gives the opportunity 
> to better tune the connection.

Yes, Nagle is there to reduce overhead by aggregating data into segments
and piggybacking them with ACKs. Most significant differences will be
when dealing with a steady but slow pace of characters, say text being
typed over a 9600bps serial line.

> It seems like disabling Nagle is the bolierplate answer for anyone who 
> encounters GigEth or better networking simply because the TCP protocol was 
> not designed for such fast networks. But what happens to others that do 
> not have GigEth ? What is the impact of this change for a slower/congested 
> network ?

There is a chance that small requests and replies (~100 bytes) will not
be aggregated into the same segments but instead sent out separately. In
essence, this will result in some additional network overhead due to
headers, but the response times will be perceived as faster even for 
slower networks.

Since NFS traffic is bursty, it is unlikely that any individual request
or reply will be split up between two segments when it didn't need to.

> If anything, I would like to see this as a per-mount-point and 
> per-export-entry option...

I think it would just clutter the documentation and list of options,
since I don't forsee any practical scenarios in which anyone would have
a positive performance impact from having Nagle enabled.


On a side note: As far as I know, most (all?) other NFS implementations 
out there already disable Nagle.


-Olof

-- 
Olof Johansson                                        Office: 4E002/905
pSeries Linux Development                             IBM Systems Group
Email: olof@austin.ibm.com                          Phone: 512-838-9858




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
