From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH kNFSd 0 of 54] Introduction
Date: Tue, 8 Mar 2005 00:01:44 -0800
Message-ID: <20050308000144.6599431b.akpm@osdl.org>
References: <20050308165419.3842.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8ZfU-00079e-F2
	for nfs@lists.sourceforge.net; Tue, 08 Mar 2005 00:02:16 -0800
Received: from fire.osdl.org ([65.172.181.4] helo=smtp.osdl.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D8ZfS-00075N-Vb
	for nfs@lists.sourceforge.net; Tue, 08 Mar 2005 00:02:16 -0800
To: NeilBrown <neilb@cse.unsw.edu.au>
In-Reply-To: <20050308165419.3842.patches@notabene>
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

NeilBrown <neilb@cse.unsw.edu.au> wrote:
>
>  54 (!!) patches for knfsd. Mostly nfsv4 related from Bruce Fields and co.

Fun, I'm up to 944 patches.

I assume that nfsv4 is still "experimental", so we can scoot these in
fairly promptly?

There were a few rejects against things in Linus's tree now, or something. 
I fixed them up.  I'll try to do another -mm 24 hours hence - please check
that everything landed OK.

I can tell you right now that the compiler will get huffy about this:



-void static inline nfs4_state_init(void){}
+int static inline nfs4_state_init(void){}

I'll stick a `return 0;' in there...


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
