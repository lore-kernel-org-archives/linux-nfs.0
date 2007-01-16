From: Spencer Shepler <spencer.shepler@sun.com>
Subject: Re: [nfsv4] RE: Finding hardlinks
Date: Tue, 16 Jan 2007 00:06:49 -0600
Message-ID: <20070116060649.GE4298@sheplap.local>
References: <C98692FD98048C41885E0B0FACD9DFB8023DF95A@exnane01.hq.netapp.com>
Reply-To: spencer.shepler@sun.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Benny Halevy <bhalevy@panasas.com>,
	Spencer Shepler <spencer.shepler@sun.com>, nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H6hTX-0001cD-Hn
	for nfs@lists.sourceforge.net; Mon, 15 Jan 2007 22:07:15 -0800
Received: from nwkea-mail-5.sun.com ([192.18.42.27])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H6hTW-0001ij-Rg
	for nfs@lists.sourceforge.net; Mon, 15 Jan 2007 22:07:17 -0800
To: nfsv4@ietf.org
In-Reply-To: <C98692FD98048C41885E0B0FACD9DFB8023DF95A@exnane01.hq.netapp.com>
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


I won't be at connectathon either.  

btw: we do have 2.5 hours scheduled for Prague. :-)


On Mon, Noveck, Dave wrote:
> I'm not going to be at Connectathon, but I could call in for a
> discussion. 
> 
> -----Original Message-----
> From: Benny Halevy [mailto:bhalevy@panasas.com] 
> Sent: Monday, January 15, 2007 3:45 AM
> To: Noveck, Dave; Trond Myklebust
> Cc: Spencer Shepler; nfsv4@ietf.org; nfs@lists.sourceforge.net
> Subject: Re: [nfsv4] RE: Finding hardlinks
> 
> How about discussing this topic in the upcoming Connectathon?
> 
> Benny
> 
> Noveck, Dave wrote:
> > For now, I'm not going to address the controversial issues here, 
> > mainly because I haven't decided how I feel about them yet.
> > 
> >      Whether allowing multiple filehandles per object is a good
> >      or even reasonably acceptable idea.
> > 
> >      What the fact that RFC3530 talks about implies about what
> >      clients should do about the issue.
> > 
> > One thing that I hope is not controversial is that the v4.1 spec 
> > should either get rid of this or make it clear and implementable.
> > I expect plenty of controversy about which of those to choose, but 
> > hope that there isn't any about the proposition that we have to choose
> 
> > one of those two.
> > 
> >> SECINFO information is, for instance, given out on a per-filehandle 
> >> basis, does that mean that the server will
> > have
> >> different security policies? 
> > 
> > Well yes, RFC3530 does say "The new SECINFO operation will allow the 
> > client to determine, on a per filehandle basis", but I think that just
> 
> > has to be considered as an error rather than indicating that if you 
> > have two different filehandles for the same object, they can have 
> > different security policies.  SECINFO in RFC3530 takes a directory fh 
> > and a name, so if there are multiple filehandles for the object with 
> > that name, there is no way for SECINFO to associate different policies
> 
> > with different filehandles.  All it has is the name to go by.  I think
> 
> > this should be corrected to "on a per-object basis" in the new spec no
> 
> > matter what we do on other issues.
> > 
> > I think the principle here has to be that if we do allow multiple fh's
> 
> > to map to the same object, we require that they designate the same 
> > object, and thus it is not allowed for the server to act as if you 
> > have multiple different object with different characteristics.
> > 
> > Similarly as to:
> > 
> >> In some places, people haven't even started to think about the 
> >> consequences:
> >>
> >>     If GETATTR directed to the two filehandles does not return the
> >>     fileid attribute for both of the handles, then it cannot be
> >>     determined whether the two objects are the same.  Therefore,
> >>     operations which depend on that knowledge (e.g., client side data
> >>     caching) cannot be done reliably.
> > 
> > I think they (and maybe "they" includes me, I haven't checked the 
> > history
> > here) started to think about them, but went in a bad direction.
> > 
> > The implication here that you can have a different set of attributes 
> > supported for the same object based on which filehandle is used to 
> > access the attributes is totally bogus.
> > 
> > The definition of supp_attr says "The bit vector which would retrieve 
> > all mandatory and recommended attributes that are supported for this 
> > object.  The scope of this attribute applies to all objects with a 
> > matching fsid."  So having the same object have different attributes 
> > supported based on the filehandle used or even two objects in the same
> 
> > fs having different attributes supported, in particular having fileid 
> > supported for one and not the other just isn't valid.
> > 
> >> The fact is that RFC3530 contains masses of rope with which to allow 
> >> server and client vendors to hang themselves.
> > 
> > If that means simply making poor choices, then OK.  But if there are 
> > other cases where you feel that the specification of a feature is 
> > simply
> > 
> > incoherent and the consequences not really thought out, then I think 
> > we need to discuss them and not propagate that state of affairs to
> v4.1.
> > 
> > -----Original Message-----
> > From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
> > Sent: Friday, January 05, 2007 5:29 AM
> > To: Benny Halevy
> > Cc: Jan Harkes; Miklos Szeredi; nfsv4@ietf.org; 
> > linux-kernel@vger.kernel.org; Mikulas Patocka; 
> > linux-fsdevel@vger.kernel.org; Jeff Layton; Arjan van de Ven
> > Subject: Re: [nfsv4] RE: Finding hardlinks
> > 
> > 
> > On Fri, 2007-01-05 at 10:28 +0200, Benny Halevy wrote:
> >> Trond Myklebust wrote:
> >>> Exactly where do you see us violating the close-to-open cache 
> >>> consistency guarantees?
> >>>
> >> I haven't seen that. What I did see is cache inconsistency when
> > opening
> >> the same file with different file descriptors when the filehandle
> > changes.
> >> My testing shows that at least fsync and close fail with EIO when the
> > filehandle
> >> changed while there was dirty data in the cache and that's good.
> > Still,
> >> not sharing the cache while the file is opened (even on a different
> > file
> >> descriptors by the same process) seems impractical.
> > 
> > Tough. I'm not going to commit to adding support for multiple 
> > filehandles. The fact is that RFC3530 contains masses of rope with 
> > which to allow server and client vendors to hang themselves. The fact 
> > that the protocol claims support for servers that use multiple 
> > filehandles per inode does not mean it is necessarily a good idea. It 
> > adds unnecessary code complexity, it screws with server scalability 
> > (extra GETATTR calls just in order to probe existing filehandles), and
> 
> > it is insufficiently well documented in the RFC: SECINFO information 
> > is, for instance, given out on a per-filehandle basis, does that mean 
> > that the server will have different security policies? In some places,
> 
> > people haven't even started to think about the consequences:
> > 
> >       If GETATTR directed to the two filehandles does not return the
> >       fileid attribute for both of the handles, then it cannot be
> >       determined whether the two objects are the same.  Therefore,
> >       operations which depend on that knowledge (e.g., client side
> data
> >       caching) cannot be done reliably.
> > 
> > This implies the combination is legal, but offers no indication as to 
> > how you would match OPEN/CLOSE requests via different paths. AFAICS 
> > you would have to do non-cached I/O with no share modes (i.e. 
> > NFSv3-style "special" stateids). There is no way in hell we will ever 
> > support non-cached I/O in NFS other than the special case of O_DIRECT.
> > 
> > 
> > ...and no, I'm certainly not interested in "fixing" the RFC on this 
> > point in any way other than getting this crap dropped from the spec. I
> 
> > see no use for it at all.
> > 
> > Trond
> > 
> > 
> > _______________________________________________
> > nfsv4 mailing list
> > nfsv4@ietf.org
> > https://www1.ietf.org/mailman/listinfo/nfsv4
> 
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share your
> opinions on IT & business topics through brief surveys - and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
