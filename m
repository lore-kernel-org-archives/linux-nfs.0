From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Status of mount.nfs
Date: Sat, 28 Jul 2007 09:20:16 -0400
Message-ID: <46AB4290.4090408@RedHat.com>
References: <20070708191640.GA13962@uio.no>	<18065.43199.104020.412029@notabene.brown>	<20070715083114.GB4158@uio.no>	<18074.50730.591965.39211@notabene.brown>	<20070716092047.GA10353@uio.no>	<18075.17719.855332.259470@notabene.brown>	<20070722191733.GA31501@uio.no>
	<46A52816.6050500@oracle.com>	<20070724172451.GA14026@uio.no>
	<46A7A5F8.4040204@oracle.com> <46A897CD.50201@RedHat.com>
	<46A96032.7080503@oracle.com> <46AA089E.50503@RedHat.com>
	<46AA4989.8040003@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEmER-0005uv-1b
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 06:21:19 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEmEU-0003gy-Jp
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 06:21:23 -0700
In-Reply-To: <46AA4989.8040003@oracle.com>
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

Chuck Lever wrote:
> Sorry about all the questions... and thanks for providing the history. 
> The good news is that, now that [u]mount.nfs resides in nfs-utils, we 
> can easily make this work a whole lot better.
> 
> Steve Dickson wrote:
>> Chuck Lever wrote:
>>>
>>> And umount.nfs always uses TCP for the mountd request.  I have a 
>>> patch that fixes that to behave more like mount.nfs does, which I 
>>> will forward in the next day or two.
>> thats a bug... umount should use the protocol the mount did...
>> I thought I had fixed that... :-\
> 
> Nope... umount.nfs sets the transport protocol to TCP explicitly before 
> doing the umount call.  Check out utils/mount/nfsumount.c:_nfsumount() .
> 
>>> I notice some problems if a share is mounted with TCP, but the server 
>>> later disables TCP -- umount.nfs hiccups on that when it tries to 
>>> umount using the same protocol as listed in /etc/mtab.  Perhaps 
>>> relying on /etc/mtab for setting the umount protocol is unnecessary.
>> I think I was using /proc/mounts...
> 
> umount.nfs uses getmntdirbackward(), which probes /etc/mtab, as far as I 
> can tell.  One problem with this is that often the effective transport 
> protocol isn't listed in /etc/mtab at all, if, say, the user requests 
> TCP and the server supports only UDP.
This got lost in the translation... In older mount code (i.e. the one
in utils-linux) /proc/mounts is used which is a much simpler way
of dealing with this... imho..

> 
> I can't see why we need to refer back to either file to determine the 
> transport protocol for a umount request.  Whatever transport mountd is 
> advertising at the moment is what should be used, right?
Well for firewall reasons you generally want to use the protocol
that the mount used...

> 
> [ Steve, since you have a different recollection of how all this mount 
> stuff works, I wonder if Amit took an older version of mount when he 
> split out the new mount.nfs helper... Can you verify this?  Maybe there 
> are some fixes you made that need to be ported over. ]
No... I pretty sure I had Amit use the latest and greatest...
I just think there was some decisions made or liberties taken
without a complete understand of what the ramification were...

> 
>>> 2.  MNT -- likewise, UDP unless proto=tcp is specified or GETPORT 
>>> says UDP is not supported;
>>>
>>> 3.  NFS -- this should be TCP all the time unless proto=udp is 
>>> specified or GETPORT says TCP is not supported.
>> What about rollbacks... meaning if tcp is not supported do we try udp?
>> if v4 is not supported to we try v3 and the v2 or just fail the mount?
> 
> I think breaking back can be supported by grabbing all data about the 
> interesting services from portmapper at the start of a mount request. 
> That way mount.nfs can build the correct request based on the list of 
> services advertised on the server, and the list of options from the 
> mount command line, then make a single set of requests.  No retry logic 
> is needed except for handling "bg".
right...


>>> Also, can we get rid of the clnt_ping()?  If not, can we document why 
>>> it is there?  It adds two extra round trips to the whole process.  If 
>>> error reporting is the problem, maybe we can try the pings only if 
>>> the kernel part of the mount process fails?
>> How do we avoid hang down deep in RPC land (governed by
>> uncontrollable timeout) when either mountd or nfsd  are not up?
> 
> I guess I don't see how a NULL RPC is different than sending a real 
> request, when we're talking about a single MNT request from a user space 
> application.  If the service is down, it fails either way.
As long as the request does not get caught up in some unreasonably
long timeout in the RPC code... there is no difference... Waiting
60sec for each retry or to find out some service is down would
not be a good thing when a machine is coming up...

> 
>> That was the main reason for the ping. Since neither portmapper or
>> rpcbind ping their services before they hand out the ports, there
>> is really no way of telling where the server is up? So to avoid
>> the hang, we ping them... Sure its costly network wise, but
>> hanging during a boot because a server is not responding is
>> a bit more costly... imho...
> 
> My feeling is we should then fix the kernel to behave more reasonably. I 
> recently changed the kernel's rpcbind client to use "intr" instead of 
> "nointr" for its requests, for example.  Is it practical to track down 
> the hangs and fix them?  
In the kernel yes, in glibc no because that code will not
change, period!

> Is it just the long time waiting for a failure, 
> or do the mount processes actually get totally stuck?
Its a long time wait that can not be controlled...

steved.




-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
