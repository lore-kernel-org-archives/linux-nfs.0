From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Re: [PATCH kNFSd 0 of 12] Introduction
Date: Tue, 8 Feb 2005 10:58:26 -0500
Message-ID: <20050208155826.GA26196@fieldses.org>
References: <20050208140033.24886.patches@notabene> <20050207192453.2a0a206b.akpm@osdl.org> <16904.12902.298401.1645@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>,
	"J . Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyXl5-0003Xq-3F
	for nfs@lists.sourceforge.net; Tue, 08 Feb 2005 07:58:35 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CyXl3-0003ov-Lf
	for nfs@lists.sourceforge.net; Tue, 08 Feb 2005 07:58:35 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16904.12902.298401.1645@cse.unsw.edu.au>
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

On Tue, Feb 08, 2005 at 02:30:46PM +1100, Neil Brown wrote:
> On Monday February 7, akpm@osdl.org wrote:
> > 
> > > The 6 from Bruce fix a real performance problem with locking.
> > 
> > That one depends on a bunch of the preceding ones, yes?
> 
> The set of six (numbered 3 to 8) should be independent of the rest.  I
> believe Bruce has done substantial testing on them.  I'll leave him to
> make a case or not.

Well, they've been waiting around longer than I'd like, but they're also
not completely trivial, so I hate to drop them in right before 2.6.11.

> > > The rest could be safely delayed if that seem appropriate, but they are 
> > > either quite trivial or (for the last one) quite well tested.
> > 
> > Maybe just the readdir and append patches for 2.6.11??
> 
> I'm OK with that if Bruce is.

OK.  If someone else cares passionately about getting the lockd callback
problem fixed as soon as possible, they can test and speak up.  They
seem fine to me, but I haven't gotten much feedback on them.

--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
