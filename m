From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: nfsd random drop
Date: Sun, 04 Apr 2004 21:09:39 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1081127379.2585.49.camel@lade.trondhjem.org>
References: <20040401102334.GC20772@suse.de>
	 <16496.42129.32286.429339@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BAIcX-00062M-88
	for nfs@lists.sourceforge.net; Sun, 04 Apr 2004 18:09:49 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BAIcW-0003GO-TJ
	for nfs@lists.sourceforge.net; Sun, 04 Apr 2004 18:09:48 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16496.42129.32286.429339@notabene.cse.unsw.edu.au>
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

On Sun, 2004-04-04 at 20:13, Neil Brown wrote:
> > As an alternative to hardcoding a formula based on the number of threads,
> > I could also make the max number of connections a sysctl.
> 
> Might be good, but I would only bother if a real need presents itself.

Some of the stuff we're discussing for NFSv4.1 might make this of
interest. Many people want to make use of the fact that IPSEC tunnels
offer secure point-to-point communications and that hardware
acceleration for this is pretty cheap. The so-called "CCM"
authentication model for RPCSEC_GSS makes use of this.

...we are talking about 2.7 development here (at the earliest), so
please don't take the above to be anything other than a FYI. I just
wanted to ensure that you are aware that the cost of reconnection might
well rise as we offload more and more to the socket layer.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
