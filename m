From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Performance tuning on modern 2.6 series kernels
Date: Thu, 14 Jun 2007 14:00:15 -0400
Message-ID: <4671822F.6010407@oracle.com>
References: <906723.78703.qm@web63902.mail.re1.yahoo.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020603050000030002020009"
Cc: nfs@lists.sourceforge.net
To: Bill Johnstone <beejstone3@yahoo.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HytdL-0008Pe-5O
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 11:01:23 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HytdM-0003Aj-SI
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 11:01:26 -0700
In-Reply-To: <906723.78703.qm@web63902.mail.re1.yahoo.com>
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
--------------020603050000030002020009
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Bill Johnstone wrote:
> 1. TCP vs. UDP.  Assuming a high-bandwidth switched network, with
> enough disk and network bandwidth on the storage server, and
> rsize/wsize (for both) less than the MTU, UDP should have less overhead
> and be faster, than TCP, correct?

The overhead of TCP ACKs and extra TCP header fields does cause slow 
down, but it really depends on network latency, host interrupt latency, 
and host processor speed on the server and client.   The slowdown was 
measured at about 5% several years ago on gigahertz class Pentium III 
processors, but is probably much less these days.

In almost any real world network, TCP will win over UDP because it is 
properly designed to recover from network losses due to congestion and 
link speed mismatches.  Even the "perfect" network you describe can 
suffer packet losses from bus and buffer overruns and hardware errors.

In addition, the NFSv4 spec requires the use of reliable transport 
protocol, which UDP is not.  So for NFSv4, UDP isn't an option.

In other words, TCP is the only choice for any modern NFS deployment.

> 2. Large rsize/wsize, and TCP vs. UDP again.  I understand that if the
> rsize/wsize is larger than the MTU, a UDP packet containing NFS
> read/write data will be fragmented into multiple packets.  However, all
> the documentation in this cases seems to imply that even though the
> same MTU restriction applies to TCP, TCP will be faster in this case
> than the fragmented UDP.  Why is this?  Doesn't TCP need to "fragment"
> the NFS payload as well?

TCP does break data into MTU sized chunks, but has proper management of 
the chunks using 32-bit TCP sequence numbers.  UDP uses only a 16 bit ID 
field in the IP header, which is known to wrap in many common real world 
situations.  IP ID wrapping can cause fragment misassembly which results 
in either a bad checksum on reassembly or corrupt file data.

TCP was designed as a *reliable* transport protocol, thus provides many 
guarantees that the data that leaves one host is the same as the data 
that arrives at the receiving end.  UDP makes no guarantees about data 
reliability.

--------------020603050000030002020009
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
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------020603050000030002020009
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------020603050000030002020009
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020603050000030002020009--
