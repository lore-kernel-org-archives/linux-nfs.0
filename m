From: David Bartley <dtbartle@csclub.uwaterloo.ca>
Subject: Re: NFS Write Delays
Date: Sat, 25 Aug 2007 01:30:08 -0400
Message-ID: <46CFBE60.1080609@csclub.uwaterloo.ca>
References: <46CFB46D.8010405@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOoDo-0006j0-EF
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 22:30:08 -0700
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IOoDq-00062K-E4
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 22:30:12 -0700
Received: from caffeine.csclub.uwaterloo.ca (localhost [127.0.0.1])
	by caffeine.csclub.uwaterloo.ca (Postfix) with ESMTP id 6231A744A4
	for <nfs@lists.sourceforge.net>; Sat, 25 Aug 2007 01:30:09 -0400 (EDT)
Received: from [129.97.134.14] (glucose-fructose.csclub.uwaterloo.ca
	[129.97.134.14])
	by caffeine.csclub.uwaterloo.ca (Postfix) with ESMTP id 4ECCE7445E
	for <nfs@lists.sourceforge.net>; Sat, 25 Aug 2007 01:30:09 -0400 (EDT)
In-Reply-To: <46CFB46D.8010405@csclub.uwaterloo.ca>
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

I was able to turn on debugging and I believe I see what's happening. 
Here's what I see in /var/log/messages:

01:01:31 kernel: nfs: write(/mterry2.avi(147458), 262144@0)
01:01:31 kernel: nfs: write(/mterry2.avi(147458), 262144@262144)
01:01:31 kernel: nfs: write(/mterry2.avi(147458), 262144@524288)
01:01:31 kernel: nfs: write(/mterry2.avi(147458), 262144@786432)
.
.
.
01:01:38 kernel: nfs: write(/mterry2.avi(147458), 262144@417071104)
01:01:38 kernel: nfs: write(/mterry2.avi(147458), 201314@417333248)
01:01:38 kernel: nfs: flush(0:13/147458)
01:01:39 kernel: RPC: 62652 reserved req fffffc007b4fc000 xid 4e72324e
01:01:39 kernel: RPC: 62652 xprt_prepare_transmit
01:01:39 kernel: RPC: 62652 xprt_transmit(262332)
01:01:39 kernel: RPC: 62653 reserved req fffffc007b4fc128 xid 4f72324e

So it looks like it takes 7 seconds to read the entire file into memory 
(the client has 6G of RAM), and only after it is read in is the file 
pushed to the network. I'm wondering if there is some way to force the 
data to start transmitting before it's does reading the file in.

-- David


David Bartley wrote:
> Hi,
>
> I'm NFS mounting a 100G ext3 partion over NFS. There's a gigabit link 
> between the server and client. When I attempt to copy a file from the 
> client to the server, nothing is transferred for between 5 and 10 
> seconds. If I run wireshark, I see some RPC requests and replys. It 
> looks like every request gets a reply, so I don't think the server is 
> blocking. As well, I have another client that is able to transfer files 
> without delay to this server. So it appears to be a client issue. I'm 
> not using any extra options when mounting (I did try with async and with 
> udp, but this did not fix anything). This also isn't an issue with the 
> client's disk, as I attempted to dd /dev/zero across and got the same delay.
>
> I'm running Debian on all systems. Here's the versions I've tested this 
> with (client and server):
>
> nfs-utils: 1:1.0.10-6+etch.1 and 1.1.1~git-20070709-3
> portmap: 5-26 and 6.0-4
> kernel: client: 2.6.21-1-alpha-smp, server: 2.6.22-1-amd64
>
> If you need any more information, let me know. If there's any flag I can 
> turn on to see what's happening, that would be useful to test.
>
> -- David
>
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc.
> Still grepping through log files to find problems?  Stop.
> Now Search log events and configuration files using AJAX and a browser.
> Download your FREE copy of Splunk now >>  http://get.splunk.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>
>   


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
