From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH kNFSd 32 of 54] nfsd4: fix callback cred refcnt
	leak
Date: Tue, 08 Mar 2005 01:16:55 -0500
Message-ID: <1110262615.11712.20.camel@lade.trondhjem.org>
References: <20050308165419.3842.patches@notabene>
	 <E1D8Xrg-00018r-Db@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Y1w-00031q-4E
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:17:20 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D8Y1v-0006LT-8J
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:17:19 -0800
To: NeilBrown <neilb@cse.unsw.edu.au>
In-Reply-To: <E1D8Xrg-00018r-Db@notabene.cse.unsw.edu.au>
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

ty den 08.03.2005 Klokka 17:06 (+1100) skreiv NeilBrown:
> 
> The rpc creds we look up in the callback code need puts.
> 

<cough> Error checking on the results of nfsd4_lookupcred()? </cough>

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
