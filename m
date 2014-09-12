Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:56197 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070AbaILCYN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2014 22:24:13 -0400
Received: by mail-qa0-f50.google.com with SMTP id dc16so87602qab.37
        for <linux-nfs@vger.kernel.org>; Thu, 11 Sep 2014 19:24:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140911201148.GA6623@infradead.org>
References: <1410447752-11288-1-git-send-email-tao.peng@primarydata.com> <20140911201148.GA6623@infradead.org>
From: Peng Tao <tao.peng@primarydata.com>
Date: Fri, 12 Sep 2014 10:23:48 +0800
Message-ID: <CAKVebiVNg+jG+QvvQEMiHfq8vzYAAY44cEbOgk7APbCmSbzeCA@mail.gmail.com>
Subject: Re: [PATCH] nfs41: change PNFS_LAYOUTRET_ON_SETATTR to only return on chown/truncate
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>, Boaz Harrosh <boaz@plexistor.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 12, 2014 at 4:11 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Thu, Sep 11, 2014 at 11:02:32PM +0800, Peng Tao wrote:
>> Both blocks layout and objects layout want to use it to avoid CB_LAYOUTRECALL
>> but that should only happen if client is doing chown or truncate. So change
>> PNFS_LAYOUTRET_ON_SETATTR to follow the logic and not to send layoutreturn
>> unnecessarily.
>
> We should defintively reduce the amount of returns, but why do we even
> bother and chown and a truncate to a larger size?
hmm, I agree. Let's only layoutreturn on truncate to a smaller size
and let server decide if it needs CB_LAYOUTRECALL in chown.
