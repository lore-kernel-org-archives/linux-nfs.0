From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: Re: Interesting problem with sunrpc cache
Date: Thu, 18 Oct 2007 14:22:00 -0400
Message-ID: <1192731720.7466.37.camel@moss-terrapins.epoch.ncsc.mil>
References: <1192715235.7466.13.camel@moss-terrapins.epoch.ncsc.mil>
	<20071018145549.GA24088@fieldses.org>
	<1192722476.7466.28.camel@moss-terrapins.epoch.ncsc.mil>
	<20071018170104.GD24088@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iia0X-0000yr-6E
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 11:22:09 -0700
Received: from mummy.ncsc.mil ([144.51.88.129] helo=jazzhorn.ncsc.mil)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Iia0c-0001QU-4r
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 11:22:14 -0700
In-Reply-To: <20071018170104.GD24088@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2007-10-18 at 13:01 -0400, J. Bruce Fields wrote:
> On Thu, Oct 18, 2007 at 11:47:56AM -0400, David P. Quigley wrote:
> > On Thu, 2007-10-18 at 10:55 -0400, J. Bruce Fields wrote:
> > > On Thu, Oct 18, 2007 at 09:47:15AM -0400, David P. Quigley wrote:
> > > > Hello,
> > > >     I have been working on a Domain of Interpretation mapper for the
> > > > labeled nfs work and I seem to have hit a wall. I started with idmapd as
> > > > a base and proceeded to modify it to work with DOIs instead. Because of
> > > > this with a few minor exceptions I expected everything to work. For the
> > > > most part it does however I seem to have a minor problem with the cache
> > > > on the nfsd side.
> > > > 
> > > >     I am running into a problem where I can't mount the export because
> > > > the server keeps trying to translate the label. I initially get a
> > > > success but then it repeatedly attempts to retry.
> > > 
> > > So you're just getting repeated NFS4ERR_DELAY responses to the same
> > > request from the client?  Or does the server just stop responding?  Is
> > > this always reproduceble?
> > 
> > The server stops responding since it is hung in the
> > nfs_map_local_to_global function so these retries are between the kernel
> > and the userspace daemon.
> 
> OK.  It's not doing exactly the same thing as the nfs4idmap.c code,
> then--maybe you'll want to post your patch to help us understand?

That's a good idea. I'm gonna table my translation stuff for a day or so
to incorporate some other patches from my other team mates and I will
post a patch set probably on Monday. I wanted to have a working DOI
translation daemon sent out with it but unfortunately that doesn't seem
like it is going to be an option.

> 
> > > > I have tracked it down to a bit of code which essentially is a
> > > > duplication of do_idmap_lookup_nowait.
> > > 
> > > When exactly does the label translation occur?
> > 
> > We added a new recommended attribute so we have a function called
> > nfsd4_encode_security_label in nfs4xdr.c. This grabs the label using
> > security_inode_getsecurity and then sends it to the translation daemon.
> 
> When is this attribute requested?

The call to nfsd4_encode_security_label is in nfsd4_encode_fattr. We
usually pull this across with every getattr request. The decoding which
we haven't hit yet is in nfsd4_decode_fattr
> 
> > I don't think there is more than one cache item. I can't tell for sure
> > since there doesn't seem to be more than one iteration before it goes
> > into the loop but I do a lookup on the local representation and I get a
> > negative cache entry back.
> 
> It shouldn't have CACHE_NEGATIVE set at this point.  (CACHE_VALID should
> be cleared, if that's what you mean.)
> 
> > I'm not sure if the negative bit is set so I will check that in a bit
> > (no pun intended).
> 
> Hmph.
> 
> > Then I make the upcall to userspace and the parse function comes back
> > with a sucessful translation and no error code. At this point I put
> > the node into the update function and in theory the negative entry we
> > pulled from the lookup should update the global field for the entry. I
> > supposed that I could toss another lookup call in there to make sure
> > that this is actually happening.  However, update seems to be working
> > properly in that it returns a cache entry that has the appropriate
> > values.
> 
> You could also printk() the address of the cache items in question just
> to make sure the right one's getting updated.

I'll give that a try.

> 
> > Any bit of insight helps me get closer to solving the problem. The
> > interesting thing is that if this bit was being set properly it seems as
> > if everything else would be working perfectly.
> 
> Happy to help if I'm able, but I'm leaving for an early weekend sometime
> this afternoon, so will probably be mostly unresponsive till Monday.

Have a nice weekend :)

> 
> --b.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
