From: bruce@it.usyd.edu.au (Bruce Janson)
Subject: Re: can't get request slot, write timeout
Date: Tue, 13 Aug 2002 00:26:44 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200208121444.g7CEiLB09220@serf0.cs.usyd.edu.au>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from staff.cs.usyd.edu.au ([129.78.8.1])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eGQm-000385-00
	for <nfs@lists.sourceforge.net>; Mon, 12 Aug 2002 07:44:28 -0700
Received: (from bruce@localhost)
	by serf0.cs.usyd.edu.au (8.11.6/8.11.6) id g7CEiLB09220
	for nfs@lists.sourceforge.net; Tue, 13 Aug 2002 00:44:21 +1000
To: nfs@lists.sourceforge.net
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

    ...
    From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
    To: Kenneth Howlett <aw464@osfn.org>
    cc: nfs@lists.sourceforge.net
    ...
    Date: Mon, 12 Aug 2002 14:15:37 +0200 (CEST)
    ...
    On Sun, 11 Aug 2002, Kenneth Howlett wrote:
    ...
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
    ...

No, User.
    
    > I have fixed my problem by using mount options of rsize=2048,wsize=2048.
    > rsize=1024,wsize=1024 also works, but is a little slower.
    
    That confirms the network problem.
    ...

Eh?
    
    > Most of the people who have reported similar problems also
    > reported using 2.4.x clients, and some reported that the problem
    > did not occur before they upgraded to 2.4.x. This suggests that
    > there might be a bug in 2.4.x clients.
    ...

The surprising thing about this error condition (which has been reported
on this list for a number of years now) is that under such conditions
the Linux NFS client code fails so spectacularly.  Rather than performance
degrading gracefully as one might expect from a congested network (or a
flaky NIC or a marginal cable or a slow receiver or a client kernel RAM
shortage or ...) the kernel instead emits one or more

  can't get a request slot

messages and the affected transactions freeze for extended periods (hours!).


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
