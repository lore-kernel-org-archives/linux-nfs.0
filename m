From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Status of mount.nfs
Date: Fri, 27 Jul 2007 15:37:45 -0400
Message-ID: <46AA4989.8040003@oracle.com>
References: <20070708191640.GA13962@uio.no>	<18065.43199.104020.412029@notabene.brown>	<20070715083114.GB4158@uio.no>	<18074.50730.591965.39211@notabene.brown>	<20070716092047.GA10353@uio.no>	<18075.17719.855332.259470@notabene.brown>	<20070722191733.GA31501@uio.no>
	<46A52816.6050500@oracle.com>	<20070724172451.GA14026@uio.no>
	<46A7A5F8.4040204@oracle.com> <46A897CD.50201@RedHat.com>
	<46A96032.7080503@oracle.com> <46AA089E.50503@RedHat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010107030801080805000809"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEWAX-0007Nk-PJ
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 13:12:23 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IEWAb-00076d-6w
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 13:12:17 -0700
In-Reply-To: <46AA089E.50503@RedHat.com>
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
--------------010107030801080805000809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Sorry about all the questions... and thanks for providing the history. 
The good news is that, now that [u]mount.nfs resides in nfs-utils, we 
can easily make this work a whole lot better.

Steve Dickson wrote:
> Chuck Lever wrote:
>>
>> And umount.nfs always uses TCP for the mountd request.  I have a patch 
>> that fixes that to behave more like mount.nfs does, which I will 
>> forward in the next day or two.
> thats a bug... umount should use the protocol the mount did...
> I thought I had fixed that... :-\

Nope... umount.nfs sets the transport protocol to TCP explicitly before 
doing the umount call.  Check out utils/mount/nfsumount.c:_nfsumount() .

>> I notice some problems if a share is mounted with TCP, but the server 
>> later disables TCP -- umount.nfs hiccups on that when it tries to 
>> umount using the same protocol as listed in /etc/mtab.  Perhaps 
>> relying on /etc/mtab for setting the umount protocol is unnecessary.
> I think I was using /proc/mounts...

umount.nfs uses getmntdirbackward(), which probes /etc/mtab, as far as I 
can tell.  One problem with this is that often the effective transport 
protocol isn't listed in /etc/mtab at all, if, say, the user requests 
TCP and the server supports only UDP.

I can't see why we need to refer back to either file to determine the 
transport protocol for a umount request.  Whatever transport mountd is 
advertising at the moment is what should be used, right?

[ Steve, since you have a different recollection of how all this mount 
stuff works, I wonder if Amit took an older version of mount when he 
split out the new mount.nfs helper... Can you verify this?  Maybe there 
are some fixes you made that need to be ported over. ]

>> We have three requests that need to be made:
>>
>> 1.  GETPORT -- I think this should UDP all the time unless proto=tcp 
>> is explicitly specified;
> Some people have asked that we first try UDP all the time... which
> I have resisted but it might make sense...

So far I've only found one reason to allow GETPORT over TCP, and that's 
to go through firewalls.  That's why I proposed allowing proto=tcp to 
override the default... I'm very interested to hear other use cases that 
might fail with UDP.

>> 2.  MNT -- likewise, UDP unless proto=tcp is specified or GETPORT says 
>> UDP is not supported;
>>
>> 3.  NFS -- this should be TCP all the time unless proto=udp is 
>> specified or GETPORT says TCP is not supported.
> What about rollbacks... meaning if tcp is not supported do we try udp?
> if v4 is not supported to we try v3 and the v2 or just fail the mount?

I think breaking back can be supported by grabbing all data about the 
interesting services from portmapper at the start of a mount request. 
That way mount.nfs can build the correct request based on the list of 
services advertised on the server, and the list of options from the 
mount command line, then make a single set of requests.  No retry logic 
is needed except for handling "bg".

>> Even better would be to use RPCB_DUMP instead of RPCB_GETPORT.  That 
>> way we only need a single rpcbind call for both protocols, and can get 
>> transport protocol information as well, and make an "informed" choice.
> Good point... but note, a while back I got a request to use GETPORT
> instead of DUMP because some Cisco router actually use the GETPORTs
> to punch holes in their firewalls.

Sigh.  ;-)

>> Also, can we get rid of the clnt_ping()?  If not, can we document why 
>> it is there?  It adds two extra round trips to the whole process.  If 
>> error reporting is the problem, maybe we can try the pings only if the 
>> kernel part of the mount process fails?
> How do we avoid hang down deep in RPC land (governed by
> uncontrollable timeout) when either mountd or nfsd  are not up?

I guess I don't see how a NULL RPC is different than sending a real 
request, when we're talking about a single MNT request from a user space 
application.  If the service is down, it fails either way.

> That was the main reason for the ping. Since neither portmapper or
> rpcbind ping their services before they hand out the ports, there
> is really no way of telling where the server is up? So to avoid
> the hang, we ping them... Sure its costly network wise, but
> hanging during a boot because a server is not responding is
> a bit more costly... imho...

My feeling is we should then fix the kernel to behave more reasonably. 
I recently changed the kernel's rpcbind client to use "intr" instead of 
"nointr" for its requests, for example.  Is it practical to track down 
the hangs and fix them?  Is it just the long time waiting for a failure, 
or do the mount processes actually get totally stuck?

--------------010107030801080805000809
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


--------------010107030801080805000809
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------010107030801080805000809
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------010107030801080805000809--
