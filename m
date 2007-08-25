From: David Bartley <dtbartle@csclub.uwaterloo.ca>
Subject: NFS Write Delays
Date: Sat, 25 Aug 2007 00:47:41 -0400
Message-ID: <46CFB46D.8010405@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOnYk-0002qO-Eu
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 21:47:42 -0700
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IOnYn-0007Kl-Kb
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 21:47:46 -0700
Received: from caffeine.csclub.uwaterloo.ca (localhost [127.0.0.1])
	by caffeine.csclub.uwaterloo.ca (Postfix) with ESMTP id C2D7674978
	for <nfs@lists.sourceforge.net>; Sat, 25 Aug 2007 00:47:41 -0400 (EDT)
Received: from [129.97.134.14] (glucose-fructose.csclub.uwaterloo.ca
	[129.97.134.14])
	by caffeine.csclub.uwaterloo.ca (Postfix) with ESMTP id B3FAD74905
	for <nfs@lists.sourceforge.net>; Sat, 25 Aug 2007 00:47:41 -0400 (EDT)
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

Hi,

I'm NFS mounting a 100G ext3 partion over NFS. There's a gigabit link 
between the server and client. When I attempt to copy a file from the 
client to the server, nothing is transferred for between 5 and 10 
seconds. If I run wireshark, I see some RPC requests and replys. It 
looks like every request gets a reply, so I don't think the server is 
blocking. As well, I have another client that is able to transfer files 
without delay to this server. So it appears to be a client issue. I'm 
not using any extra options when mounting (I did try with async and with 
udp, but this did not fix anything). This also isn't an issue with the 
client's disk, as I attempted to dd /dev/zero across and got the same delay.

I'm running Debian on all systems. Here's the versions I've tested this 
with (client and server):

nfs-utils: 1:1.0.10-6+etch.1 and 1.1.1~git-20070709-3
portmap: 5-26 and 6.0-4
kernel: client: 2.6.21-1-alpha-smp, server: 2.6.22-1-amd64

If you need any more information, let me know. If there's any flag I can 
turn on to see what's happening, that would be useful to test.

-- David

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
