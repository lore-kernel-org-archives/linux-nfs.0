From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: need info on IPv6 support for NFS in RHEL and	SLES	distros
Date: Wed, 29 Aug 2007 17:18:07 -0400
Message-ID: <1188422287.6580.143.camel@heimdal.trondhjem.org>
References: <3DFE68BCB5D6994994AA6CB1EC581EA30411E61E@qcaexc02.asiapacific.cpqcorp.net>
	<46D59C8F.8070508@oracle.com>  <20070829210828.GA21877@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQUvU-0007jB-Qe
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 14:18:13 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQUvX-0005ir-PD
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 14:18:17 -0700
In-Reply-To: <20070829210828.GA21877@uio.no>
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

On Wed, 2007-08-29 at 23:08 +0200, Steinar H. Gunderson wrote:
> On Wed, Aug 29, 2007 at 12:19:27PM -0400, Chuck Lever wrote:
> > No Linux distribution contains IPv6 support for NFS right now.  The 
> > implementation is still being developed.
> 
> Speaking of which, what's missing now? I see text-based mounts, client-side
> IPv6 RPC and server-side transport switch (of which the first two are already
> in mainline, and the last seems to be on its way) -- my impression was that
> these are all important building blocks. I guess nfs-utils will also need
> some patching, and an IPv6 transport will be needed for plugging into the
> server side transport switch, but after that?
> 
> /* Steinar */

The client very much needs server support to be present in order to
function correctly. NFSv2/v3 NLM locking callbacks and NFSv4 delegations
will fail to work without server side IPv6 support.

We also need to convert rpc.statd and the kernel rpc.statd upcall.

Finally, we need to convert rpc.gssd/rpc.svcgssd and rpc.idmapd to work
with IPv6.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
