From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Cache flushing
Date: Sat, 17 Nov 2007 15:41:02 -0500
Message-ID: <1195332062.6999.20.camel@localhost.localdomain>
References: <1195258291.6039.189.camel@hurina>
	<1195328785.6999.5.camel@localhost.localdomain>
	<600549E3-82CF-44EB-8394-E57A3BB41118@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Timo Sirainen <tss@iki.fi>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ItUTS-0000cU-1L
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 12:41:06 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ItUTW-0004QK-9Y
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 12:41:12 -0800
In-Reply-To: <600549E3-82CF-44EB-8394-E57A3BB41118@iki.fi>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


On Sat, 2007-11-17 at 22:12 +0200, Timo Sirainen wrote:
> On 17.11.2007, at 21.46, Trond Myklebust wrote:
> > Why is this needed?
> 
> Do you mean why is flushing attribute cache needed, or why is this  
> particular way to flush it needed?
> 
> I need to be able to find out if a file has changed, so I need to get  
> its attribute cache flushed. fchown()ing to -1, -1 would work safely  
> in all situations because it's guaranteed not to change the file in  
> any way.

Why can't you simply close(), and then re-open() the file? That is _the_
standard way to force an attribute cache revalidation on all NFS
versions. The close-to-open caching model, which is implemented on most
NFS clients guarantees this.

> Also O_DIRECT is a bit too much for my use case. I do want the file  
> to be cached for the most part, but there are times occationally when  
> parts of it can be overwritten, and I need to make sure that in those  
> situations the newest data is read.
> 
> If you want a wider description of what I'm trying to do: I'm  
> developing Dovecot IMAP server. A lot of people store mails on NFS  
> and want to have multiple IMAP servers be able to access the mails.  
> Dovecot uses somewhat complex index files to speed up accessing the  
> mailboxes, and it's mainly for these index files that I need this  
> explicit control over caching. If two servers are accessing the same  
> mailbox at the same time, the index files get easily corrupted if I  
> can't control the caching.

So how are you ensuring that both servers don't try writing to the same
locations? You must have some form of synchronisation scheme for this to
work.

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

