From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Cache flushing
Date: Sat, 17 Nov 2007 18:52:11 -0500
Message-ID: <1195343531.7084.11.camel@localhost.localdomain>
References: <1195258291.6039.189.camel@hurina>
	<1195328785.6999.5.camel@localhost.localdomain>
	<600549E3-82CF-44EB-8394-E57A3BB41118@iki.fi>
	<1195332062.6999.20.camel@localhost.localdomain>
	<1195337516.6039.239.camel@hurina>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Timo Sirainen <tss@iki.fi>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ItXSS-0001P8-B8
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 15:52:16 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ItXSW-0002Aa-OD
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 15:52:22 -0800
In-Reply-To: <1195337516.6039.239.camel@hurina>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


On Sun, 2007-11-18 at 00:11 +0200, Timo Sirainen wrote:
> On Sat, 2007-11-17 at 15:41 -0500, Trond Myklebust wrote:
> > Why can't you simply close(), and then re-open() the file? That is _the_
> > standard way to force an attribute cache revalidation on all NFS
> > versions. The close-to-open caching model, which is implemented on most
> > NFS clients guarantees this.
> 
> Interesting. Too bad this is the first time I have heard of it (where as
> I've seen fchown()/chown() suggested in several mailing lists before). I
> understood NFS FAQ's close-to-open caching description to mean only how
> data caching is handled.

No. It handles attribute caching also. In NFSv2/v3, the mtime is used to
decide whether or not the data has changed. In NFSv4 it is the change
attribute. In either case, you need to force an attribute cache
update...

> close()+open() would have been difficult to handle because open() can
> fail, but looks like opening another file descriptor and closing it
> works just as well. Also looks like it works for flushing directories'
> attribute cache (which doesn't seem to work with FreeBSD though).
> 
> There's one potential problem with closing a file descriptor though. It
> loses all fcntl locks for that file from all fds. I'm not sure if this a
> problem for me though.

Right. I understood that you were not using fcntl() locks. Those will in
any case ensure cache revalidation, so you wouldn't have to use anything
else.

> > > Also O_DIRECT is a bit too much for my use case. I do want the file  
> > > to be cached for the most part, but there are times occationally when  
> > > parts of it can be overwritten, and I need to make sure that in those  
> > > situations the newest data is read.
> > > 
> > > If you want a wider description of what I'm trying to do: I'm  
> > > developing Dovecot IMAP server. A lot of people store mails on NFS  
> > > and want to have multiple IMAP servers be able to access the mails.  
> > > Dovecot uses somewhat complex index files to speed up accessing the  
> > > mailboxes, and it's mainly for these index files that I need this  
> > > explicit control over caching. If two servers are accessing the same  
> > > mailbox at the same time, the index files get easily corrupted if I  
> > > can't control the caching.
> > 
> > So how are you ensuring that both servers don't try writing to the same
> > locations? You must have some form of synchronisation scheme for this to
> > work.
> 
> Well, there's no simple answer for that. :) There are 3 different kinds
> of index files with completely different locking behavior, because I try
> to avoid long lasting locks. I do use write locks, but reads are mainly
> lockless. There's this transaction log file which tells me when
> something has changed, so I know when data cache need to be flushed.
> 
> Anyway, all of this is working already, but I'd just like to get the
> performance a bit better with Linux by avoiding those unnecessary lock
> +unlock sequences.

Again, you can use the close-to-open trick of simply reopening the file
whenever you need to revalidate the data cache.

The problem, however, is that on the most common Linux filesystems
(ext2/ext3, reiserfs,...) the time resolution on the mtime is 1 second.
If your NFS server is running one of those filesystems, then the data
cache revalidation may fail to detect a write that happens within 1
second of the previous write.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

