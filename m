From: "Chris Carlson" <c.carlson@aristoslogic.com>
Subject: Re: nfs_refresh_inode: inode number mismatch
Date: Thu, 27 Sep 2007 17:11:30 -0700
Message-ID: <46FC46B2.2000800@aristoslogic.com>
References: <46E6C54F.4020100@aristoslogic.com>
	<20070911130226.131bad3d.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ib3SJ-0007uL-Q2
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 17:11:47 -0700
Received: from wsip-70-165-47-10.oc.oc.cox.net ([70.165.47.10]
	helo=gabriel.aristoslogic.com)
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Ib3SN-0004LU-J7
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 17:11:47 -0700
Received: from gabriel.aristoslogic.com (localhost [127.0.0.1])
	by localhost.aristoslogic.com (Postfix) with ESMTP id 42D2A221F
	for <nfs@lists.sourceforge.net>; Thu, 27 Sep 2007 17:11:41 -0700 (PDT)
Received: from daak.aristoslogic.com (unknown [172.31.1.2])
	by gabriel.aristoslogic.com (Postfix) with SMTP id 1CC71220A
	for <nfs@lists.sourceforge.net>; Thu, 27 Sep 2007 17:11:41 -0700 (PDT)
Received: from [172.31.10.74] ([172.31.10.74]) by
	daak.aristoslogic.com (Netscape Messaging Server 4.1) with ESMTP
	id JP1XVG00.U1E for <nfs@lists.sourceforge.net>; Thu, 27 Sep
	2007 17:11:40 -0700
In-Reply-To: <20070911130226.131bad3d.jlayton@redhat.com>
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


A few weeks ago, I asked for assistance in finding the cause for an 
issue with NFS we were experiencing.  The original message is below.

We followed a path down a response we received having to do with an old 
version of the OnTap system on our NetApps servers.  Apparently, it is a 
caching problem that is known when using NetApps NFS servers.

Suddenly, we discovered the same problem with our Snap Appliance 
servers.  Now we can't blame it on NetApps.

A theory we came up with was that the real-time clock on our boards is 
not operational.  Is it possible that during our frequent reboots, the 
sequence number of NFS RPC calls is coinciding with previous runs, and 
the server is responding with cached packets having the same sequence 
number on the previous run?

I have noticed that in Linux 2.4, the random seed appears to be 
generated from the lower 16 bits of the MAC address.  This implies to me 
that it is quite likely the sequence numbers would be identical from one 
run to the next.

Does our theory that the server is sending cached responses sound plausible?

Thanks for your time,
Chris



> On Tue, 11 Sep 2007 09:41:51 -0700
> "Chris Carlson" <c.carlson@aristoslogic.com> wrote:
>
>   
>> We are running MontaVista Embedded Linux 2.4 with NetApps NFS servers as 
>> the root filesystem and Linux 2.6 mounted filesystems.  A simple test 
>> runs to copy files from one mount point to another (both are different 
>> directories on the same NFS server mounted at differet points).
>>
>> After 30 copies of a hundred files are made, the system is rebooted and 
>> the test repeats.
>>
>> After 2 reboots, an NFS file is created, and we get the following error 
>> from the kernel:
>>
>> nfs_refresh_inode: inode number mismatch
>> expected (0x11/0xdacea3), got (0x11/0xb8d5e3)
>>
>>     
>
>   
>   

CONFIDENTIALITY NOTICE:

This email, together with any attachments, is intended only for use by Aristos Logic Corporation and the
individual(s) to which it is addressed and may contain information that is privileged, confidential or 
exempt from disclosure. If you are not the intended recipient, you are hereby notified that any dissemination,
distribution, or copying of this email, or any attachment, is strictly prohibited. If you have received this
email in error, please notify Aristos Logic Corporation by sending an email to sysadm@aristoslogic.com
and delete this email, along with any attachments, from your computer.

Thank you.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
