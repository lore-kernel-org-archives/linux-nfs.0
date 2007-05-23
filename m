From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 4/14] knfsd: has_wspace per transport
Date: Wed, 23 May 2007 16:41:57 +1000
Message-ID: <20070523064157.GE14076@sgi.com>
References: <20070523023206.GA14076@sgi.com>
	<C27939D4.30F92%tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqkXt-0000fB-Gk
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 23:42:05 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1+iBujGcIE4Dm4MRH5xJIpCaYe1ki5MjfA=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqkXw-0002Hr-8B
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 23:42:08 -0700
In-Reply-To: <C27939D4.30F92%tom@opengridcomputing.com>
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

On Wed, May 23, 2007 at 12:22:44AM -0500, Tom Tucker wrote:
> 
> 
> 
> On 5/22/07 9:32 PM, "Greg Banks" <gnb@sgi.com> wrote:
> 
> > On Tue, May 22, 2007 at 12:34:23PM -0500, Tom Tucker wrote:
> 
> I need to do a little clean up (e.g. atomic_inc()) and then I'll add them as
> suggested. If there are dissenters, please speak now...

You should be able to get away with just ++.  They're only stats,
it's not like you have logic depending on them being exact.

> >> The current thread will wait, but the remaining
> >> threads (127 in your case) will be free to do other work for other mount
> >> points. 
> >> 
> >> This only falls over in the limit of 128 mounts all pounding the server
> >> with writes. Comments?
> > 
> > A common deployment scenario I would expect to see would have at
> > least twice as many clients as threads, and SGI have successfully
> > tested scenarios with a 16:1 client:thread ratio.  So I don't think
> > we can solve the problem in any way which ties down a thread for
> > up to 6 seconds per client, because there won't be enough threads
> > to go around.
> 
> Agreed. But isn't that the 100 dead adapter scenario?

Umm?

> Someone has to wait.
> Who? 

> > In other words, invert the rdma_read_xdr() logic so nfsd return
> > to the main loop instead of blocking.
> > 
> > Unfortunately it's kind of a major change.  Thoughts?
> > 
> 
> Ok, I love it and I hate it :-)  This is the consolidated waiter strategy
> that solves all the problems...except ...does this expose any read/write
> ordering issues at the client? Couldn't the client issue a write followed by
> a read and get the original data?

The server doesn't guarantee that the order of completion of calls
in the filesystem is the same as the order of emission of those calls
by the client.  On UDP, the calls might not even arrive at the server
in the same order they left the client.

If the client needs to ensure that a READ happens after a WRITE,
it needs to wait for the WRITE reply before emitting the READ; that
should still be true with this change.

> That's the hate it part. If we need to decide which requests are allowed to
> proceed on a QP with outstanding READ WR, things get messy quick.
> 
> Is there no such requirement?

I don't think so.

You might want to limit the number of RDMA READ streams in flight.

> >>> And every now and again something goes awry in
> >>> IB land and each thread ends up waiting for 6 seconds or more.
> >> 
> >> Yes. Note that when this happens, the connection gets terminated.
> > 
> > Indeed.  Meanwhile, for the last 6 seconds all the nfsds are
> > blocked waiting for the one client, and none of the other clients
> > are getting any service.
> 
> We need to think about this. A dead adapter causes havoc.

A dead adaptor on the server should cause havoc, at least for as long
as it takes HA to kick in.  A dead adaptor on a client should affect
only that client and no other clients.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
