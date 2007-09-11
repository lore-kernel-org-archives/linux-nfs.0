From: "Chris Carlson" <c.carlson@aristoslogic.com>
Subject: Re: nfs_refresh_inode: inode number mismatch
Date: Tue, 11 Sep 2007 14:11:45 -0700
Message-ID: <46E70491.5010109@aristoslogic.com>
References: <46E6C54F.4020100@aristoslogic.com><20070911130226.131bad3d.jlay	ton@redhat.com>
	<20070911134353.60e7bda7.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVD1h-000265-UI
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 14:12:06 -0700
Received: from 65-119-21-40.dia.static.qwest.net ([65.119.21.40]
	helo=gabriel.aristoslogic.com)
	by mail.sourceforge.net with smtp (Exim 4.44) id 1IVD1m-0003Up-CG
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 14:12:10 -0700
Received: from gabriel.aristoslogic.com (localhost [127.0.0.1])
	by localhost.aristoslogic.com (Postfix) with ESMTP id 60788223D
	for <nfs@lists.sourceforge.net>; Tue, 11 Sep 2007 14:11:59 -0700 (PDT)
Received: from daak.aristoslogic.com (unknown [172.31.1.2])
	by gabriel.aristoslogic.com (Postfix) with SMTP id 31A3B2204
	for <nfs@lists.sourceforge.net>; Tue, 11 Sep 2007 14:11:59 -0700 (PDT)
In-Reply-To: <20070911134353.60e7bda7.jlayton@redhat.com>
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


Thanks a lot, Jeff.  It looks like this is the problem.  You just saved 
me from days of research and testing.

Chris


Jeff Layton wrote:
> On Tue, 11 Sep 2007 13:02:26 -0400
> Jeff Layton <jlayton@redhat.com> wrote:
>
>   
>> On Tue, 11 Sep 2007 09:41:51 -0700
>> "Chris Carlson" <c.carlson@aristoslogic.com> wrote:
>>
>>     
>>> We are running MontaVista Embedded Linux 2.4 with NetApps NFS servers as 
>>> the root filesystem and Linux 2.6 mounted filesystems.  A simple test 
>>> runs to copy files from one mount point to another (both are different 
>>> directories on the same NFS server mounted at differet points).
>>>
>>> After 30 copies of a hundred files are made, the system is rebooted and 
>>> the test repeats.
>>>
>>> After 2 reboots, an NFS file is created, and we get the following error 
>>> from the kernel:
>>>
>>> nfs_refresh_inode: inode number mismatch
>>> expected (0x11/0xdacea3), got (0x11/0xb8d5e3)
>>>
>>>       
>> This may be a bug in the NetApp. I saw some similar messages when
>> working on an issue and it turned out to be a filer bug. I ended
>> up tracking it down by doing network captures, and then searching them
>> for the 'expected' and 'got' sequence of bytes in wireshark. It showed
>> that in some cases the netapp was sending back a new fileid in the
>> WCC attributes for the dir when a create call would fail.
>>
>>     
>
> For the record, the NetApp engineers I worked with on this issue referenced
> NetApp BURT:
>
> 244015: We should not have pre/post attributes in case of an error coming
> from exports code
>
> You might want to check that your filer has that fix.
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
