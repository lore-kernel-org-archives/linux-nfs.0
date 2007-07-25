From: Chuck Lever <chuck.lever@oracle.com>
Subject: rpcbind behavior on Fedora 7
Date: Tue, 24 Jul 2007 22:08:40 -0400
Message-ID: <46A6B0A8.40700@oracle.com>
References: <20070708191640.GA13962@uio.no>
	<18065.43199.104020.412029@notabene.brown>
	<20070715083114.GB4158@uio.no>
	<18074.50730.591965.39211@notabene.brown>
	<20070716092047.GA10353@uio.no>
	<18075.17719.855332.259470@notabene.brown>
	<20070722191733.GA31501@uio.no> <46A52816.6050500@oracle.com>
	<20070724172451.GA14026@uio.no>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030108040902010901060804"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDWKH-00027x-Mg
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 19:10:10 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDWKL-0001t5-0a
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 19:10:13 -0700
In-Reply-To: <20070724172451.GA14026@uio.no>
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
--------------030108040902010901060804
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Steve-

I was trying out the mount.nfs test case for another bug (see below). 
The test case didn't work against a Fedora 7 server.  Trying to mount 
with UDP against a specific port just hangs.  So I tried an rpcinfo 
against it to see what the current rocbind configuration was.

 > [root@picasso ~]# rpcinfo ingres
 >    program version netid     address                service    owner
 >     100000    4    tcp6      ::.0.111               portmapper superuser
 >     100000    3    tcp6      ::.0.111               portmapper superuser
 >     100000    2    tcp6      ::.0.111               portmapper superuser
 >     100000    4    udp6      ::.0.111               portmapper superuser
 >     100000    3    udp6      ::.0.111               portmapper superuser
 >     100000    2    udp6      ::.0.111               portmapper superuser
 >     100000    4    local     /v                     portmapper superuser
 >     100000    3    local     /v                     portmapper superuser
 >     100000    2    local     /v                     portmapper superuser
 >     100024    1    udp6      ::.2.222               status     unknown
 >     100024    1    tcp6      ::.2.225               status     unknown
 >     100021    1    tcp6      ::.170.233             nlockmgr   unknown
 >     100021    3    tcp6      ::.170.233             nlockmgr   unknown
 >     100021    4    tcp6      ::.170.233             nlockmgr   unknown
 >     100011    1    udp6      ::.3.158               rquotad    unknown
 >     100011    2    udp6      ::.3.158               rquotad    unknown
 >     100011    1    tcp6      ::.3.161               rquotad    unknown
 >     100011    2    tcp6      ::.3.161               rquotad    unknown
 >     100021    1    udp6      ::.128.0               nlockmgr   unknown
 >     100021    3    udp6      ::.128.0               nlockmgr   unknown
 >     100021    4    udp6      ::.128.0               nlockmgr   unknown
 >     100003    2    udp6      ::.8.1                 nfs        unknown
 >     100003    3    udp6      ::.8.1                 nfs        unknown
 >     100003    4    udp6      ::.8.1                 nfs        unknown
 >     100003    2    tcp6      ::.8.1                 nfs        unknown
 >     100003    3    tcp6      ::.8.1                 nfs        unknown
 >     100003    4    tcp6      ::.8.1                 nfs        unknown
 >     100005    1    udp6      ::.2.135               mountd     unknown
 >     100005    1    tcp6      ::.2.138               mountd     unknown
 >     100005    2    udp6      ::.2.135               mountd     unknown
 >     100005    2    tcp6      ::.2.138               mountd     unknown
 >     100005    3    udp6      ::.2.135               mountd     unknown
 >     100005    3    tcp6      ::.2.138               mountd     unknown
 > [root@picasso ~]#

Um.  Ok, where are the IPv4 entries?

I've now completely shut off IPv6 initialization and autoconfiguration 
on the only network interface on the system and rebooted several times 
(I wasn't using the IPv6 networking stuff yet anyway).  I still get *no* 
udp4 or tcp4 entries in the rpcbind database.  The NFS service on this 
system is all IPv4 (it's a Linux NFS server).

How are these getting registered?

Steinar H. Gunderson wrote:
> On Mon, Jul 23, 2007 at 06:13:42PM -0400, Chuck Lever wrote:
>> It would help if we could take a look at a clean network trace of the bad 
>> and the good mount operations.
> 
> It was quite simple to test this myself. I started the kernel server on a
> machine, then shut down portmap. First I did:
> 
>   fugl:~> sudo mount -t nfs -o port=2049,mountport=901,nfsvers=3 192.168.0.101:/ /mnt
>   mount: mount to NFS server '192.168.0.101' failed: System Error: Connection refused.
> 
> The dump is attached as "default.dump". Then I did
> 
>   fugl:~> sudo mount -t nfs -o port=2049,mountport=901,nfsvers=3,udp 192.168.0.101:/ /mnt 
> 
> which is attached as "udp.dump".
> 
> Note that in default.dump, UDP is simply never tried at all. I believe that
> to be a bug.
> 
> /* Steinar */

--------------030108040902010901060804
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
version:2.1
end:vcard


--------------030108040902010901060804
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------030108040902010901060804
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030108040902010901060804--
