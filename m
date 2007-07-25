From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Status of mount.nfs
Date: Wed, 25 Jul 2007 15:35:20 -0400
Message-ID: <46A7A5F8.4040204@oracle.com>
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
Content-Type: multipart/mixed; boundary="------------070804010309080709020804"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDmiD-0005ae-4Q
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 12:40:00 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDmiF-0001KO-NH
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 12:40:01 -0700
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
--------------070804010309080709020804
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Steinar-

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

I'm looking at probe_nfsport() and probe_mntport() and I see that the 
portmapper call is avoided iff the protocol version, transport protocol, 
and the port number are all specified in advance.

So if you specify:

    -o mountport=650,port=2049

mount will still contact the server's portmapper to determine which 
transport protocols are available (and this breaks through a firewall 
that doesn't pass portmapper requests).  Only if you specify:

    -o tcp,mountport=650,port=2049

or

    -o udp,mountport=650,port=2049

then the portmapper calls are avoided entirely.  For some reason 
probe_bothports() sets the default NFS version to 3 but does not set a 
default transport protocol.

The transport protocols are probed differently for NFS and MNT: for MNT, 
UDP is probed first then TCP; for NFS, the opposite is true.  The mount 
command is supposed to try both transport protocol types both for NFS 
and MNT, but it appears that it is failing to try the other type if the 
first fails... I see this is also problematic for umount.nfs.

So yes, I think the logic is there, but it's broken.  I recall that the 
transport protocol probing logic was added recently.

--------------070804010309080709020804
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


--------------070804010309080709020804
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------070804010309080709020804
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070804010309080709020804--
