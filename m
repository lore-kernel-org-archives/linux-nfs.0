From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: nfs_statfs: statfs error = 116
Date: Thu, 18 Sep 2003 11:56:18 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F698142.6070404@inf.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19zvWf-0003eV-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 02:56:37 -0700
Received: from medoc.inf.ethz.ch ([129.132.178.200])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19zvWS-0007KC-68
	for nfs@lists.sourceforge.net; Thu, 18 Sep 2003 02:56:24 -0700
Received: from localhost (localhost [127.0.0.1])
	by medoc.inf.ethz.ch (Postfix) with ESMTP id 76D50A18C
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 11:56:20 +0200 (MEST)
Received: from medoc.inf.ethz.ch ([127.0.0.1])
 by localhost (medoc [127.0.0.1]) (amavisd-new, port 10024) with LMTP
 id 01107-01 for <nfs@lists.sourceforge.net>;
 Thu, 18 Sep 2003 11:56:19 +0200 (MEST)
Received: from inf.ethz.ch (ikarus.inf.ethz.ch [129.132.10.58])
	by medoc.inf.ethz.ch (Postfix) with ESMTP id 6E823A18B
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 11:56:19 +0200 (MEST)
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

Dear all,

Server: RedHat 7.3, kernel 2.4.20-19.7smp, nfs-util 1.0.5
Client: RedHat 7.3, kernel 2.4.18-27.7.x, nfs-utils 0.3.3-6.73

Over 200 entries in /etc/exports, after issuing 'exportfs -r', some 
clients keep certain home directories stale.

On the client, the dmesg output says:

nfs: server x not responding, still trying
nfs: server x OK
nfs_statfs: statfs error = 116
nfs_statfs: statfs error = 116
nfs_statfs: statfs error = 116
nfs_statfs: statfs error = 116

bash# ls -ld /home/user
ls: /home/user: Stale NFS file handle

On the server, I'm looking at the traffic from client ('tcpdump -s300 -i 
eth2 -Nt host client'):
...
client.4180178520 > fs.nfs: 112 read fh Unknown/1 4096 bytes @ 
0x000029000 (DF)
x.nfs > client.4180178520: reply ok 32 (DF)
client.4196955736 > fs.nfs: 112 read fh Unknown/1 4096 bytes @ 
0x000029000 (DF)
x.nfs > client.4196955736: reply ok 32 (DF)
client.4213732952 > fs.nfs: 112 read fh Unknown/1 4096 bytes @ 
0x000029000 (DF)
x.nfs > client.4213732952: reply ok 32 (DF)
client.4230510168 > fs.nfs: 112 read fh Unknown/1 4096 bytes @ 
0x000029000 (DF)
x.nfs > client.4230510168: reply ok 32 (DF)
client.4247287384 > fs.nfs: 112 read fh Unknown/1 4096 bytes @ 
0x000029000 (DF)
x.nfs > client.4247287384: reply ok 32 (DF)
client.4264064600 > fs.nfs: 112 read fh Unknown/1 4096 bytes @ 
0x000029000 (DF)
x.nfs > client.4264064600: reply ok 32 (DF)
client.4280841816 > fs.nfs: 112 read fh Unknown/1 4096 bytes @ 
0x000029000 (DF)
x.nfs > client.4280841816: reply ok 32 (DF)
...

I don't know how to interpret this, but the facts are:

- the server x is running NFS, most clients still work w/o problems
- client can not recover from the stale handle and it looks like it is 
spamming the server

My questions are:

- Is this a race?
- Is there a way to get the client working again w/o having to reboot 
(or kill all the users processes and umount the home if that's 
possible)? I tried restarting rpc.statd on the client but that did not help.
- How can I provide more debugging infos if needed?
- Could this be related to the thread "[NFS] nfs errors clutter up logs 
after 2.4.20 -> 2.4.22-pre10", we really see a lot of messages like that 
on all clients

Thanks for your help.

Regards,
     Marc







-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
