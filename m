Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail03-md.ns.itscom.net ([175.177.155.113]:35145 "EHLO
        mail03-md.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752998AbcIESzw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2016 14:55:52 -0400
From: "J. R. Okajima" <hooanon05g@gmail.com>
Subject: Re: 4.8-rcN nfs, access(W_OK) on an immutable inode
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
In-Reply-To: <D2C9D52A-1C3D-491E-9C90-205B2B85F284@primarydata.com>
References: <3647.1472877116@jrobl> <24930.1473095997@jrobl> <D2C9D52A-1C3D-491E-9C90-205B2B85F284@primarydata.com>
Date: Tue, 06 Sep 2016 03:55:49 +0900
Message-ID: <27139.1473101749@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Trond Myklebust:
> The NFS protocol has no way to convey to the client that the inode is label=
> ed as immutable on the server. The NFSv4.1 =93retention_hold=94 mechanism d=
> escribed in RFC5661 comes close, and could possibly be used, but it is not =
> implemented for now.
>
> Note also that file immutability is not a POSIX concept, and EPERM is conse=
> quently not listed as one of the POSIX sanctioned return values for access(=
> ): http://pubs.opengroup.org/onlinepubs/9699919799/functions/access.html

Ok.
Thanx for the explanation.


J. R. Okajima
