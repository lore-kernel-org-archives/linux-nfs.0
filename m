From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: can't get request slot, write timeout
Date: Mon, 12 Aug 2002 14:15:37 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0208121320300.32192-100000@kenzo.iwr.uni-heidelberg.de>
References: <200208120225.WAA09099@osfn.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eE6w-0005Kx-00
	for <nfs@lists.sourceforge.net>; Mon, 12 Aug 2002 05:15:50 -0700
To: Kenneth Howlett <aw464@osfn.org>
In-Reply-To: <200208120225.WAA09099@osfn.org>
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

On Sun, 11 Aug 2002, Kenneth Howlett wrote:

> Namelessp2 has a davicom dm9102f ethernet chip built into the
> motherboard. Junk486 has a 3com 3c503 ethernet card. I have a surecom
> 505st hub.  ... This is a low cost 10mbps network made with cheap
> components because I do not need a high performance network.

Then why are you asking NFS over UDP to work well on it ? Especially a 
computer called "junk" :-)

> I want to backup namelessp2 to the hard drive of junk486 using
> nfs.

Maybe you should use something TCP based: either NFS over TCP or something 
else like tar and netcat, rsync, etc.

> I do not think this problem is caused by network congestion or an
> overloaded server because there is no other network activity.

No other network activity doesn't mean that there is no congestion. 
Congestion can also be created with 2 computers when one sends faster than 
the other can receive. Check /proc/net/dev file on both computers for 
errors.

> I have searched through the list archives and found many similar
> problems. ... Each of these problem reports is slightly different, but I
> think most are the same problem. But in the list archives, it appears
> that the developers do not recognize this as the same problem, because
> everyone reports it differently.

I posted some messages in the past about this. As the error message says,
the communication between the client and the server is broken - that is
the problem and it's the same in all cases; however, there can be 1001 
causes for it and each one may have a different solution.

> If I do 'ping -f -s nnnn' with various numbers for nnnn; the
> higher nnnn is, the more packets are lost.

That points clearly toward a network problem. Any UDP based service will 
have problems on a network that looses packets. That's why it's called UDP 
= Unreliable.

> I have fixed my problem by using mount options of rsize=2048,wsize=2048.
> rsize=1024,wsize=1024 also works, but is a little slower.

That confirms the network problem.

> Most of the people who have reported similar problems also
> reported using 2.4.x clients, and some reported that the problem
> did not occur before they upgraded to 2.4.x. This suggests that
> there might be a bug in 2.4.x clients.

There are a lot of differences between 2.2 and 2.4, including differences 
in network drivers which might impact your network.

> I have already solved my problem, so I do not need any help.

You've done well. But you've cured the symptoms, not the real cause.

> Next time someone asks what to do about request slot error
> messages, or a hung server, or very slow performance; that person
> should be told to try a smaller rsize/wsize. This should be added
> to the FAQ and to the HOWTO and to the nfs manpage.

Why ? So that afterwards this person complains that the performance of
Linux NFS is poor ? No, this person should read the page at
nfs.sourceforge.net and look at point 11 which is supposed to be a
starting point for investigation, not a panacea. And only after being sure
that there are no problems with the whole setup (hardware + software),
he/she should complain.

> In the FAQ it says that tcp is faster than udp on congested
> networks.  I think the same effect could be achieved by using udp
> with a small rsize/wsize.

That's debatable. TCP is supposed to handle these cases well 'cause that's
what it was designed for. The NFS client over UDP just recently got better
behaviour through Trond's efforts, but having it perform just as over TCP 
would probably mean re-implementing TCP within NFS. Eh, now Trond can 
shoot me :-)

> When I was searching the archive, it would have been easier if I
> could have downloaded one large digest of all messages from the
> last year or two.

All lists hosted at SourceForge behave the same way. Complain to them, if 
you want ;-)

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
