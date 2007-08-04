From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 05/10] mount.nfs: Shorter timeout for TCP connects
Date: Fri, 03 Aug 2007 20:29:30 -0400
Message-ID: <46B3C86A.9010804@oracle.com>
References: <20070803172349.3357.55907.stgit@monet.1015granger.net>
	<18099.43580.95942.585732@notabene.brown>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050106080007080500090005"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IH7XN-0004gD-AC
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 17:30:33 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IH7XR-0008MV-3Q
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 17:30:37 -0700
In-Reply-To: <18099.43580.95942.585732@notabene.brown>
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
--------------050106080007080500090005
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> On Friday August 3, chuck.lever@oracle.com wrote:
>> The standard TCP connect timeout on Linux is 75 seconds, which can be
>> too long in some cases.  The timeout itself can be altered on a system-wide
>> basis, but we'd like mount to have it's own connect timeout that's tunable,
>> and defaults to a shorter value.
> 
> 75?  "man 7 tcp" suggest about 180, and a simple telnet test confirmed this.
> The man page also suggests that this is due to 5 SYN packets being
> sent, but I count 6 and intervals of 
> 
>  3, 6, 12, 24, 48, then 96 seconds until it gives up
> 
> This makes a total of 189.

The traditional TCP connect timeout is 75 seconds on *BSD, and my simple 
test gave about 75 seconds on my distro.  I'm not surprised that it varies.

Usually some consideration is given to the expected maximum possible 
round-trip.  Too short a connect timeout can prevent successful 
connections to distant hosts.

> You can change The number of SYN retries with the TCP_SYNCNT socket
> option, but it is probably just as easy to use async connect and
> select as you do.

connect/select is recommended in Steven's "Unix Networking Programming, 
Vol I".  I think it is recommended because this is the most portable way 
to time out a TCP connect.

And, unlike SYNs, "seconds" directly tunes what a user will experience.

> The sensible timeouts would seem to be (just more than)
>  3, 9, 21, 45, 93
> seconds.  You have chosen 10, 20, 30
> 
> Any reason for that?

I don't really think it's necessary to cleave closely to the SYN behavior.

> I'm having trouble justifying why the portmap,
> the mountd and the 'ping' calls should have different timeouts.

I did this mostly to demonstrate that it could be done.  I'm not 
strongly attached to the idea of having different timeouts for different 
purposes.

> I would probably go for 12 seconds each.  This allows 2 SYN requests,
> and 3 seconds for a response to get back.  If that is too short, then
> maybe 25 seconds.

GETPORT over UDP uses 3 second retries, and times out after 20 seconds. 
  The 20 second RPC timeout is determined by the TIMEOUT macro, and it 
might be reasonable to make the equivalent TCP timeouts roughly the same.

> Choosing timeouts is a very imprecise science, but I'd like to have at
> least some understanding of what we pick the numbers we do.

Adding some documentation in comments near the TIMEOUT definitions would 
probably be useful for doing future tweaks.

--------------050106080007080500090005
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


--------------050106080007080500090005
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------050106080007080500090005
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------050106080007080500090005--
