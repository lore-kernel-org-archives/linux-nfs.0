From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: ETIMEDOUT in nfsd?
Date: Thu, 5 Aug 2004 10:21:59 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040805142159.GB25948@fieldses.org>
References: <20040803081503.GM5581@sgi.com> <20040803191610.GC7781@fieldses.org> <20040804073500.GP5581@sgi.com> <20040804141346.GA19282@fieldses.org> <20040805022608.GR5581@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bsj86-0007M3-4C
	for nfs@lists.sourceforge.net; Thu, 05 Aug 2004 07:22:02 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1Bsj85-0008ET-Ml
	for nfs@lists.sourceforge.net; Thu, 05 Aug 2004 07:22:02 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040805022608.GR5581@sgi.com>
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

On Thu, Aug 05, 2004 at 12:26:08PM +1000, Greg Banks wrote:
> On Wed, Aug 04, 2004 at 10:13:46AM -0400, J. Bruce Fields wrote:
> > So from the point of view
> > of the NFS server code, it does look like a retry, but the NFS client
> > isn't involved--the server rpc code did the retry on its own.
> 
> Aha...I see now.
> 
> > This is only right if upcalls are done before you've done anything
> > non-idempotent, which makes it hard to handle NFSv4 compounds
> > correctly.
> 
> Ouch, this is not a good assumption, especially considering servers
> rebooting and cache timeouts.

I don't see the problem you're referring to.  I don't believe that in
either case these internal replays add any problems that we don't
already have, but perhaps I'm missing something.

> > > Why not send EJUKEBOX to the client, and let it manage retry using a
> > > retry strategy designed for a slow server instead of the one designed
> > > for lossy networks?
> > 
> > That might mean returning EJUKEBOX on a lot of common operations (e.g.
> > on the first rpc request from a new client), when the server usually
> > could have replied very quickly.
> 
> Potentially.  But, in your experience do idmapper upcalls proceed quickly?

It's a good question; it would be interesting to measure them sometime
with a variety of different configurations (local /etc/passwd, ldap,
etc.), but we haven't gotten around to that yet.

--Bruce Fields


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
