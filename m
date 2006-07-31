From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 008 of 11] knfsd: add svc_set_num_threads
Date: Mon, 31 Jul 2006 14:24:41 +1000
Message-ID: <17613.34313.547132.43455@cse.unsw.edu.au>
References: <20060731103458.29040.patches@notabene>
	<1060731004223.29267@suse.de>
	<20060730211130.be44c1d0.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7PKn-0004t8-9P
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 21:24:53 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G7PKm-0005YZ-Ef
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 21:24:53 -0700
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: message from Andrew Morton on Sunday July 30
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

On Sunday July 30, akpm@osdl.org wrote:
> On Mon, 31 Jul 2006 10:42:23 +1000
> NeilBrown <neilb@suse.de> wrote:
> 
> > +	/* destroy old threads */
> > +	while (nrservs < 0 &&
> > +	       (victim = choose_victim(serv, pool, &state)) != NULL) {
> > +		send_sig(serv->sv_kill_signal, victim, 1);
> > +		nrservs++;
> 
> Using signals to communicate with kernel threads is rather baroque - we
> have a range of less klunky ways of controlling kernel threads in-kernel.

True.

> 
> The containers guys are going through converting lots of these things over
> to the kthread API - I believe it's a requirement for containerisation.
> 

Yes - hch has suggested that this needs to be a done.  I had a try and
there were enough complications that I decided to leave it to asked
Greg's NUMA stuff.

> nfsd/rpc is going to be one of the hard ones to convert, but it's going to
> happen.

yep.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
