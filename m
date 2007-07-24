From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Status of mount.nfs
Date: Tue, 24 Jul 2007 17:18:49 -0400
Message-ID: <46A66CB9.9050805@oracle.com>
References: <20070708191640.GA13962@uio.no>	
	<18065.43199.104020.412029@notabene.brown>
	<20070715083114.GB4158@uio.no>	
	<18074.50730.591965.39211@notabene.brown>
	<20070716092047.GA10353@uio.no>	
	<18075.17719.855332.259470@notabene.brown>
	<20070722191733.GA31501@uio.no>	 <46A52816.6050500@oracle.com>
	<20070724172451.GA14026@uio.no>	 <46A6652F.8000707@oracle.com>
	<1185311449.6586.69.camel@localhost>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040909070904020206050905"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDRno-0006Hy-SV
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 14:20:21 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDRnr-0007o8-G5
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 14:20:24 -0700
In-Reply-To: <1185311449.6586.69.camel@localhost>
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
--------------040909070904020206050905
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



Trond Myklebust wrote:
> On Tue, 2007-07-24 at 16:46 -0400, Chuck Lever wrote:
> 
>> The TCP case fails because mount.nfs is using the portmapper even though 
>> the user has specified the ports on the command line.  Could that be the 
>> root cause of the failure?
> 
> If the user specifies a port, then there is no real good reason to use
> the portmapper:

Exactly.

>       * For the case of the mount protocol, we should just try an RPC
>         call and then look at the returned RPC error values to figure
>         out which versions of the protocol are supported if it fails (or
>         alternatively, fall back to UDP if the TCP connection fails).
>       * If the mount call has succeeded and we have a port for the NFS
>         server, we should probably just try the mount call for a
>         sufficiently recent kernel, then look at the returned error
>         codes. For older kernels (pre 2.6.13?) which don't return decent
>         error values, then ping first in userland and look at the RPC
>         return values. Retry with UDP if TCP doesn't work...

I'm wondering how much of this is already implemented in mount.nfs, but 
is just broken.  I'm reviewing the code now.

I cleaned this up a little with recent patches so it should be easier to 
figure out what's going wrong.

--------------040909070904020206050905
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


--------------040909070904020206050905
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------040909070904020206050905
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040909070904020206050905--
