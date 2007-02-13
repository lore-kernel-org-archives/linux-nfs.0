From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Broken nfsd in recent kernels
Date: Tue, 13 Feb 2007 15:50:22 +1100
Message-ID: <45D1438E.6090001@yahoo.com.au>
References: <1171326368.8065.36.camel@hoeplx2923>	<17873.13603.316692.955211@notabene.brown>	<45D1374E.1090800@yahoo.com.au>
	<17873.16504.979464.1957@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Norman Weathers <norman.r.weathers@conocophillips.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGpcr-0001u4-G0
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 20:50:45 -0800
Received: from smtp101.mail.mud.yahoo.com ([209.191.85.211])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HGpct-00034H-6u
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 20:50:47 -0800
In-Reply-To: <17873.16504.979464.1957@notabene.brown>
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

Neil Brown wrote:
> On Tuesday February 13, nickpiggin@yahoo.com.au wrote:

>>It would be interesting to know whether Norman's test case actually is
>>using writev...
> 
> 
> He is just use NFS.  NFSD does use writev.

OK that makes a lot of sense.

> A typical 32K write arrives as a bunch of IP packets most of which
> hold 1448 bytes.  These are all presented to the filesystem in a
> writev (vfs_writev actually).
> 
> I presume the problem is that we cannot fault_in_pages_readable two
> different buffers as the first might disappear while the second is
> being paged in....

Yeah that, and also I don't think we ever actually did the
fault_in_pages_readable for subsequent segments past the first one,
so it could be quite trivial to trigger the problem delibrately.

> Would it be possible to count how much of the iovec is in
> kernel-space, or maybe how much is *not* part of the file being
> written too, and allow that much to be processed all at once?
> Or is there something more subtle that I am missing?
> 
> The following patch is rather gross, but seems to work and should be
> safe... what do you think?

I think it seems like a very good idea. There is no reason to worry
about faults if we're dealing with kernel constructed buffers.

> 
> NeilBrown
> 
> Signed-off-by: Neil Brown <neilb@suse.de>
> 
> diff .prev/mm/filemap.c ./mm/filemap.c
> --- .prev/mm/filemap.c	2007-02-13 15:10:32.000000000 +1100
> +++ ./mm/filemap.c	2007-02-13 15:19:20.000000000 +1100
> @@ -2163,9 +2163,11 @@ generic_file_buffered_write(struct kiocb
>  		/*
>  		 * Limit the size of the copy to that of the current segment,
>  		 * because fault_in_pages_readable() doesn't know how to walk
> -		 * segments.
> +		 * segments, but don't worry about such technicalities if nfsd
> +		 * is writing, as prefault isn't needed then.
>  		 */
> -		bytes = min(bytes, cur_iov->iov_len - iov_base);
> +		if (!segment_eq(get_fs(), KERNEL_DS))
> +			bytes = min(bytes, cur_iov->iov_len - iov_base);
>  
>  		/*
>  		 * Bring in the user page that we will copy from _first_.
> @@ -2173,7 +2175,8 @@ generic_file_buffered_write(struct kiocb
>  		 * same page as we're writing to, without it being marked
>  		 * up-to-date.
>  		 */
> -		fault_in_pages_readable(buf, bytes);
> +		if (!segment_eq(get_fs(), KERNEL_DS))
> +			fault_in_pages_readable(buf, bytes);
>  
>  		page = __grab_cache_page(mapping,index,&cached_page,&lru_pvec);
>  		if (!page) {
> 


-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
