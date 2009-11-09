From: Ivan Yosifov <iyosifov@gmail.com>
Subject: Re: Question: NFS behaviour in case of concurrent local and remote
 access
Date: Mon, 09 Nov 2009 17:13:10 +0200
Message-ID: <1257779590.9200.28.camel@home.yosifov.net>
References: <1257770569.7276.31.camel@home.yosifov.net>
	 <1257773136.3754.17.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:37033 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702AbZKIPNI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Nov 2009 10:13:08 -0500
Received: by bwz27 with SMTP id 27so3552626bwz.21
        for <linux-nfs@vger.kernel.org>; Mon, 09 Nov 2009 07:13:13 -0800 (PST)
In-Reply-To: <1257773136.3754.17.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-11-09 at 08:25 -0500, Trond Myklebust wrote:
> On Mon, 2009-11-09 at 14:42 +0200, Ivan Yosifov wrote:
> > Hi everyone,
> > 
> > I'm new to NFS and am trying to understand how to use it safely and
> > correctly.
> > 
> > The situation I'm considering is following. There's a server with an
> > ( ext4 if it matters ) local volume that's exported through NFSv4. There
> > are expected to be both remote ( ie. over the NFS ) read/write clients
> > and local ones that write to the volume directly ( ie. not thorough the
> > NFS ).
> > 
> > Assuming well-behaved clients, ie. no interleaved open()...close() on
> > the same file, how will NFS handle this ? Will close-to-open consistency
> > continue to work, will it interfere with delegations ?
> > 
> > Pointers or thoughts greatly appreciated.
> 
> The NFS expectation is that if one application is writing to a file
> while another is holding it open, then the two applications will use
> locking in order to synchronise their access.

So I understood. So far so good.

> As long as all applications adhere to this rule, then you are supposed
> to be guaranteed cache consistency. It shouldn't matter if the
> applications are running on the server or on another client.

> Cheers
>    Trond
> 

Sounds encouraging. Just to clarify, I assume local writers don't pass
through NFS. 

Out of curiosity, do you know how it's implemented ? 

I looked at fs/nfsd and fs/nfs in the kernel source but didn't really
understand a lot. I got the impression that nfs clients and the server
pass nfsd4_change_info objects ( defined in include/linux/nfsd/xdr4.h )
around with the before_change and after_change fields being "file
version" of sorts - ie. they are changed when the file is changed and
don't depend on timestamp resolution or anything like that.

My concern is that the normal fs has only timestamps ( right ? ) which
have a finite resolution and can't be used as file version indicators.
So it seems necessary for the normal fs code to notify the NFS code for
every write/change to a file that's also opened through NFS. Such a
tight coupling both seems hard to get and I didn't notice anything like
it in the source. 

Thanks,
Ivan




