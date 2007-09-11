From: "Chris Carlson" <c.carlson@aristoslogic.com>
Subject: Re: nfs_refresh_inode: inode number mismatch
Date: Tue, 11 Sep 2007 14:15:43 -0700
Message-ID: <46E7057F.5090700@aristoslogic.com>
References: <46E6C54F.4020100@aristoslogic.com> <46E6CBB4.7020503@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVD5S-0002PT-7G
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 14:15:58 -0700
Received: from 65-119-21-40.dia.static.qwest.net ([65.119.21.40]
	helo=gabriel.aristoslogic.com)
	by mail.sourceforge.net with smtp (Exim 4.44) id 1IVD5W-0001OE-PR
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 14:16:03 -0700
Received: from gabriel.aristoslogic.com (localhost [127.0.0.1])
	by localhost.aristoslogic.com (Postfix) with ESMTP id 148062231
	for <nfs@lists.sourceforge.net>; Tue, 11 Sep 2007 14:15:57 -0700 (PDT)
Received: from daak.aristoslogic.com (unknown [172.31.1.2])
	by gabriel.aristoslogic.com (Postfix) with SMTP id E298F2204
	for <nfs@lists.sourceforge.net>; Tue, 11 Sep 2007 14:15:56 -0700 (PDT)
In-Reply-To: <46E6CBB4.7020503@oracle.com>
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


Thanks, Chuck.  Yours and Jeff's directions helped a lot.

We are running Linux 2.4.20 on our clients and NetApps ONTAP 6.3.3 on 
the servers that are causing the problem.  Based on all of this info, it 
appears the Linux client is blameless.

Thanks again,
Chris


Chuck Lever wrote:
> Hi Chris-
>
> Chris Carlson wrote:
>> We are running MontaVista Embedded Linux 2.4 with NetApps NFS servers 
>> as the root filesystem and Linux 2.6 mounted filesystems.  A simple 
>> test runs to copy files from one mount point to another (both are 
>> different directories on the same NFS server mounted at differet 
>> points).
>>
>> After 30 copies of a hundred files are made, the system is rebooted 
>> and the test repeats.
>>
>> After 2 reboots, an NFS file is created, and we get the following 
>> error from the kernel:
>>
>> nfs_refresh_inode: inode number mismatch
>> expected (0x11/0xdacea3), got (0x11/0xb8d5e3)
>>
>> We're just trying to figure out what to do to figure out what the 
>> problem is.  Is there a good place to place printks or breakpoints?
>
> This may be due to an RPC XID collision.  Which 2.4 kernel are you 
> using?  The Linux NFS client may be sending the same XID sequence on 
> the same port number after each reboot, in which case the server will 
> respond with a cached reply rather than doing real work.  The cached 
> reply may contain old file ID information, which triggers the "inode 
> number mismatch" message you see in your log.
>
> One way to detect if this is happening is to use "pktt" on the filer. 
> You can capture a packet trace across client reboots to determine if
>
> A) the transport socket's port number is the same across reboots, and
>
> B) the RPC XID sequence is the same

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
