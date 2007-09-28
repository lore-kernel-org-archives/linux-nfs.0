From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfs_refresh_inode: inode number mismatch
Date: Fri, 28 Sep 2007 10:52:07 -0400
Message-ID: <46FD1517.6040707@oracle.com>
References: <46E6C54F.4020100@aristoslogic.com>	<20070911130226.131bad3d.jlayton@redhat.com>
	<46FC46B2.2000800@aristoslogic.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060303090609070401000407"
Cc: nfs@lists.sourceforge.net
To: Chris Carlson <c.carlson@aristoslogic.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbHCU-0001C1-IS
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 07:52:18 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IbHCY-00043a-3s
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 07:52:23 -0700
In-Reply-To: <46FC46B2.2000800@aristoslogic.com>
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

This is a multi-part message in MIME format.
--------------060303090609070401000407
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Chris-

Chris Carlson wrote:
> A few weeks ago, I asked for assistance in finding the cause for an 
> issue with NFS we were experiencing.  The original message is below.
> 
> We followed a path down a response we received having to do with an old 
> version of the OnTap system on our NetApps servers.  Apparently, it is a 
> caching problem that is known when using NetApps NFS servers.
> 
> Suddenly, we discovered the same problem with our Snap Appliance 
> servers.  Now we can't blame it on NetApps.
> 
> A theory we came up with was that the real-time clock on our boards is 
> not operational.  Is it possible that during our frequent reboots, the 
> sequence number of NFS RPC calls is coinciding with previous runs, and 
> the server is responding with cached packets having the same sequence 
> number on the previous run?
> 
> I have noticed that in Linux 2.4, the random seed appears to be 
> generated from the lower 16 bits of the MAC address.  This implies to me 
> that it is quite likely the sequence numbers would be identical from one 
> run to the next.
> 
> Does our theory that the server is sending cached responses sound plausible?

This theory is what I suggested in my reply to your original e-mail.  So 
I think it's plausible!  :-)

If the client's XID generator starts at the same value after every 
reboot, the port number the client uses to connect is the same, and the 
client's IP address is the same, the server has little to distinguish 
fresh RPC requests from old ones.

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
>>   
>>   
> 
> CONFIDENTIALITY NOTICE:
> 
> This email, together with any attachments, is intended only for use by Aristos Logic Corporation and the
> individual(s) to which it is addressed and may contain information that is privileged, confidential or 
> exempt from disclosure. If you are not the intended recipient, you are hereby notified that any dissemination,
> distribution, or copying of this email, or any attachment, is strictly prohibited. If you have received this
> email in error, please notify Aristos Logic Corporation by sending an email to sysadm@aristoslogic.com
> and delete this email, along with any attachments, from your computer.
> 
> Thank you.
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Microsoft
> Defy all challenges. Microsoft(R) Visual Studio 2005.
> http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

--------------060303090609070401000407
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------060303090609070401000407
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--------------060303090609070401000407
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060303090609070401000407--
