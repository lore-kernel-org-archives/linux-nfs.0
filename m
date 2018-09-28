Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io1-f65.google.com ([209.85.166.65]:46280 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726665AbeI1U6R (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Sep 2018 16:58:17 -0400
Received: by mail-io1-f65.google.com with SMTP id y12-v6so4268198ioj.13
        for <linux-nfs@vger.kernel.org>; Fri, 28 Sep 2018 07:34:12 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
Message-ID: <99a34fd0ef40f5bdfe61b1ec25b210239224066c.camel@hammerspace.com>
Subject: Re: osd_login
To: Steve Dickson <SteveD@RedHat.com>, linux-nfs@vger.kernel.org
In-Reply-To: <ca5c1a1d-9d8b-b1c8-3882-7f6b09ad1487@RedHat.com>
References: <114a207b-9fb8-0216-1ad5-e49f7f4500ad@RedHat.com>
         <ca5c1a1d-9d8b-b1c8-3882-7f6b09ad1487@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Date: Fri, 28 Sep 2018 10:33:04 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2018-09-28 at 09:19 -0400, Steve Dickson wrote:
> 
> On 9/13/18 11:47 AM, Steve Dickson wrote:
> > Hello,
> > 
> > Is the osd_login shell script use anymore?
> > 
> > Would it be a problem if it goes away?
> 
> I'm going to assume remove this will not be a problem... 
> 

The OSD code has already been removed from the kernel, so anyone who
may be using it (nobody has admitted to doing so yet) is already using
legacy systems.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trond.myklebust@hammerspace.com
