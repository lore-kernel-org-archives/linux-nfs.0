From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Status of mount.nfs
Date: Fri, 27 Jul 2007 13:07:14 -0400
Message-ID: <46AA2642.60505@RedHat.com>
References: <20070708191640.GA13962@uio.no>	
	<18065.43199.104020.412029@notabene.brown>	<20070715083114.GB4158@uio.no>	
	<18074.50730.591965.39211@notabene.brown>	<20070716092047.GA10353@uio.no>	
	<18075.17719.855332.259470@notabene.brown>	<20070722191733.GA31501@uio.no>	
	<46A52816.6050500@oracle.com>	<20070724172451.GA14026@uio.no>	
	<46A7A5F8.4040204@oracle.com> <46A897CD.50201@RedHat.com>	
	<46A96032.7080503@oracle.com> <46AA089E.50503@RedHat.com>	
	<1185551769.6586.28.camel@localhost> <46AA1A70.5010705@RedHat.com>
	<1185553679.6586.34.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IETHi-0003db-3v
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 10:07:29 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IETHj-0007tY-Fn
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 10:07:29 -0700
In-Reply-To: <1185553679.6586.34.camel@localhost>
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



Trond Myklebust wrote:
> On Fri, 2007-07-27 at 12:16 -0400, Steve Dickson wrote:
>> Trond Myklebust wrote:
>>> On Fri, 2007-07-27 at 11:00 -0400, Steve Dickson wrote:
>>>
>>>> That was the main reason for the ping. Since neither portmapper or
>>>> rpcbind ping their services before they hand out the ports, there
>>>> is really no way of telling where the server is up? So to avoid
>>>> the hang, we ping them... Sure its costly network wise, but
>>>> hanging during a boot because a server is not responding is
>>>> a bit more costly... imho...
>>> Right, but recent kernels both can and will ping the NFS service for
>>> you.
>> Good point... but that's just as costly (wrt network traffic) as
>> the mount command doing the pinging... plus the status of the
>> remote mountd is also needed.
> 
> The kernel ping is sent on the same connection to the server than the
> NFS client will use, so we don't waste any extra TCP ports.
> 
> I agree that you need to figure out the mountd parameters, but the right
> thing to do there is simply to try the command. The RPC return values
> will tell you if the service or version you tried isn't supported.
After how long of a wait? If all the timeouts are controllable then
I agrees, but if we have to wait undefined-able amount of time for
every RPC retransmit, then I think we should do a ping...

steved.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
