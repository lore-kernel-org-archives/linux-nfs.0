From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 22/25] NFS: remove a no-longer-needed error	check
 in nfs_symlink()
Date: Thu, 10 Aug 2006 08:36:00 -0400
Message-ID: <44DB2830.1020705@redhat.com>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>	<20060809145943.3914.99861.stgit@picasso.dsl.sfldmi.ameritech.net>
	<1155175810.16378.1254.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Chuck Lever <chucklever@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GB9lq-0001xr-Kg
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 05:36:18 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GB9lo-0006a3-TV
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 05:36:19 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1155175810.16378.1254.camel@hole.melbourne.sgi.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Greg Banks wrote:
> On Thu, 2006-08-10 at 00:59, Chuck Lever wrote:
>   
>> In the early days of NFS, there was no duplicate reply cache on the server.
>> Thus retransmitted non-idempotent requests often found that the request had
>> already completed on the server.  To avoid passing an unanticipated return
>> code to unsuspecting applications, NFS clients would often shunt error
>> codes that implied the request had been retried but already completed.
>>
>> On modern NFS clients, it is safe to remove such checks.
>>     
>
> I'm not sure why you have such faith in servers' repcaches.  The Linux
> knfsd repcache as currently coded is fundamentally useless at modern
> call rates.  If this error case isn't needed anymore it's probably
> because we have fewer lost calls thanks to using TCP instead of UDP.
>   

It is true that the duplicate request cache in Linux and probably most other
systems, definitely including Solaris, is undersized.  However, most 
clients,
definitely including Solaris, do not contain special code.  They simply
depend upon the server to work correctly.

I suspect that it is the use of TCP which has minimized the number of
complaints about failing non-idempotent requests.  Given that TCP is 
becoming
more and more widespread, and that TCP is the only valid transport for 
NFSv4,
despite the Linux implementation, it seems to make sense to minimize the
overhead on the client.

       ps


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
