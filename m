From: Greg Banks <gnb@sgi.com>
Subject: Re: ETIMEDOUT in nfsd?
Date: Thu, 5 Aug 2004 12:26:08 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040805022608.GR5581@sgi.com>
References: <20040803081503.GM5581@sgi.com> <20040803191610.GC7781@fieldses.org> <20040804073500.GP5581@sgi.com> <20040804141346.GA19282@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BsXxd-0003qB-Bd
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 19:26:29 -0700
Received: from omx3-ext.sgi.com ([192.48.171.20] helo=omx3.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BsXxd-0003EQ-0N
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 19:26:29 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040804141346.GA19282@fieldses.org>
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

On Wed, Aug 04, 2004 at 10:13:46AM -0400, J. Bruce Fields wrote:
> On Wed, Aug 04, 2004 at 05:35:00PM +1000, Greg Banks wrote:
> > On Tue, Aug 03, 2004 at 03:16:10PM -0400, J. Bruce Fields wrote:
> >
> > Let me see if I understand this...the *NFS* request is silently dropped,
> > and the *sunrpc cache* request is remembered on the server machine and
> > sent upstairs later, presumably as the userspace daemon replies to
> > earlier upcalls.  The NFS client gets nothing...no reply and no
> > indication that it should retry the original NFS request.
> 
> Right.  But it shouldn't have to retry.

But if the upcall latency (the upcall time itself plus the queue delay)
is greater than the client's initial timeout (e.g. 1.1 sec) the client
*will* retry anyway.  I don't have a feel for how long your upcalls
are...

> > So you're implicitly relying on the normal clientside timeout and
> > retry mechanism to get the NFS request resubmitted?
> 
> No.  When the userspace daemon replies, the request data that was copied
> in svc_defer() is used to make a new request.

You construct a new *NFS* request?

> So from the point of view
> of the NFS server code, it does look like a retry, but the NFS client
> isn't involved--the server rpc code did the retry on its own.

Aha...I see now.

> This is only right if upcalls are done before you've done anything
> non-idempotent, which makes it hard to handle NFSv4 compounds
> correctly.

Ouch, this is not a good assumption, especially considering servers
rebooting and cache timeouts.

> > Why not send EJUKEBOX to the client, and let it manage retry using a
> > retry strategy designed for a slow server instead of the one designed
> > for lossy networks?
> 
> That might mean returning EJUKEBOX on a lot of common operations (e.g.
> on the first rpc request from a new client), when the server usually
> could have replied very quickly.

Potentially.  But, in your experience do idmapper upcalls proceed quickly?

> Not that I'm happy with this internal retry.  Personally I'd rather just
> put the thread to sleep on a short timeout (1 second or less) and then
> return EJUKEBOX.  That's currently what we're doing for NFSv4 idmapping
> upcalls.

That sounds like a more balanced approach, although I'd want the
timeout a bit shorter, say 500ms to 800 ms.

> > Anyway, the problem I have is the use of EAGAIN.  [...]
> Well, you could either translate those EAGAIN's to ETIMEDOUT's, which
> will do what you want, or you could change all the cache code to use
> some other error in place of EAGAIN and change EAGAIN to map to
> NFSERR_JUKEBOX....

I don't fancy futzing with the cache code, or more precisely I don't
fancy having to test it.  Perhaps I'll just swallow my pride and
translate EAGAIN from the VFS layer to ETIMEDOUT in the three places
where it can happen.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
