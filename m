From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: ETIMEDOUT in nfsd?
Date: Wed, 4 Aug 2004 10:13:46 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040804141346.GA19282@fieldses.org>
References: <20040803081503.GM5581@sgi.com> <20040803191610.GC7781@fieldses.org> <20040804073500.GP5581@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BsMWc-0005Qi-U8
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 07:13:50 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1BsMWc-0003ff-A5
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 07:13:50 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040804073500.GP5581@sgi.com>
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

On Wed, Aug 04, 2004 at 05:35:00PM +1000, Greg Banks wrote:
> On Tue, Aug 03, 2004 at 03:16:10PM -0400, J. Bruce Fields wrote:
> > The server does upcalls to userspace daemons (usually to mountd to get
> > export options or IP address->client name mappings) by doing a lookup in
> > a cache, and returning -EAGAIN if an upcall is required.
> 
> With, if I understand your document correctly, the side effect of
> queuing an upcall which can be expected to fill the cache at some
> later date depending on the action of the userspace daemon (and
> its LDAP or NIS lookups or whatever).

Yes.

> > The request is
> > then dropped, a copy of the request is made (see svcsock.c:svc_defer())
> > and reprocessed at a later time (see svcsock.c:svc_revisit()).
> 
> Let me see if I understand this...the *NFS* request is silently dropped,
> and the *sunrpc cache* request is remembered on the server machine and
> sent upstairs later, presumably as the userspace daemon replies to
> earlier upcalls.  The NFS client gets nothing...no reply and no
> indication that it should retry the original NFS request.

Right.  But it shouldn't have to retry.

> So you're implicitly relying on the normal clientside timeout and
> retry mechanism to get the NFS request resubmitted?

No.  When the userspace daemon replies, the request data that was copied
in svc_defer() is used to make a new request.  So from the point of view
of the NFS server code, it does look like a retry, but the NFS client
isn't involved--the server rpc code did the retry on its own.

This is only right if upcalls are done before you've done anything
non-idempotent, which makes it hard to handle NFSv4 compounds
correctly.

> Why not send EJUKEBOX to the client, and let it manage retry using a
> retry strategy designed for a slow server instead of the one designed
> for lossy networks?

That might mean returning EJUKEBOX on a lot of common operations (e.g.
on the first rpc request from a new client), when the server usually
could have replied very quickly.

Not that I'm happy with this internal retry.  Personally I'd rather just
put the thread to sleep on a short timeout (1 second or less) and then
return EJUKEBOX.  That's currently what we're doing for NFSv4 idmapping
upcalls.

> Anyway, the problem I have is the use of EAGAIN.  The normal semantics
> of EAGAIN are that the receiver should cause a retry of whatever it was
> doing.  So if (say) nfsd_write() returned -EAGAIN it would make
> sense to translate that into NFSERR_JUKEBOX which is designed to have
> the same effect at the client.
> 
> This is what happens on an Altix with DMF installed: the DMF hooks
> in the filesystem return EAGAIN when they need to pull a file in
> from tape, and that percolates naturally through several layers to
> be translated to NFSERR_JUKEBOX to the client.

Well, you could either translate those EAGAIN's to ETIMEDOUT's, which
will do what you want, or you could change all the cache code to use
some other error in place of EAGAIN and change EAGAIN to map to
NFSERR_JUKEBOX....

--Bruce Fields


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
