Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:39514 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751452AbdGAJej (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 1 Jul 2017 05:34:39 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 77465280892
        for <linux-nfs@vger.kernel.org>; Sat,  1 Jul 2017 11:34:37 +0200 (CEST)
Date: Sat, 1 Jul 2017 11:34:36 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        Christoph Hellwig <hch@lst.de>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        schumaker anna <schumaker.anna@gmail.com>
Message-ID: <995885135.19496849.1498901676399.JavaMail.zimbra@desy.de>
In-Reply-To: <20170630173818.GC14868@fieldses.org>
References: <20170629133453.19641-1-hch@lst.de> <20170629154650.GC1651@fieldses.org> <1498842056.6728.1.camel@primarydata.com> <20170630173818.GC14868@fieldses.org>
Subject: Re: open by handle support for NFS V2
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "J. Bruce Fields" <bfields@fieldses.org>
> To: "Trond Myklebust" <trondmy@primarydata.com>
> Cc: "Christoph Hellwig" <hch@lst.de>, "Jeff Layton" <jlayton@poochiereds.net>, "linux-nfs" <linux-nfs@vger.kernel.org>,
> "schumaker anna" <schumaker.anna@gmail.com>
> Sent: Friday, June 30, 2017 7:38:18 PM
> Subject: Re: open by handle support for NFS V2

> On Fri, Jun 30, 2017 at 05:00:59PM +0000, Trond Myklebust wrote:
>> The main use case for open by filehandle was (and still should be) the
>> promise of being able to do the sort of tricks you normally associate
>> with object storage on a standard filesystem.
>> 
>> Imagine that you are trying to build an application for indexing and
>> searching the data on your storage. You basically want to trawl through
>> the filesystem on a regular basis and build up a database of key words
>> and other metadata to tell you what is in the files. For that kind of
>> application, the namespace is a real PITA to deal with, because files
>> get renamed, moved and deleted all the time; so if you can store
>> something that is independent of the namespace and that will give you
>> access to the file contents, then why wouldn't you do so? Normally,
>> applications like that use the inode number, but you can't open a file
>> by inode number, and you have the same problems with inode number reuse
>> that a NFS server has.
>> 
>> That's the sort of thing I'd think we want to allow through open by
>> filehandle, and I see no reason why NFS should be excluded from that
>> type of application.
> 
> Thanks, that makes sense.
> 
> We've had open_by_handle support for most filesystems since 2011, is
> there evidence of anyone doing this?


I am pretty sure that nfs-ganesha is using this in one the backend
implementations.

Tigran.

> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
