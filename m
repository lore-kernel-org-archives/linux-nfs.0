From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: FC3 <-> Solaris 10, NFSv4 interop?
Date: Fri, 25 Feb 2005 16:59:53 -0800
Message-ID: <1109379593.17237.20.camel@lade.trondhjem.org>
References: <1109296629.5897.574.camel@seki.nac.uci.edu>
	 <200502251706.24315.vincent.roqueta@ext.bull.net>
	 <1109355225.5897.580.camel@seki.nac.uci.edu>
	 <20050225184615.GD23369@fieldses.org>
	 <1109376963.30943.7.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Vincent Roqueta <vincent.roqueta@ext.bull.net>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4qJf-0006vk-7g
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 17:00:19 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D4qJd-0002ct-Hm
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 17:00:19 -0800
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1109376963.30943.7.camel@seki.nac.uci.edu>
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

fr den 25.02.2005 Klokka 16:16 (-0800) skreiv Dan Stromberg:

> How hard would it be to set up one of the following on FC3 and Solaris
> 10?
> 
> LIPKEY (based on SPKM-3)
> SPKM-3

Very hard. They don't support it... ;-)

> If we just continue using AUTH_UNIX with NFSv4, are we still relying on
> reserved ports?

Yes.

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
