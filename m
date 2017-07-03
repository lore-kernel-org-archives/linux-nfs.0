Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sainfoin-smtp-out.extra.cea.fr ([132.167.192.228]:51752 "EHLO
        sainfoin-smtp-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750861AbdGCGo5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Jul 2017 02:44:57 -0400
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
        by sainfoin-sys.extra.cea.fr (8.14.7/8.14.7/CEAnet-Internet-out-4.0) with ESMTP id v636dYQW020921
        for <linux-nfs@vger.kernel.org>; Mon, 3 Jul 2017 08:39:34 +0200
Received: from pisaure.intra.cea.fr (localhost [127.0.0.1])
        by localhost (Postfix) with SMTP id 3774720623F
        for <linux-nfs@vger.kernel.org>; Mon,  3 Jul 2017 08:39:34 +0200 (CEST)
Received: from muguet1.intra.cea.fr (muguet1.intra.cea.fr [132.166.192.6])
        by pisaure.intra.cea.fr (Postfix) with ESMTP id 2E6A72061F0
        for <linux-nfs@vger.kernel.org>; Mon,  3 Jul 2017 08:39:34 +0200 (CEST)
Received: from zia.cdc.esteban.ctsi (out.dam.intra.cea.fr [132.165.76.10])
        by muguet1.intra.cea.fr (8.15.2/8.15.2/CEAnet-Intranet-out-1.4) with SMTP id v636dXJ4024406
        for <linux-nfs@vger.kernel.org>; Mon, 3 Jul 2017 08:39:33 +0200
Subject: Re: open by handle support for NFS V2
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <trondmy@primarydata.com>,
        Christoph Hellwig <hch@lst.de>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        schumaker anna <schumaker.anna@gmail.com>
References: <20170629133453.19641-1-hch@lst.de>
 <20170629154650.GC1651@fieldses.org>
 <1498842056.6728.1.camel@primarydata.com>
 <20170630173818.GC14868@fieldses.org>
 <995885135.19496849.1498901676399.JavaMail.zimbra@desy.de>
From: DENIEL Philippe <philippe.deniel@cea.fr>
Message-ID: <d800776d-722a-0f20-5616-4d236e9d6130@cea.fr>
Date: Mon, 3 Jul 2017 08:39:32 +0200
MIME-Version: 1.0
In-Reply-To: <995885135.19496849.1498901676399.JavaMail.zimbra@desy.de>
Content-Type: text/plain; charset="utf-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/01/17 11:34, Mkrtchyan, Tigran wrote:
>
> ----- Original Message -----
>> From: "J. Bruce Fields" <bfields@fieldses.org>
>> To: "Trond Myklebust" <trondmy@primarydata.com>
>> Cc: "Christoph Hellwig" <hch@lst.de>, "Jeff Layton" <jlayton@poochiereds.net>, "linux-nfs" <linux-nfs@vger.kernel.org>,
>> "schumaker anna" <schumaker.anna@gmail.com>
>> Sent: Friday, June 30, 2017 7:38:18 PM
>> Subject: Re: open by handle support for NFS V2
>> On Fri, Jun 30, 2017 at 05:00:59PM +0000, Trond Myklebust wrote:
>>> The main use case for open by filehandle was (and still should be) the
>>> promise of being able to do the sort of tricks you normally associate
>>> with object storage on a standard filesystem.
>>>
>>> Imagine that you are trying to build an application for indexing and
>>> searching the data on your storage. You basically want to trawl through
>>> the filesystem on a regular basis and build up a database of key words
>>> and other metadata to tell you what is in the files. For that kind of
>>> application, the namespace is a real PITA to deal with, because files
>>> get renamed, moved and deleted all the time; so if you can store
>>> something that is independent of the namespace and that will give you
>>> access to the file contents, then why wouldn't you do so? Normally,
>>> applications like that use the inode number, but you can't open a file
>>> by inode number, and you have the same problems with inode number reuse
>>> that a NFS server has.
>>>
>>> That's the sort of thing I'd think we want to allow through open by
>>> filehandle, and I see no reason why NFS should be excluded from that
>>> type of application.
>> Thanks, that makes sense.
>>
>> We've had open_by_handle support for most filesystems since 2011, is
>> there evidence of anyone doing this?
>
> I am pretty sure that nfs-ganesha is using this in one the backend
> implementations.
>
> Tigran.
Tigran is right: nfs-ganesha does something a bit similar to this in its 
"FSAL_VFS" module (the backed module based the usage of on 
open_by_handle_at() and name_to_handle_at() ).

     regards

         Philippe

>
>> --b.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


