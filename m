From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [Fwd: Re: rpc.mountd problems]
Date: Thu, 26 Jun 2003 09:35:59 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16122.12767.103726.330411@gargle.gargle.HOWL>
References: <1056396464.31466.25.camel@mosix>
	<16119.28036.546786.260128@gargle.gargle.HOWL>
	<1056562429.3941.49.camel@mosix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19VJoF-0000HD-00
	for <nfs@lists.sourceforge.net>; Wed, 25 Jun 2003 16:36:15 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <mschilli@vss.fsi.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Thu, 26 Jun 2003 09:36:00 +1000
To: Matt Schillinger <mschilli@vss.fsi.com>
In-Reply-To: message from Matt Schillinger on  June 25
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On  June 25, mschilli@vss.fsi.com wrote:
> 
> But it WAS mounted prior to exportfs.. hmm.. could /var/lib/nfs/rmtab
> entries existing prior to exportfs cause a problem?

No. They are only noticed by exportfs, not before.

> 
> The config is like this:
> 
> Three gigabit interfaces on three separate subnets. 
> 	in dns, there is only the name thor.vss.fsi.com that corresponds to the
> ips... But another note, is that those ips are bound to ip aliases
> (eth0:0, etc).
> 	The actual interface ip addresses all have names associated (thor-200,
> thor-400, thor-20).
> 
> 	Could this cause a problem??
> 
> 	One last shot in the dark is that 2 of our Solaris 8 boxes, that act as
> nfs clients, are ALSO multi homed, on the same subnets.. Might that
> interact badly?

There is a bug in glibc (fixed in the last couple of months) which
causes the reply to a mount request to be forced out the same
interface that the request came in.
Depending on how your routes are set up, it could well be that that
interface doesn't have a route back to the client.  This would cause
stalls when mounting a filesystem.

I worked around this by putting default routes on all the interfaces on some
multi-homed hosts.

However this doesn't explain your "exportfs -auv" problems.  I'm still
suspicious of your mount order.  The filesystem is *definately*
mounted *before* mountd or exportfs are run???

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
