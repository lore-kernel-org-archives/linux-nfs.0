From: aw464@osfn.org (Kenneth Howlett)
Subject: can't get request slot, write timeout
Date: Sun, 11 Aug 2002 22:25:57 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200208120225.WAA09099@osfn.org>
Reply-To: aw464@osfn.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from osfn.org ([209.113.213.86])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17e4u9-0007mO-00
	for <nfs@lists.sourceforge.net>; Sun, 11 Aug 2002 19:26:01 -0700
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




I have two computers, namelessp2, a PII which I usually use; and
junk486, an old 486. Namelessp2 has a davicom dm9102f ethernet
chip built into the motherboard. Junk486 has a 3com 3c503
ethernet card. I have a surecom 505st hub. Both computers run
redhat 7.2 with a 2.4.18 kernel. This is a low cost 10mbps
network made with cheap components because I do not need a high
performance network.

I want to backup namelessp2 to the hard drive of junk486 using
nfs. However, when I write data to the nfs drive, the program
which is writing data appears to hang, and I get many messages
like

   kernel: nfs: server server.domain.name not responding, still
trying
   kernel: nfs: task 10754 can't get a request slot
   kernel: nfs: server server.domain.name OK

If I wait many hours, the program which is trying to write data
to the nfs drive will eventually succeed, so it is not really
hung, but it is so slow that it appears to be hung.

I do not think this problem is caused by network congestion or an
overloaded server because there is no other network activity. I
do not think this problem is caused by buggy network cards or
drivers because I changed network cards and drivers, and the
problem was unchanged.

I have searched through the list archives and found many similar
problems. Some people have reported a hung server because the
client reports that the server is not responding. Other people
have reported a client problem because the problem only occurs
with certain clients. Some people say it is hung and other people
say performance is low. Some people reported the request slot
error message and some did not.

Each of these problem reports is slightly different, but I think
most are the same problem. But in the list archives, it appears
that the developers do not recognize this as the same problem,
because everyone reports it differently.

In my search of the archive, all the suggested solutions I found
were too vague to be useful, and I did not find any messages
which confirmed that anyone had ever solved this problem.

The problem only occurred on writes. I have no problem with
reads. The problem may occur when either computer writes to the
other, but is more likely to occur when namelessp2 writes to
junk486. The problem is more likely to occur when writing a large
file than when writing a small file. I tried changing the block
size used by the program which writes the file; the problem
occurred with any block size but was more likely to occur with a
large block size. The problem did not occur if I used a small
block size and opened and closed the file for each block. Opening
the file with O_SYNC had no effect on the problem. Exporting with
sync or async had no effect on the problem. Mounting with
rsize=8192,wsize=8192 had no effect on the problem. The problem
does not occur when namelessp2 nfs mounts itself.

If I do 'ping -f -s nnnn' with various numbers for nnnn; the
higher nnnn is, the more packets are lost. If nnnn is a small
number, no packets are lost. If nnnn is a large number, all
packets are lost. More packets are lost when namelessp2 pings
junk486 than when junk486 pings namelessp2. If namelessp2 pings
junk486, 1% packet loss occurs at a packet size of 1000 to 4000.
If junk486 pings namelessp2, 1% packet loss occurs at a packet
size of 5000 to 9000.

I have fixed my problem by using mount options of
rsize=2048,wsize=2048. rsize=1024,wsize=1024 also works, but is a
little slower.

Most of the people who have reported similar problems also
reported using 2.4.x clients, and some reported that the problem
did not occur before they upgraded to 2.4.x. This suggests that
there might be a bug in 2.4.x clients. However, I think the
problem is not the 2.4.x  clients, but the utils used with 2.4.x
clients; the newer utils have a higher default rsize/wsize than
the old utils. Apparently the new default rsize/wsize does not
work with some hardware.

I have already solved my problem, so I do not need any help. I am
posting this message for the benefit of anyone who is searching
the archives for solutions to this problem.

Next time someone asks what to do about request slot error
messages, or a hung server, or very slow performance; that person
should be told to try a smaller rsize/wsize. This should be added
to the FAQ and to the HOWTO and to the nfs manpage. Since so many
people have had this problem, this should be added to the
documentation.

In the FAQ it says that tcp is faster than udp on congested
networks.  I think the same effect could be achieved by using udp
with a small rsize/wsize.

When I was researching this, I spent a while looking for the FAQ
before I realized the FAQ was right in front of me at
http://nfs.sourceforge.net. I think that page should say 'this is
the FAQ'.

When I was searching the archive, it would have been easier if I
could have downloaded one large digest of all messages from the
last year or two.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
