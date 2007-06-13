From: Bill Johnstone <beejstone3@yahoo.com>
Subject: Performance tuning on modern 2.6 series kernels
Date: Wed, 13 Jun 2007 10:45:14 -0700 (PDT)
Message-ID: <906723.78703.qm@web63902.mail.re1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HyWuE-0006sf-Vo
	for nfs@lists.sourceforge.net; Wed, 13 Jun 2007 10:45:19 -0700
Received: from web63902.mail.re1.yahoo.com ([69.147.97.117])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HyWuG-0005IS-R6
	for nfs@lists.sourceforge.net; Wed, 13 Jun 2007 10:45:22 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hello all.

I've been trying to understand performance tuning for NFSv3 on Linux
2.6 kernels (say 2.6.20 and up), and I just wound up uncertain, with a
lot of questions.  Additionally, the Linux-NFS documentation for
performance tuning at http://nfs.sourceforge.net/nfs-howto/ar01s05.html
has a lot of discussion regarding 2.4 series kernels, which doesn't
really seem that relevant these days.  It would be great if there was
more discussion of 2.6-related information (if so desired, I could
submit some changes to the docs based on what I hear back).  Anyway,
here's what I would really appreciate some clarification on:

1. TCP vs. UDP.  Assuming a high-bandwidth switched network, with
enough disk and network bandwidth on the storage server, and
rsize/wsize (for both) less than the MTU, UDP should have less overhead
and be faster, than TCP, correct?

2. Large rsize/wsize, and TCP vs. UDP again.  I understand that if the
rsize/wsize is larger than the MTU, a UDP packet containing NFS
read/write data will be fragmented into multiple packets.  However, all
the documentation in this cases seems to imply that even though the
same MTU restriction applies to TCP, TCP will be faster in this case
than the fragmented UDP.  Why is this?  Doesn't TCP need to "fragment"
the NFS payload as well?

3. Socket buffers.  Many references mention changing
/proc/sys/net/core/{r,w}mem_default and
/proc/sys/net/core/{r,w}mem_max
but documents such as NetApp's "Using the Linux NFS Client with Network
Appliance Filers" ( http://www.netapp.com/library/tr/3183.pdf ) mention
that this is not necessary in 2.6 kernels, as they "auto-tune" socket
buffers.  However, even if we needn't change the default values, is
there any benefit to increasing the rmem_max / wmem_max parameters?

4. tcp_window_scaling, tcp_timestamps, and tcp_sack .  There is an IBM
Linux NFS performance tuning article at
http://www.ibm.com/developerworks/eserver/library/es-033104.html which
mentions turning off all three of these features, and presumaby the
tcp_window_scaling causes them to see an effective MSS less than what
they get without it.  Is there merit to turning these features off
today, on modern 2.6 kernels?

Thank you very much for any enlightenment you provide.



      ___________________________________________________________________________________
You snooze, you lose. Get messages ASAP with AutoCheck
in the all-new Yahoo! Mail Beta.
http://advision.webevents.yahoo.com/mailbeta/newmail_html.html

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
