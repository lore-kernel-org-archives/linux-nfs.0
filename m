From: Rock Gordon <rockgordon@yahoo.com>
Subject: Re: purpose of knfsd reply cache
Date: Sat, 6 Apr 2002 11:10:50 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020406191050.25886.qmail@web14802.mail.yahoo.com>
References: <15534.6056.626290.31180@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from web14802.mail.yahoo.com ([216.136.224.218])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16tvaN-0003na-00
	for <nfs@lists.sourceforge.net>; Sat, 06 Apr 2002 11:10:51 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>, jpmg@eng.cam.ac.uk
In-Reply-To: <15534.6056.626290.31180@notabene.cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Well, the "correctness" is subject to whether a
previous reply was actually found in the cache or not.

That will not only depend on the quality of the
network, but also on the number of entries in the
cache. The comment in the begining of the file
nfscache.c ("Size of reply cache ...") itself seems to
convey that guesswork was at it's best.


--- Neil Brown <neilb@cse.unsw.edu.au> wrote:
> On Friday April 5, jpmg@eng.cam.ac.uk wrote:
> > I'm trying to pin down a data corruption
> corruption bug in knfsd .  As
> > a side effect, I've been looking at the reply
> cache, and getting puzzled.
> > 
> > Any answers to any of the following very much
> appreciated!
> 
> The purpose of the reply cache is for correctness,
> not performance.
> 
> If a client sends a MKDIR request where the
> presented name doesn't yet
> exist, the server will create the directory and
> return "success".
> If the reply gets lost, the client resends, and the
> server re-executes
> the request, it will find that the directory already
> exists and so
> will return "EEXIST".
> So the client will see EEXIST where it should see
> "success".
> The reply cache is for catching caches such as this.
>  The resend from
> the client will cause a match in the reply cache, so
> the server
> will not re-execute the MKDIR but will just send the
> original
> "success" response.
> 
> So your assessment of what the reply cache does is
> exactly correct.
> However you expectation of what it is for is wrong.
> 
> 
> 
> > 
> > a) am I correct in thinking that the comment in
> both nfs3proc.c and
> >    nfsproc.c 
> >    * Only the results of non-idempotent operations
> are cached.
> >    should actually read
> >    * Only the results of idempotent operations are
> cached.
> > 
> 
> No
> 
> >    [ ie, only operations that are idempotent (acts
> as if used only once
> >    even if used many times) can safely be "faked"
> on subsequent calls
> >    by using the cached reply data ]
> > 
> > b) given the set of operations for which reply
> caching is allowed, is
> >    it not the case that the only likely cause of a
> reply cache hit is
> >    when a client sends a request, the server
> handles the request, the
> >    reply is lost, so the client repeats the
> request?
> 
> Yes.
> 
> > 
> > c) on my server, "nfsstat -o rc" suggests that
> around 0.0005% of replies
> >    that could have been cached were hits.  Is my
> server unusual?  Does
> >    nfsstat correctly report this statistic?  If
> the answers to those
> >    are "no" and "yes", then is the reply cache
> worth bothering with?  
> 
> No. Yes. Yes.
> A low hit rate is good.  It means your network is
> not being
> overloaded.
> 
> NeilBrown
> 
> > 
> > -patrick.
> > 
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


__________________________________________________
Do You Yahoo!?
Yahoo! Tax Center - online filing with TurboTax
http://taxes.yahoo.com/

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
