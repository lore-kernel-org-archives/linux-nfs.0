From: Steve Dickson <SteveD@RedHat.com>
Subject: NFSD Flow Control Using the TCP Transport
Date: Wed, 19 Mar 2003 10:05:15 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E78872B.5020702@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18vf8C-0000uB-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Mar 2003 07:05:28 -0800
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

There seems to be some issues (probably known) with the flow control
over  TCP connections (on an SMP machine) to NFSD. Unfortunately,
the fstress benchmark brings these issues out fairly nicely :-(
This is occurring in a 2.4.20 kernel.

When fstress starts  it's stress tests,  svc_tcp_sendto() immediately 
starts failing
with -EGAINs. Initially, this caused  an oops because svc_delete_socket()
was being called twice for the same socket [ which was easily fixed by 
checking
 for the SK_DEAD bit in svsk->sk_flags],  but now the tests just fail.

The problem seems to stem from the fact that the queued memory in
the TCP send buffer (i.e. sk->wmem_queued) is not being released ( i.e
tcp_wspace(sk)  becomes negative and  never recovers).

Here is what's (appears to be)  happening:
Fstress opens one TCP connection and then start sending
multiple nfs ops with different fhandles . The problems start when
a nfs op, with a large responses (like a read), gets 'stuck' in the nfs code
for a few microseconds and in the meantime other nfs ops, with smaller
responses are being processed.  With every smaller response, the
sk->wmem_queued value is incremented. Now when the 'stuck' nfs read
tries to send its responses the send buffer is full (i.e. 
tcp_memory_free(sk)
in tcp_sendmsg() fails) and  after a 30 second sleep (in tcp_sendmsg())
-EAGAIN is returned and the show is over.....

I _guess_ what is suppose  to happen is that the queued memory  will be
freed (or reclaimed) when a socket buffer is freed (via kfree_skb()).
Which in turn causes the threads waiting for memory (i.e. sleeping
in tcp_sendmsg()) to be woke up via a  call to sk->write_space().
But this does not seem to be happening even when the smaller
replies are processed....

Can anyone shed some light on what the heck is going on here
and if there are any patches or solutions or ideas addressing this
problem.

TIA,

SteveD.




-------------------------------------------------------
This SF.net email is sponsored by: Does your code think in ink? 
You could win a Tablet PC. Get a free Tablet PC hat just for playing. 
What are you waiting for?
http://ads.sourceforge.net/cgi-bin/redirect.pl?micr5043en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
