From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH] 3/3 - remove rpc_call interface
Date: Wed, 31 Mar 2004 09:06:00 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07BF1@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Olaf Kirch" <okir@suse.de>, "Steve Dickson" <SteveD@redhat.com>,
        "Jeremy McNicoll" <jeremy@mcnicoll.ca>,
        "Patrick Mochel" <mochel@digitalimplant.org>,
        <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B8jAO-0000tE-8W
	for nfs@lists.sourceforge.net; Wed, 31 Mar 2004 09:06:16 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B8jAM-0006Pa-Qo
	for nfs@lists.sourceforge.net; Wed, 31 Mar 2004 09:06:14 -0800
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

> > In order to expose the new RPC metrics facility to all NFS=20
> operations,=20
> > we need to get rid of the rpc_call wrapper in favor of the=20
> interfaces=20
> > (like rpc_call_sync) that expose the rpc_message structure=20
> directly to=20
> > the caller.
>=20
> Please could you review those "inline" conversions? I'm at=20
> all not convinced that something like nfs3_async_handle() is=20
> particularly useful to inline (particularly not since it is=20
> used in every function in that file).

i inlined nfs3_rpc_wrapper because it is used in every NFSv3
proc.  it removes a calling sequence and stack frame from
the path.

the other two inlines appear on the read/write/commit path,
but this path, being synchronous, is probably not as hot as
the async read/write/commit path.  so you are welcome to
remove these if you have no other complaint about this patch.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
