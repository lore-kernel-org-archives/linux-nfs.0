From: Michael Feig <meikel@scripps.edu>
Subject: NFS client eventually stalls with automount
Date: Wed, 26 Jun 2002 17:23:52 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D1A5B18.7050601@scripps.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.scripps.edu ([192.42.82.59])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17NN8B-0008QW-00
	for <nfs@lists.sourceforge.net>; Wed, 26 Jun 2002 17:27:27 -0700
Received: from antigen.scripps.edu (antigen.scripps.edu [137.131.200.100])
	by ns1.scripps.edu (8.11.6/TSRI-4.2rx) with SMTP id g5R0RPJ20739
	for <nfs@lists.sourceforge.net>; Wed, 26 Jun 2002 17:27:25 -0700 (PDT)
Received: from vangogh.scripps.edu (vangogh.scripps.edu [137.131.252.53])
	by relay1.scripps.edu (8.11.6/TSRI-4.2.1rAV) with ESMTP id g5R0RJe13700
	for <nfs@lists.sourceforge.net>; Wed, 26 Jun 2002 17:27:19 -0700 (PDT)
Received: from scripps.edu (vangogh [137.131.252.53])
	by vangogh.scripps.edu (8.11.6/TSRI-4.1.0) with ESMTP id g5R0Nqa02320
	for <nfs@lists.sourceforge.net>; Wed, 26 Jun 2002 17:23:52 -0700
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

Hi!

Here is the problem. When I try to read and write at the same time (it 
shows up when trying to create a tar file)
on an automounted directory the process starts up fine, but pretty 
quickly slows down and eventually
stalls completely. The process is then frozen but reacts to a kill 
signal after a few minutes.
At the same time I have seen kernel messages such as 

Jun 25 17:37:05 vangogh kernel: nfs: task 39046 can't get a request slot
Jun 25 17:37:37 vangogh kernel: nfs: server bebop OK
....

Networking seems to be fine otherwise, in particular I have no problems 
when I just read OR write from the same
disk (as when I would create a tar file on a local disk from the mounted 
directory).

I ran into this with the RedHat 7.3 distribution kernel (2.4.18) but 
also tried the very latest 2.4.19-rc1 with
Trond's latest NFS_ALL patches (for pre10).

The machine from where the disk is server is running SGI IRIX 6.5 and 
nfsstat shows that I am using
NFS V3.

So far I did not change any NFS options such as buffer size yet.

Any suggestions?

Thanks.

-- 
 Michael Feig                           meikel@scripps.edu 

 The Scripps Research Institute, La Jolla, CA





-------------------------------------------------------
This sf.net email is sponsored by: Jabber Inc.
Don't miss the IM event of the season | Special offer for OSDN members! 
JabberConf 2002, Aug. 20-22, Keystone, CO http://www.jabberconf.com/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
