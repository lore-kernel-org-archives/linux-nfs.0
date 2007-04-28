From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
Date: Sat, 28 Apr 2007 14:33:32 +0200
Message-ID: <20070428123332.GB3827@janus>
References: <17969.37229.250000.895316@notabene.brown>
	<20070427111513.GA25126@salusa.poochiereds.net>
	<17969.61232.323762.29003@notabene.brown>
	<20070427134248.GB25126@salusa.poochiereds.net>
	<20070427141710.GA11484@infradead.org>
	<20070427154259.GF32278@fieldses.org>
	<46321870.7000607@redhat.com> <20070427203444.GA28874@janus>
	<4632C5AF.7080500@redhat.com>
	<17970.53957.677739.642780@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, Jeff Layton <jlayton@redhat.com>,
	Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hhm7K-0007Rv-6V
	for nfs@lists.sourceforge.net; Sat, 28 Apr 2007 05:33:34 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hhm7K-0002zD-Ml
	for nfs@lists.sourceforge.net; Sat, 28 Apr 2007 05:33:36 -0700
In-Reply-To: <17970.53957.677739.642780@notabene.brown>
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

On Sat, Apr 28, 2007 at 02:51:17PM +1000, Neil Brown wrote:
> On Friday April 27, wcheng@redhat.com wrote:
[...]
> Certainly a lot closer.
> If we are creating "nlm_drop_locks" and "nlm_set_grace" interfaces, we
> should spend a few moments considering exactly what semantics they
> should have.
> 
> In both cases we write a filename.  Presumably it must start with a
> '/' and be null terminated, so you use "echo -n" rather than "echo".
> After all, a filename can contain a newline.

I don't care much about the trailing newline. Try mounting and
exporting it and mounting it on the client ;-). Truncating the
string at the first newline may be a practical thing to do.

> 
> Is there any extra info we might want to pass in or out at the same
> time?
> 
> For nlm_drop_locks, we might also want to be able to query locked -
> "Do you hold any locks on this filesystem".  Even "how many?".

The "no locks dropped" case might be useful. #locks dropped is
only informational (without client info) and covers the first case
too so that would be my choice but I don't have any strong opinion
about this.

> 
> Does it make sense to have a single file with composite semantics?

Only if that would avoid an otherwise unavoidable race. There are
just too many components involved with NFS so to avoid any race I'd
probably unplug it temporarily with iptables or "ip addr del..."
But I would like to be able to drop locks without entering grace
mode: a zero second grace mode when combined.

> 
> We write
>     XX/path/name
> where XX can be:

Try mounting and exporting pathnames with spaces.. that's not going
to work anytime soon, or even anytime at all (other unixes). So no
need to use / as separator.

>     a number, to set second remaining in grace period
>     a '?' (or empty string) to query state

You mean: write "?/path/name" to tell the kernel what subsequent
reads should query?

>     a '-' to remove all locks (and cancels any grace period)

That's a strange combination. But cancelling a grace period
is equivalent with setting it to zero seconds so no need for a
special case.

I'd go for simplicity: one file per function (unless there's an
unavoidable race). What about:

/proc/fs/nfsd/nlm_grace:
	Write a number to set the grace period in seconds
	(0==cancel). May be followed by a space + pathname to
	indicate the superblock/list of svc_something the grace
	period applies to (otherwise it's global). Truncate the
	string at a newline.

/proc/fs/nfsd/nlm_unlock:
	Write either a pathname or "" to drop locks. This has the
	same syntax as the second field of nlm_grace.


Optional: In addition to a pathname support "fsid=" syntax in
both cases.

If you wanna go wild then support a file= syntax to recover from
stale locks on individual files due to buggy clients.

-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
