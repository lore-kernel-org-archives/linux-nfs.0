From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Status of mount.nfs
Date: Thu, 26 Jul 2007 23:02:10 -0400
Message-ID: <46A96032.7080503@oracle.com>
References: <20070708191640.GA13962@uio.no>	<18065.43199.104020.412029@notabene.brown>	<20070715083114.GB4158@uio.no>	<18074.50730.591965.39211@notabene.brown>	<20070716092047.GA10353@uio.no>	<18075.17719.855332.259470@notabene.brown>	<20070722191733.GA31501@uio.no>
	<46A52816.6050500@oracle.com>	<20070724172451.GA14026@uio.no>
	<46A7A5F8.4040204@oracle.com> <46A897CD.50201@RedHat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020901030400000208000601"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEG7o-0007i6-6L
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 20:04:20 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IEG7q-0002nd-PM
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 20:04:24 -0700
In-Reply-To: <46A897CD.50201@RedHat.com>
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
--------------020901030400000208000601
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Steve Dickson wrote:
>> The transport protocols are probed differently for NFS and MNT: for 
>> MNT, UDP is probed first then TCP; for NFS, the opposite is true.  The 
>> mount command is supposed to try both transport protocol types both 
>> for NFS and MNT, but it appears that it is failing to try the other 
>> type if the first fails... I see this is also problematic for umount.nfs.
 >
> The idea here was to use UDP to probe for both rpc.mountd and the
> NFS server so as not to put (tcp) ports in TIMEWAIT, basically making
> them unavailable for the actual mount. That allowed many more tcp
> mounts to happen during autofs mount storms.

Right.  I don't see GETPORT using UDP as often as perhaps it should, 
though.  I need to go back and check it.

And umount.nfs always uses TCP for the mountd request.  I have a patch 
that fixes that to behave more like mount.nfs does, which I will forward 
in the next day or two.

I notice some problems if a share is mounted with TCP, but the server 
later disables TCP -- umount.nfs hiccups on that when it tries to umount 
using the same protocol as listed in /etc/mtab.  Perhaps relying on 
/etc/mtab for setting the umount protocol is unnecessary.

> Note: if the protocol was explicitly specified (i.e. proto=tcp) only
> that protocol was used during the probing and mounting. I have
> been asked to change that as well. Meaning if when proto=tcp is
> specified, they still want the udp probing to occur.

I would like to spell out exactly what behavior we want to solder into 
the community nfs-utils here, at least so I can approximate it with the 
string-ified mount implementation, but also because it seems to be quite 
heuristic and totally undocumented.  If we tune for a particular use 
case, it will break others, so we need to agree on a default that works 
for most cases.

(As part of this exercise it would also be lovely to assemble some nice 
regression test cases, but that may be too much to hope for ;-)

We have three requests that need to be made:

1.  GETPORT -- I think this should UDP all the time unless proto=tcp is 
explicitly specified;

2.  MNT -- likewise, UDP unless proto=tcp is specified or GETPORT says 
UDP is not supported;

3.  NFS -- this should be TCP all the time unless proto=udp is specified 
or GETPORT says TCP is not supported.

Even better would be to use RPCB_DUMP instead of RPCB_GETPORT.  That way 
we only need a single rpcbind call for both protocols, and can get 
transport protocol information as well, and make an "informed" choice.

Also, can we get rid of the clnt_ping()?  If not, can we document why it 
is there?  It adds two extra round trips to the whole process.  If error 
reporting is the problem, maybe we can try the pings only if the kernel 
part of the mount process fails?

--------------020901030400000208000601
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


--------------020901030400000208000601
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------020901030400000208000601
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020901030400000208000601--
