From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] 3/3 - remove rpc_call interface
Date: Wed, 31 Mar 2004 11:56:48 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1080752208.4194.38.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435DE33@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Olaf Kirch <okir@suse.de>, Steve Dickson <SteveD@redhat.com>, Jeremy McNicoll <jeremy@mcnicoll.ca>, Patrick Mochel <mochel@digitalimplant.org>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B8j1K-0006IU-SH
	for nfs@lists.sourceforge.net; Wed, 31 Mar 2004 08:56:54 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B8j1K-00037i-Oc
	for nfs@lists.sourceforge.net; Wed, 31 Mar 2004 08:56:54 -0800
To: Charles Lever <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435DE33@lavender-fe.eng.netapp.com>
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

On Wed, 2004-03-31 at 11:34, Lever, Charles wrote:
> In order to expose the new RPC metrics facility to all NFS operations,
> we need to get rid of the rpc_call wrapper in favor of the interfaces
> (like rpc_call_sync) that expose the rpc_message structure directly to
> the caller.
> 
> This patch does that.

Please could you review those "inline" conversions? I'm at all not
convinced that something like nfs3_async_handle() is particularly useful
to inline (particularly not since it is used in every function in that
file).

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
