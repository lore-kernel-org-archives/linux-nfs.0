From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: Re:
	=?iso-8859-1?q?slowness_due_to_splitting_into_pages_in=09nf?=
	=?iso-8859-1?q?s3svc=5Fdecode=5Fwriteargs_=28=29?=
Date: Fri, 31 Aug 2007 23:34:49 +0200
Message-ID: <200708312334.50001.bernd-schubert@gmx.de>
References: <200708312003.30446.bernd-schubert@gmx.de>
	<20070831184515.GC11165@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Brian J. Murrell" <brian@interlinx.bc.ca>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IRE8s-00048Z-6B
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 14:35:02 -0700
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1IRE8t-000328-KT
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 14:35:05 -0700
In-Reply-To: <20070831184515.GC11165@fieldses.org>
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

Hello Bruce,

thanks for your help!

On Friday 31 August 2007, J. Bruce Fields wrote:
> On Fri, Aug 31, 2007 at 08:03:30PM +0200, Bernd Schubert wrote:
> > I'm presently investigating why writing to a nfs exported lustre
> > filesystem is rather slow. Reading from lustre over nfs about 200-300
> > MB/s, but writing to it over nfs is only 20-50MB/s (both with IPoIB).
> > Writing directly to this lustre cluster is about 600-700 MB/s both
> > reading and writing. Well, 200-300 MB/s over NFS per client would be
> > acceptable.
> >
> > After several dozens of printks, systemtaps, etc I think its not the
> > fault of lustre, but a generic nfsd and/or vfs problem.
>
> Thanks for looking into this!

I will give these thanks to my boss who is paying me for this work :)


>
> > In nfs3svc_decode_writeargs() all the data received are splitted into
> > PAGE_SIZE, except the very first page. This page only gets
> > PAGE_SIZE - header_length. So far no problem, but now on writing the
> > pages in generic_file_buffered_write(), this function tries to write
> > PAGE_SIZE. So it takes the first nfs page, which is PAGE_SIZE -
> > header_length.
> > To fill up to PAGE_SIZE it will take header_length from the second page.
> > Of course, now there's also only PAGE_SIZE - header_length for the 2nd
> > nfs page left.
> > It will continue this way until the last page is written. Don't know why
> > this doesn't show a big effect on other file system. Well, maybe it does,
> > but nobody did notice it before?
>
> Hm.  Any chance this is the same problem?:
>
> 	http://marc.info/?l=linux-nfs&m=112289652218095&w=2

Looks similar.

+	if (vec[0].iov_len + vec[vlen-1].iov_len != PAGE_CACHE_SIZE)
+		return 0;
+	for (i = 1; i < vlen - 1; ++i) {
+		if (vec[i].iov_len != PAGE_CACHE_SIZE)
+			return 0;
+	}

I tried to say in my last mail:

vec[0].iov_len           = PAGE_PAGE_SIZE - headerlength
vec[1 ... n - 1].iov_len = PAGE_PAGE_SIZE
vec[n].iov_len           = headerlength


This looks like it needs quite some cpu cycles

+               memmove(this_page + chunk0, this_page, chunk1);
+               memcpy(this_page, prev_page + chunk1, chunk0);

I will test the patch tomorrow.

>
> > Using this patch I get write speed of about 200 MB/s, even with kernel
> > debugging enabled and several left-over printks
>
> At too high a cost, unfortunately:
> > -- nfs3xdr.c.bak	2007-07-09 01:32:17.000000000 +0200
> >  	rqstp->rq_vec[0].iov_base = (void*)p;
>
> ...
>
> > +	rqstp->rq_vec[0].iov_len = len;
> > +	args->vlen = 1;
>
> There's no guarantee the later pages in the rq_pages array are
> contiguous in memory after the first one, so the rest of that iovec
> probably has random data in it.

Hmm, its some time since I last read rfc1813, but I can't remember something 
like 'data are send in pages and pages may have random order'. So I guess 
some kind of multi-threading is filling in the data the client is sending?
Given the performance impact this has, maybe single-threading per client 
request would be better?
Can you point me to the corresponding function?

>
> (You might want to add to your tests some checks that the right data
> still gets to the file afterwards.)

Hmm, I need to put the data on a ram-disk. All raid-boxes sufficiently fast 
for this operation are in use for lustre storage.


Thanks again,
Bernd

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
