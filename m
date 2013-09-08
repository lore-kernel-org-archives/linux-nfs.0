Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f53.google.com ([209.85.212.53]:46587 "EHLO
	mail-vb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719Ab3IHO0G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Sep 2013 10:26:06 -0400
Received: by mail-vb0-f53.google.com with SMTP id i3so3230514vbh.26
        for <linux-nfs@vger.kernel.org>; Sun, 08 Sep 2013 07:26:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1378481956.3332.10.camel@leira.trondhjem.org>
References: <20130905162110.GA17920@gmail.com> <20130905170303.GB17330@us.ibm.com>
 <20130905191139.GA20830@gmail.com> <1378411320.5450.27.camel@leira.trondhjem.org>
 <20130905213649.GA21944@gmail.com> <1378418243.5450.29.camel@leira.trondhjem.org>
 <20130905223420.GA23192@gmail.com> <20130906093636.6818e7b2@corrin.poochiereds.net>
 <1378479655.3332.3.camel@leira.trondhjem.org> <20130906110429.48000442@corrin.poochiereds.net>
 <1378481956.3332.10.camel@leira.trondhjem.org>
From: William Dauchy <wdauchy@gmail.com>
Date: Sun, 8 Sep 2013 16:25:44 +0200
Message-ID: <CAJ75kXa_1zvcQuaGYk0_mh-6M3VuKy7iuDO_eJYA_cM4QTY1Jg@mail.gmail.com>
Subject: Re: nfs-backed mmap file results in 1000s of WRITEs per second
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>, Quentin Barnes <qbarnes@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 6, 2013 at 5:39 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> There should be no big differences between mmapped I/O and ordinary I/O
> now that we have page_mkwrite() to set up the request. The only
> difference that I can think of offhand is when you use locking: for
> mmap() writes, NFS can only guarantee data integrity if you lock the
> entire page.

Tested the two patches on top of a 3.10.x. Looks ok so far.

-- 
William
