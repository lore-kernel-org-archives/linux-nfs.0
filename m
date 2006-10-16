From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 7/8] knfsd: repcache: faster hash chain probe
Date: Mon, 16 Oct 2006 12:34:54 +1000
Message-ID: <17714.61390.225292.840864@cse.unsw.edu.au>
References: <1160566178.8530.19.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZIJh-0008GQ-Gw
	for nfs@lists.sourceforge.net; Sun, 15 Oct 2006 19:35:01 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZIJh-0005Zm-R3
	for nfs@lists.sourceforge.net; Sun, 15 Oct 2006 19:35:02 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Wednesday October 11
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

On Wednesday October 11, gnb@melbourne.sgi.com wrote:
> knfsd: Squeeze some small performance improvements out of the duplicate
> request cache's lookup function by reducing the number of instructions
> to compare each entry during hash chain probing.
> 
> Comparisons such as the RPC protocol number and version which are going
> to be the same for almost all entries are now done last.  Comparisons
> such as xid and client IP address which are more likely to differ
> between entries are done first.  The client IP address comparison
> is fixed not to compare 8 bytes of zeroes and to do comparisons as
> 32b quantities.  Finally, a 32b addition for the timestamp is removed
> from the loop by taking advantage of a loop invariant.

And yet:

> +static inline int
> +compare_sockaddr_in(const struct sockaddr_in *sina, const struct sockaddr_in *sinb)
> +{
> +	return ((*(u32 *)&sina->sin_family == *(u32 *)&sinb->sin_family) &&
> +		(sina->sin_addr.s_addr == sinb->sin_addr.s_addr));
> +}
> +

You compare family and port before address.... I suspect you would
find the port is the same between clients more often than the address.

Is there a reason?

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
