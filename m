From: Brian Kerr <kerrboy@gmail.com>
Subject: Re: NFS reliability in Enterprise Environment
Date: Fri, 3 Feb 2006 11:36:45 -0500
Message-ID: <b83c9e30602030836v7e7360daj615d653496b4462d@mail.gmail.com>
References: <5573EF758F632B43A91FE1A01B6AC3D401B77D6B@exch3-dc-aus.northamerica.corporate-domain.net>
	 <EXCHG2003ZKpjE5aHaZ00001176@EXCHG2003.microtech-ks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Sullivan <david.sullivan@activant.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F53vY-0004nv-Nh
	for nfs@lists.sourceforge.net; Fri, 03 Feb 2006 08:36:52 -0800
Received: from xproxy.gmail.com ([66.249.82.193])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F53vT-00076E-Qi
	for nfs@lists.sourceforge.net; Fri, 03 Feb 2006 08:36:49 -0800
Received: by xproxy.gmail.com with SMTP id s6so458442wxc
        for <nfs@lists.sourceforge.net>; Fri, 03 Feb 2006 08:36:45 -0800 (PST)
To: Roger Heflin <rheflin@atipa.com>
In-Reply-To: <EXCHG2003ZKpjE5aHaZ00001176@EXCHG2003.microtech-ks.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On 2/2/06, Roger Heflin <rheflin@atipa.com> wrote:

...
> Just to note, since usually the underlying disk is the
> bottleneck, having 2 servers hit the same disk hardware does
> not really help.

Sure, but I'm not looking for SAN speeds on a solution using this
technology.  Rather I would like to see a relatively
fast,scalable,highly available,dense storage solution using NFS
technology.

Obviously you can do this with a Netapp or countless other solutions -
but we are looking at a Nexsan Satabeast(22TB in 4U) for it's
unmatched density and price.  Adding a couple linux servers running
GFS into the mix to make the data available to hundreds of machines.

> If you want things to scale, I would find a way to logically
> separate things.

This is the problem we have now.  We have over 15 different "storage
servers" with locally attached ata raid arrays.  Getting an
application to scale properly when you have 15+ different NFS paths is
not going to work in the long run, it isn't working now.

> On the speed note, with cheap arrays and cheap NFS servers (basic
> dual cpu machines) I can serve single stream writes at
> 95MByte/second, and reads at 115MByte/second, both of these are
> sustained rates (10x+ times the amount of possible cache anywhere
> in the setup), and this is over a single ethernet, to a single
> 14 disk array.

Yes these work great, but when you have 15 or more it gets
unmanageable, hence the switch to GFS.  A lot of the data on these
servers is simply archived away anyway.

> I would personally stay away from the shared filesystems, the
> trade off required to make them share between machines probably
> cut the speed enough to make it not worth it.

I will let you know once we implement it.  A 22TB array connected to
only two or three servers shouldn't hit a bottleneck.  You have to use
3-4 ports off the controllers to maximize bandwidth from the array
anyway.

> With single arrays (such as the above mentioned test), the total
> rate gets lower when two machines (or two streams from the same
> machine) access the same array (physical disks) as the disks
> start to seek around.
>
> When I last did it, I broke things up into small physical units and
> spread them over many cheap machines (1-2TB, this was to allow
> us to get very large IO rates, ie 500MBytes/second+, and this was
> 3+ years ago), this also allow us to have a fully tested cold
> spare that could replace any broken server machine
> within 1 hour.    This was a better thing over the large Suns we
> had previously as we only had 2 of them, and really could not afford
> to keep a 100k machine as a cold spare.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
