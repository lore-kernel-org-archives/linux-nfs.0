From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 004 of 19] knfsd: lockd: introduce nsm_handle
Date: Fri, 01 Sep 2006 12:41:33 -0400
Message-ID: <1157128893.5632.74.camel@localhost>
References: <20060901141639.27206.patches@notabene>
	<1060901043825.27464@suse.de> <1157125820.5632.44.camel@localhost>
	<20060901161110.GD29574@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, Andrew Morton <akpm@osdl.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJC5T-00030w-KU
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 09:41:47 -0700
Received: from pat.uio.no ([129.240.10.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJC5T-0002Iy-QZ
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 09:41:48 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20060901161110.GD29574@suse.de>
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

On Fri, 2006-09-01 at 18:11 +0200, Olaf Kirch wrote:
> This is all related to the reasons for introducing NSM notification
> by name in the first place.
> 
> On the client side, we may have mounted several volumes from a multi-homed
> server, using different addresses, and you have several NLM client
> handles, each with one of these addresses - and each in a different
> nlm_host object.
> 
> Or you have an NFS server in a HA configuration, listening on a virtual
> address. As the server fails over, the alias moves to the backup
> machine.
> 
> Or (once we have IPv6) you may have a mix of v4 and v6 mounts.
> 
> Now when the server reboots, it will send you one or more SM_NOTIFY
> messages. You do not know which addresses it will use. In the multihomed
> case, you will get one SM_NOTIFY for each server address if the server
> is a Linux box. Other server OSs will send you just one SM_NOTIFY,
> and the sender address will be more or less random. In the HA case
> described above, the sender address will not match the address
> you used at all (since the UDP packet will have the interface's
> primary IP address, not the alias).
> 
> This is the main motivation for introducing the nsm_handle, and this is
> also the reason why there is potentially a 1-to-many relationship between
> nsm_handles (representing a "host") and nlm_host, representing a tuple of
> (NLM version, transport protocol, address).
> 
> Maybe we should rename nlm_host to something less confusing.

The local statd process is supposed to decode the notification from the
remote client/server, and then notify the kernel. It already sends that
notification on a per-nlm_host basis (i.e. it the call down to the
kernel contains the <address,version,transport protocol>.

If we need to mark more than one <address,version,transport protocol>
tuple as rebooting when we get a notification from the remote
client/server, then why not fix statd so that it does so. Why perform
these extra mappings in the kernel, which doesn't have the benefit of
reverse DNS lookups etc to help it out?

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
