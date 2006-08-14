From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 003 of 4] Prepare knfsd for support	of	rsize/wsize
	of up to 1MB, over TCP.
Date: Mon, 14 Aug 2006 17:52:54 +1000
Message-ID: <1155541973.16378.1698.camel@hole.melbourne.sgi.com>
References: <20060807103020.12286.patches@notabene>
	<1060807003515.12391@suse.de>
	<76bd70e30608070604r5da3fefds4fea763336221403@mail.gmail.com>
	<1155003129.29877.177.camel@hole.melbourne.sgi.com>
	<17632.8057.928771.226237@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Chuck Lever <chucklever@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCXFu-0007TB-Pu
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 00:53:02 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GCXFv-0004gK-2N
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 00:53:03 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17632.8057.928771.226237@cse.unsw.edu.au>
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

On Mon, 2006-08-14 at 17:00, Neil Brown wrote:
> On Tuesday August 8, gnb@melbourne.sgi.com wrote:
> > On Mon, 2006-08-07 at 23:04, Chuck Lever wrote:
> > > I know the name NFSSVC_MAXBLKSIZE is historical, but to me it is
> > > confusing.  It isn't a block size at all, it's really a maximum
> > > tranfser size, in bytes, right?
> > 
> > NFSSVC_MAXBLKSIZE is the maximum NFS payload size, i.e. the largest
> > size of file data that can passed in WRITE and returned from READ.
> > The transfer size (as I understand the term) would be that plus the
> > NFS and RPC headers, i.e. 65536 bytes for UDP.  So I think the name
> > is mostly OK.
> > 
> 
> It tripped over this issue when I was working through this patch set,
> and decided to ignore it :-)
> 
> Mostly we try to maintain clear separation between the sunrpc layer
> and the NFS layer.  But it breaks down here.
> 
> The RPC layer allocates a certain amount of memory for each request.
> This need to hold the request and the reply, both rounded up to whole
> pages (with allowances for odd things like the tail of a readdir
> appearing in the first page of the reply, but that isn't really
> important).
> 
> The NFS server requests a buffer size, which should be enough to hold
> the largest req+reply pair.
> For v2 and v3 at least, this is one page each plus the largest IO
> block.
> 
> So far this makes sense.  NFSd should ask for 2+blocksize having
> convinced itself that apart from the datablocks, the whole req and
> reply each fit in a page (and if they don't we have lots of other
> breakage).

Agreed.

> But the names don't quite follow this.
>  RPCSVC_MAXPAYLOAD  really doesn't say anything important about RPC

True, it's an NFS level concept really.  In sunrpc/ it serves
only to make the maths prettier...

>  RPCSVC_MAXPAGES is a significant value, and maybe it is the one we
>    should be explicitly setting, though we would set it to
>     1024*1024/PAGE_SIZE + 2 
>    which is ugly.

...like that.

>  Then NFSSVC_MAXBLKSIZE is set to RPCSVC_MAXPAYLOAD which isn't
>  really right.  It should be (RPCSVC_MAXPAGES-2)*PAGE_SIZE

Sure.

>  And NFS_BUFSIZE is ((RPC_MAX_HEADER_WITH_AUTH+26)*XDR_UNIT +
>                       NFSSVC_MAXBLKSIZE)
>  which sort-of makes sense, except that we really need 2
>  headers in there, both the request and the reply.

That's right, but this works because the resulting number is
rounded up to a page size anyway.  We could have

#define NFS_BUFSIZE 1 

and it would still work.

>   And
>  we need them both to be page aligned, so giving a number of bytes
>  is odd.
> 
>  And then there is RPCSVC_MAXPAYLOAD_UDP... which is really
>  a very NFS specific thing.

I presume you mean _V2 ?

> So......
>  Maybe we should pass a number of pages to svc_create rather than a
>  number of bytes.  This needs to be the max size of a request + reply.
>  And svc_init_buffer shouldn't really add a magic '2'... or should it?

Sure, you could do it that way.

>  And I think we should replace svc_max_payload with nfsd_max_payload.

Ok, that makes more sense now that you have a /proc entry.
How about nfsd_max_transfer_size() ?

>  So nfsd calls svc_create with (1 + nfsd_max_block_pages + 1)
>  and svc_init_buffer allocates that many pages.
>  Then nfsd_max_payload returns
>         (rqstp->rq_server->sv_bufpages-2)<<PAGE_SHIFT;

Sure.

> But is it really worth the effort?

I think the entire way the sunrpc serverside code handles memory
is messy and error prone and if I had my druthers I'd spend a few
weeks rewriting it entirely.

> I guess that must be why I decided to ignore it.
> 
> Any suggestions?

I think the best thing in the short term would be to carefully
rename a few functions and preserve the existing logic, but
perhaps this is just innate conservatism.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
