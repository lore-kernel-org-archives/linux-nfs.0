From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: can't get request slot, write timeout
Date: Mon, 12 Aug 2002 19:45:32 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0208121903390.32192-100000@kenzo.iwr.uni-heidelberg.de>
References: <200208121444.g7CEiLB09220@serf0.cs.usyd.edu.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eJG5-0003hM-00
	for <nfs@lists.sourceforge.net>; Mon, 12 Aug 2002 10:45:38 -0700
To: Bruce Janson <bruce@it.usyd.edu.au>
In-Reply-To: <200208121444.g7CEiLB09220@serf0.cs.usyd.edu.au>
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

On Tue, 13 Aug 2002, Bruce Janson wrote:

>     have problems on a network that looses packets. That's why it's
>     called UDP = Unreliable.
>     ...
> No, User.

Sorry, there were supposed to be some quotes around Unreliable. I was just 
playing with LOCALE settings when I wrote the message... But 'man udp' 
says that in the first few lines on my machine.

>     > I have fixed my problem by using mount options of rsize=2048,wsize=2048.
>     > rsize=1024,wsize=1024 also works, but is a little slower.
>     That confirms the network problem.
> Eh?

With rsize/wsize=1024, the whole NFS data chunk fits into one Ethernet 
packet, with rsize/wsize=2048 it fits into 2 packets. Network problems 
generally manifest themselves (to the upper levels) as packet losses, 
which means a small rsize/wsize has much better chances to arrive 
completely at the other end. Also in case of packets missing, it's much 
easier to retransmit a small data chunk than a large one.

> The surprising thing about this error condition (which has been reported
> on this list for a number of years now) is that under such conditions
> the Linux NFS client code fails so spectacularly. 

The problem is known and work has be done to improve the situation: NFS 
client over TCP exists for some time and Trond worked on improving the 
behaviour of NFS client over UDP.

> Rather than performance degrading gracefully as one might expect from a
> congested network (or a flaky NIC or a marginal cable or a slow receiver
> or a client kernel RAM shortage or ...) ...

I beg to disagree. If you want performance degrading (more) gracefully
switch to NFS over TCP. And "one might expect" that only for slow
receiver, all other causes are much likely to produce a sudden
interruption. 
F.e. in a free memory shortage lots of consecutive packets can be dropped.  
A congested network, flaky NIC and marginal cable could lead f.e. to the
dreaded "transmit timed out" error (due to colisions, media problems,
etc.) which often does not "repair itself", as it takes some time until
the reset comes; the Tx ring is full, meaning that even if the reset
clears the error state, there is a chance that the flurry of packets to be
sent will trigger it again; in such a case (at either client or server
side), the packets are much delayed or even lost. That's why a healthy
network is a must for good UDP-based services.

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
