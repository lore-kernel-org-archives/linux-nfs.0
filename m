From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Status of mount.nfs
Date: Sat, 28 Jul 2007 17:00:15 -0400
Message-ID: <46ABAE5F.1000208@oracle.com>
References: <20070708191640.GA13962@uio.no>	<18065.43199.104020.412029@notabene.brown>	<20070715083114.GB4158@uio.no>	<18074.50730.591965.39211@notabene.brown>	<20070716092047.GA10353@uio.no>	<18075.17719.855332.259470@notabene.brown>	<20070722191733.GA31501@uio.no>
	<46A52816.6050500@oracle.com>	<20070724172451.GA14026@uio.no>
	<46A7A5F8.4040204@oracle.com> <46A897CD.50201@RedHat.com>
	<46A96032.7080503@oracle.com> <46AA089E.50503@RedHat.com>
	<46AA4989.8040003@oracle.com> <46AB4290.4090408@RedHat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030606060203090207030304"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEtQu-0004KP-JL
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:02:40 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IEtQy-0006ck-11
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:02:44 -0700
In-Reply-To: <46AB4290.4090408@RedHat.com>
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
--------------030606060203090207030304
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Steve Dickson wrote:
> Chuck Lever wrote:
>> Steve Dickson wrote:
>>> Chuck Lever wrote:
>>>>
>>>> And umount.nfs always uses TCP for the mountd request.  I have a 
>>>> patch that fixes that to behave more like mount.nfs does, which I 
>>>> will forward in the next day or two.
>>> thats a bug... umount should use the protocol the mount did...
>>> I thought I had fixed that... :-\
>>
>> Nope... umount.nfs sets the transport protocol to TCP explicitly 
>> before doing the umount call.  Check out 
>> utils/mount/nfsumount.c:_nfsumount() .
>>
>>>> I notice some problems if a share is mounted with TCP, but the 
>>>> server later disables TCP -- umount.nfs hiccups on that when it 
>>>> tries to umount using the same protocol as listed in /etc/mtab.  
>>>> Perhaps relying on /etc/mtab for setting the umount protocol is 
>>>> unnecessary.
>>> I think I was using /proc/mounts...
>>
>> umount.nfs uses getmntdirbackward(), which probes /etc/mtab, as far as 
>> I can tell.  One problem with this is that often the effective 
>> transport protocol isn't listed in /etc/mtab at all, if, say, the user 
>> requests TCP and the server supports only UDP.
> This got lost in the translation... In older mount code (i.e. the one
> in utils-linux) /proc/mounts is used which is a much simpler way
> of dealing with this... imho..

Miklos seems intent on eliminating /etc/mtab anyway...

>> I can't see why we need to refer back to either file to determine the 
>> transport protocol for a umount request.  Whatever transport mountd is 
>> advertising at the moment is what should be used, right?
> Well for firewall reasons you generally want to use the protocol
> that the mount used...

That could have been a very long time ago, even months, and the server 
settings may have changed.  Thus sending what mount used seems 
inherently unreliable.  The race window is enormous!

>> [ Steve, since you have a different recollection of how all this mount 
>> stuff works, I wonder if Amit took an older version of mount when he 
>> split out the new mount.nfs helper... Can you verify this?  Maybe 
>> there are some fixes you made that need to be ported over. ]
> No... I pretty sure I had Amit use the latest and greatest...
> I just think there was some decisions made or liberties taken
> without a complete understand of what the ramification were...

Thanks for checking on this.  I worried we may have missed some 
important bug fixes.

>>>> Also, can we get rid of the clnt_ping()?  If not, can we document 
>>>> why it is there?  It adds two extra round trips to the whole 
>>>> process.  If error reporting is the problem, maybe we can try the 
>>>> pings only if the kernel part of the mount process fails?
>>> How do we avoid hang down deep in RPC land (governed by
>>> uncontrollable timeout) when either mountd or nfsd  are not up?
>>
>> I guess I don't see how a NULL RPC is different than sending a real 
>> request, when we're talking about a single MNT request from a user 
>> space application.  If the service is down, it fails either way.
> As long as the request does not get caught up in some unreasonably
> long timeout in the RPC code... there is no difference... Waiting
> 60sec for each retry or to find out some service is down would
> not be a good thing when a machine is coming up...
> 
>>
>>> That was the main reason for the ping. Since neither portmapper or
>>> rpcbind ping their services before they hand out the ports, there
>>> is really no way of telling where the server is up? So to avoid
>>> the hang, we ping them... Sure its costly network wise, but
>>> hanging during a boot because a server is not responding is
>>> a bit more costly... imho...
>>
>> My feeling is we should then fix the kernel to behave more reasonably. 
>> I recently changed the kernel's rpcbind client to use "intr" instead 
>> of "nointr" for its requests, for example.  Is it practical to track 
>> down the hangs and fix them?  
> In the kernel yes, in glibc no because that code will not
> change, period!

Well, if libtirpc is added to nfs-utils, the mount command could use 
that instead.  We'd be able to fix any bugs in libtirpc quite easily. 
That seems like an excellent way to address every problem with glibc's 
RPC implementation, and immediately have a "simple" use case for testing 
libtirpc (or whatever we have to replace the RPC functionality in glibc).

>> Is it just the long time waiting for a failure, or do the mount 
>> processes actually get totally stuck?
> Its a long time wait that can not be controlled...

Ok.

--------------030606060203090207030304
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


--------------030606060203090207030304
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------030606060203090207030304
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030606060203090207030304--
