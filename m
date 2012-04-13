Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f174.google.com ([209.85.214.174]:35582 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756971Ab2DMXFM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Apr 2012 19:05:12 -0400
Received: by obbta14 with SMTP id ta14so1189882obb.19
        for <linux-nfs@vger.kernel.org>; Fri, 13 Apr 2012 16:05:11 -0700 (PDT)
Message-ID: <4F88B124.9030002@gmail.com>
Date: Fri, 13 Apr 2012 16:05:08 -0700
From: Dean <seattleplus@gmail.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Calvin Owens <jcalvinowens@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [GSoC Project] Implementing NFS v4.2
References: <4F7E32D4.3030201@gmail.com> <1333682276.4792.32.camel@lade.trondhjem.org>
In-Reply-To: <1333682276.4792.32.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>
>
>
> The efficient sparse file read and fadvise support might be nice too,
> but I'd like to see numbers for how they improve matters before I feel
> comfortable saying yea or nay to adding those specific features.

Instead of '...but I'd like to see...' I assume you meant, '...since I'd 
like to see...', as it would be hard to see how they improve matters 
without actually implementing them.

Although for sparse file reads, I think the low overhead design to avoid 
bloating every file upon read in NFSv4.2 makes it easy to see the 
benefit without any implementation.  For ioadvise, I think the benefit 
will be dependent upon support from the exported file system (or 
possibly nfs server).  So any prototype would have to be combined with 
appropriate support in the server file system or nfs server.

Dean
