From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,PATCH 7/15] knfsd: create RDMA transport in nfssvc
Date: Mon, 21 May 2007 17:04:40 +1000
Message-ID: <18001.17544.798341.277657@notabene.brown>
References: <1179510331.23385.120.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hq1x1-0003bG-Ap
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 00:05:03 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hq1x3-0000wn-HS
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 00:05:06 -0700
In-Reply-To: message from Tom Tucker on Friday May 18
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

On Friday May 18, tom@opengridcomputing.com wrote:
> Adds a call to the svc_makesock routine to create the RDMA transport. 
> I think this should somehow be linked to the transport switch and the 
> port mapper. 
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  fs/nfsd/nfssvc.c |   11 +++++++++++
>  1 files changed, 11 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index d7759ce..4a7982e 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -254,6 +254,17 @@ #ifdef CONFIG_NFSD_TCP
>  	if (error < 0)
>  		return error;
>  #endif
> +#ifdef CONFIG_NFSD_RDMA
> +	/* KLUDGE: The rpc.nfsd utility passes down the
> +	 * port number when it opens the nfsd file. We are
> +	 * going to ignore it here and force the RDMA port number
> +	 * to 2050. This will allow the TCP transport to coexist
> +	 * with the RDMA transport.
> +	 */
> +	error = svc_makesock(nfsd_serv, IPPROTO_MAX, 2050 /* port */, 0);
> +	if (error < 0)
> +		return error;
> +#endif
>  	return 0;
>  }
>  

As you say:  KLUDGE.

What is really going on here?  Why don't we have a protocol number,
and why can't we use port 2049?

I don't know a lot about RDMA (feel free to educate me) but it seems
that there is some connection to IP (is this IPoIB??) in that IP
address seem to be available for the end points.

Can you distinguish an RDMA connection from any other IP connection
simply based on the interface it gets routed through?

Can you actually get any sort of socket representing an RDMA
connection?  I appreciate that normal sendmsg/recvmsg calls on the
socket aren't going to work, but I'm dreaming that maybe a
socket-level 'accept' could establish the connection.  Then we look at
the connection, discover it is on a RDMA-capable device, and start
using the RDMA interface to move data around.
Does that make any sense at all, or am I totally off-beam?

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
