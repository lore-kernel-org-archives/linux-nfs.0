Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f178.google.com ([209.85.220.178]:52890 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756395AbaIIOks (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 10:40:48 -0400
Received: by mail-vc0-f178.google.com with SMTP id hy4so2393150vcb.23
        for <linux-nfs@vger.kernel.org>; Tue, 09 Sep 2014 07:40:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140909055402.GB12536@lst.de>
References: <1408637375-11343-1-git-send-email-hch@lst.de>
	<20140821161338.GA31352@infradead.org>
	<CAHQdGtToLV08oRhfnEMwvxAsL3CeiU55GUxYC9iZvyuUDZ9fCA@mail.gmail.com>
	<20140909055402.GB12536@lst.de>
Date: Tue, 9 Sep 2014 07:40:47 -0700
Message-ID: <CAHQdGtTpzjuOYeUtn9yYSuXho_oWDDDLaYg5VYMMRwo2gS__8g@mail.gmail.com>
Subject: Re: pnfs block layout driver fixes V2
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 8, 2014 at 10:54 PM, Christoph Hellwig <hch@lst.de> wrote:
> On Mon, Sep 08, 2014 at 09:12:01PM -0700, Trond Myklebust wrote:
>> Applying all patches except the ones for which I explicitly sent you
>> an email with questions and/or a notification of a dependency on a
>> questioned patch.
>
> Might be easier to just resend the whole series as there's quite a few
> dependencies.  But if you push out a tree with the applied patches I can
> just rebase against that.
>

Done. Please see
git://git.linux-nfs.org/projects/trondmy/linux-nfs.git with branch
linux-next.

Cheers
  Trond
-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
