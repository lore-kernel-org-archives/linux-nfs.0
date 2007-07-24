From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Status of mount.nfs
Date: Tue, 24 Jul 2007 16:46:39 -0400
Message-ID: <46A6652F.8000707@oracle.com>
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
Content-Type: multipart/mixed; boundary="------------090700000608050301020503"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDRII-0002Vx-PE
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 13:47:47 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDRIM-0004UK-Eq
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 13:47:50 -0700
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
--------------090700000608050301020503
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



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

It looks like, in the UDP dump you sent, there is no attempt to contact 
the portmapper at all.  The mount request is the first thing in the 
dump, and the request goes right to the port specified on the command line.

The TCP case fails because mount.nfs is using the portmapper even though 
the user has specified the ports on the command line.  Could that be the 
root cause of the failure?

--------------090700000608050301020503
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


--------------090700000608050301020503
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------090700000608050301020503
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090700000608050301020503--
