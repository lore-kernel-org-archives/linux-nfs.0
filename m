Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36286 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751247AbaEAULM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 16:11:12 -0400
Received: by mail-pa0-f46.google.com with SMTP id kx10so1432283pab.33
        for <linux-nfs@vger.kernel.org>; Thu, 01 May 2014 13:11:11 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: idmap problems with chown as root
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <7EBFCEF4-8C76-4BF2-B04A-B70F811DCF0A@me.com>
Date: Thu, 1 May 2014 16:11:06 -0400
Cc: Dickson Steve <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <DA747BEF-5E6D-4F65-8E70-516AC8E0EC8F@primarydata.com>
References: <2541339C-AF61-4ED7-8F50-E4B3CA2C924F@me.com> <5362994C.8010900@RedHat.com> <CAHQdGtTFtJYYkhnnxmpgtY7MapL49A1+2w6NBNy3o8NOKvbXWA@mail.gmail.com> <7EBFCEF4-8C76-4BF2-B04A-B70F811DCF0A@me.com>
To: Craig Yoshioka <craigyk@me.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 1, 2014, at 16:03, Craig Yoshioka <craigyk@me.com> wrote:

>> Does the following help on the client?
>> 
>> echo N >/sys/module/nfs/parameters/nfs4_disable_idmapping
>> 
> 
> After restarting idmapd and remounting that did work.  Thanks.
> 
> It’s a good workaround until I can test the recent patch that stops mapping uid 0 to nobody.  
> 

I thought the problem was the FreeBSD server trying to idmap numeric strings and failing to do so correctly. It isn’t supposed to do that according to the NFSv4 spec.

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

