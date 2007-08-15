From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Bugme-new] [Bug 8891] New: in-kernel rpc generates
 broken RPCBPROC_GETVERSADDR v4 requests
Date: Wed, 15 Aug 2007 15:57:15 -0400
Message-ID: <46C35A9B.4050909@oracle.com>
References: <bug-8891-10286@http.bugzilla.kernel.org/>
	<20070815122909.c67c0db6.akpm@linux-foundation.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090007060603050802030109"
Cc: netdev@vger.kernel.org, nfs@lists.sourceforge.net,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	speidel@ueberschuss.de
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILP1j-0002MY-2q
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 12:59:35 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ILP1l-00079B-Va
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 12:59:39 -0700
In-Reply-To: <20070815122909.c67c0db6.akpm@linux-foundation.org>
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
--------------090007060603050802030109
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Andrew Morton wrote:
> On Wed, 15 Aug 2007 12:22:51 -0700 (PDT)
> bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=8891
>>
>>            Summary: in-kernel rpc generates broken RPCBPROC_GETVERSADDR v4
>>                     requests
>>            Product: Networking
>>            Version: 2.5
>>      KernelVersion: 2.6.22.1
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Other
>>         AssignedTo: acme@ghostprotocols.net
>>         ReportedBy: speidel@ueberschuss.de
>>
>>
>> Most recent kernel where this bug did not occur: 2.6.20
> 
> Apparently a regression.

RPCBIND v4 requests are an experimental feature.  They can be disabled 
via a kernel build option (CONFIG_SUNRPC_BIND34).  I think these are 
left enabled in Fedora to find just the type of problem before v3 and v4 
becomes the default.

>> Distribution: Fedora Core 6
>> Hardware Environment: x86_64
>> Software Environment: NFS
>> Problem Description: When locking a file, an invalid RPCBPROC_GETVERSADDR
>> procedure call is sent out
>>
>> Steps to reproduce:
>> on the NFS server, run: tcpdump -xX -pni eth0 -s0 port 111 and src host
>> theNFSclient
>> on a client running 2.6.22.1, run: flock -x /nfsmount/somefile ls
>> tcpdump will show:
>>
>> 17:10:01.290655 IP 141.2.15.141.34572 > 141.2.1.1.sunrpc: P 0:168(168) ack 1
>> win 183 <nop,nop,timestamp 966695 115079499>
>>         0x0000:  4500 00dc 53ad 4000 3f06 bcdc 8d02 0f8d  E...S.@.?.......
>>                 0x0010:  8d02 0101 870c 006f cdcd 938d db00 c8a7 
>> .......o........
>>         0x0020:  8018 00b7 e59d 0000 0101 080a 000e c027  ...............'
>>         0x0030:  06db f94b 8000 00a4 fd48 2a07 0000 0000  ...K.....H*.....
>>         0x0040:  0000 0002 0001 86a0 0000 0004 0000 0009  ................
>>         0x0050:  0000 0001 0000 0054 0000 03c6 0000 0007  .......T........
>>         0x0060:  6572 6964 796b 6500 0000 0000 0000 0000  eridyke.........
>>         0x0070:  0000 000e 0000 0000 0000 0001 0000 0002  ................
>>         0x0080:  0000 0003 0000 0004 0000 0005 0000 0006  ................
>>         0x0090:  0000 0007 0000 0007 0000 0009 0000 000a  ................
>>         0x00a0:  0000 000c 0000 0014 0000 001c 0000 0000  ................
>>         0x00b0:  0000 0000 0001 86b5 0000 0004 0000 0003  ................
>>         0x00c0:  7463 7000 0000 0009 3134 312e 322e 312e  tcp.....141.2.1.
>>         0x00d0:  3100 0000 0000 0004 7270 6362            1.......rpcb
>>
>> Note the "141.2.1.1" in the output.
>>
>> According to RFC 1833, you can read here the following fields:
>>
>> RPCBPROC_GETVERSADDR version 4 procedure is being called
>> r_prog == 0x000186b5 == 100021 == nfs.lockd
>> r_vers == 4
>> r_netid == (length 3) "tcp"
>> r_addr == (length 9) "141.2.1.1"
>> r_owner == (length 4) "rpcb"
>>
>> This r_addr member is supposed to contain an universal address. Although I have
>> no source for that, the RFC clearly says a service can listen to an address,
>> and RPCBPROC_GETVERSADDR is supposed to return an universal address too. From
>> this I can conclude that an universal address is supposed to contain the port
>> number, and other operating systems are using the format
>> a.b.c.d.PortHighByte.PortLowByte (like in FTP, but with . instead of ,). I
>> interpret the RFC 1833 so that the port number of the rpcbind, that is, 111, is
>> to be appended, so the correct value of r_addr would be "141.2.1.1.0.111". This
>> matches other implementations.

That RFC is unclear on exactly what a universal address should look 
like.  However speidel's interpretation is not unreasonable, and I'm 
glad he was able to check this against other implementations that I 
don't have.  My unit testing against Solaris did not reveal this issue.

I'll look into the problem.

--------------090007060603050802030109
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


--------------090007060603050802030109
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------090007060603050802030109
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090007060603050802030109--
