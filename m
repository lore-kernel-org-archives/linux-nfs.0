From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0 of 5] knfsd: miscellaneous performance-related
	fixes
Date: Tue, 15 Aug 2006 14:26:17 +1000
Message-ID: <17633.19689.468810.139040@cse.unsw.edu.au>
References: <1155009879.29877.229.camel@hole.melbourne.sgi.com>
	<17624.17621.428870.694339@cse.unsw.edu.au>
	<1155032558.29877.324.camel@hole.melbourne.sgi.com>
	<17624.29880.852610.256270@cse.unsw.edu.au>
	<1155097112.16378.46.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCqVZ-0002UD-7i
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 21:26:29 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GCqVX-0000Dv-2j
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 21:26:29 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Wednesday August 9
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

On Wednesday August 9, gnb@melbourne.sgi.com wrote:
> 
> Ok, for comment only...this patch won't apply for several reasons
> but hopefully you can get the gist of what I was trying to do.

Thanks.  It does give a good gist.

Trying to remember back to why I did the current stats the way I did,
and comparing with this, the big difference seems to be how
burst-behaviour is recognised.

By counting only idle and busy time, your stats would not be able to
distinguish between a load of (say) 10 requests each requiring 1ms
arriving at once, and those same ten arriving at 1ms intervals.

The first scenario can benefit from having 10 threads (lower
latency).  The second would not.
My stats might have been able to show that but reporting that some
times 10 threads were used.

Is that an issue?  I'm not certain, but I have a feeling that NFS
traffic is likely to be fairly bursty.  In the interests of minimising
latency I think we want to auto-configure to be ready to catch that
burst.
I imagine the ideal auto-configure regime would be to ramp up the
number of threads fairly quickly on demand, and then have them slowly
drop away when the demand isn't there.

The minimal stat I would want would be something like a count of the
number of times that 'svc_sock_enqueue' found that pool->sp_threads
was list_empty.  While that number is increasing we add threads at
some set rate (1 per second?).  When it stops increasing we drop
threads very slowly (1 per hour?).

Possibly the %idle number could be used to change the rate of
rise/decline.  But I'm not convinced that it can be used all by
itself.

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
