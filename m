Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f43.google.com ([74.125.82.43]:64186 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756618AbaJXP7t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2014 11:59:49 -0400
Received: by mail-wg0-f43.google.com with SMTP id n12so1395445wgh.26
        for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2014 08:59:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141024105758.064f2e14@tlielax.poochiereds.net>
References: <CAHQdGtQM7E37gFeLopQiNcvC+QH7MPVMdYnwYhScL65rq=xHxQ@mail.gmail.com>
	<1414145308-11196-1-git-send-email-trond.myklebust@primarydata.com>
	<20141024072644.6643f9ed@tlielax.poochiereds.net>
	<20141024093459.70a29d80@tlielax.poochiereds.net>
	<1414161055.21776.2.camel@leira.trondhjem.org>
	<20141024105758.064f2e14@tlielax.poochiereds.net>
Date: Fri, 24 Oct 2014 18:59:47 +0300
Message-ID: <CAHQdGtTt23DBM3YH295T_eUvq6ymNere7OfDR9VNFyB3Xsfcsw@mail.gmail.com>
Subject: Re: [PATCH] nfsd: Ensure that NFSv4 always drops the connection when
 dropping a request
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Bruce Fields <bfields@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 24, 2014 at 5:57 PM, Jeff Layton
<jeff.layton@primarydata.com> wrote:
>> @@ -1228,6 +1231,8 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
>>   dropit:
>>       svc_authorise(rqstp);   /* doesn't hurt to call this twice */
>>       dprintk("svc: svc_process dropit\n");
>
> I don't think this will fix it either. I turned the above dprintk into
> a normal printk and it never fired during the test. As best I can tell,
> svc_process_common is not returning 0 when this occurs.

OK. Is perhaps the "revisit canceled" triggering in svc_revisit()? I'm
having trouble understanding the call chain for that stuff, but it too
looks as if it can trigger some strange behaviour.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
