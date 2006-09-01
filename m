From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH 004 of 19] knfsd: lockd: introduce nsm_handle
Date: Fri, 1 Sep 2006 18:11:10 +0200
Message-ID: <20060901161110.GD29574@suse.de>
References: <20060901141639.27206.patches@notabene>
	<1060901043825.27464@suse.de> <1157125820.5632.44.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, Andrew Morton <akpm@osdl.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJBbv-0000GY-Mx
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 09:11:15 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJBbv-0003is-La
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 09:11:16 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1157125820.5632.44.camel@localhost>
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

On Fri, Sep 01, 2006 at 11:50:20AM -0400, Trond Myklebust wrote:
> >   With this patch applied, all nlm_hosts from the same address
> >   will share the same nsm_handle. A future patch will add sharing
> >   by name.
> 
> <boggle>
> Exactly why is it desirable to have > 1 nlm_host from the same address?
> </boggle>
> 
> If we can map several clients into a single nsm_handle, then surely it
> makes sense to map them into the same nlm_host too.

This is all related to the reasons for introducing NSM notification
by name in the first place.

On the client side, we may have mounted several volumes from a multi-homed
server, using different addresses, and you have several NLM client
handles, each with one of these addresses - and each in a different
nlm_host object.

Or you have an NFS server in a HA configuration, listening on a virtual
address. As the server fails over, the alias moves to the backup
machine.

Or (once we have IPv6) you may have a mix of v4 and v6 mounts.

Now when the server reboots, it will send you one or more SM_NOTIFY
messages. You do not know which addresses it will use. In the multihomed
case, you will get one SM_NOTIFY for each server address if the server
is a Linux box. Other server OSs will send you just one SM_NOTIFY,
and the sender address will be more or less random. In the HA case
described above, the sender address will not match the address
you used at all (since the UDP packet will have the interface's
primary IP address, not the alias).

This is the main motivation for introducing the nsm_handle, and this is
also the reason why there is potentially a 1-to-many relationship between
nsm_handles (representing a "host") and nlm_host, representing a tuple of
(NLM version, transport protocol, address).

Maybe we should rename nlm_host to something less confusing.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
