From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: /proc/fs/nfs/exports Broken
Date: Mon, 7 Mar 2005 10:24:36 +1100
Message-ID: <16939.37172.344792.638999@cse.unsw.edu.au>
References: <20050306164036.GA21468@gam3.net>
	<20050306173628.GA3918@gam3.net>
	<20050306203043.GA5529@gam3.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D857E-0004a5-8s
	for nfs@lists.sourceforge.net; Sun, 06 Mar 2005 15:24:52 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D857D-0000pj-K4
	for nfs@lists.sourceforge.net; Sun, 06 Mar 2005 15:24:52 -0800
To: "G. Allen Morris III" <gam3-nfs@gam3.net>
In-Reply-To: message from G. Allen Morris III on Sunday March 6
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

On Sunday March 6, gam3-nfs@gam3.net wrote:
> On Sun, Mar 06, 2005 at 12:36:28PM -0500, G. Allen Morris III wrote:
> > Neil,
> > 
> > Neil the net rcp export cache should not be used directly for
> > the /proc/nfs/exports output.
> > 
> > I am pretty sure that all that needs to be done is to only display
> > the rightmost element of the domain (client = strrchr(domain, ',')+1).
> > 
> > I have a patch, but plan to clean it up before I send it to you.
> > 
> > I just wanted to request comments on this problem for now.
> 
> I can see that I am very wrong about how simple this is. I think that
> extra data or code is needed to solve this problem.

You haven't been very clear about what the problem is, but I think I
can guess.

If a particular client (identified by IP address) maps to several
different identifiers that are in /etc/exports
e.g.  '*' and 'W.X.Y.Z' and 'test-host.my.domain' and '@my-netgroup'
then the effective name for that client as listed in /etc/exports will
be the combination of all the identifiers, separated by commas.
In this example
   *,W.X.Y.Z,test-host.by.domain,@my-netgroup

This apparently bothers you....

> 
> Here are some questions:
>  1. do we need nfsd/exports at all? (No ones seems to have noticed that
>     the information it gives is not very human readable.)

Yes. Anyone using an older nfs-utils or running without /proc/fs/nfsd
needs it.

>  2. If yes. What is it for? It seems to me it is needed to show what
>     export a given IP is mapped to.

Well, it is useful to have a quick look at what is exported, and it
allows olders nfs-utils to iterate through all exports known to the
kernel and remove them.

>  3. Should exportfs have a switch that to display the kernel export
>     cache is some nice format or formats.

I don't think there is anything particularly wrong with the format
(once you understand it).  Can you convince me otherwise?

NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
