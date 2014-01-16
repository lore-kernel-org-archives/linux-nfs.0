Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:50221 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbaAPRZO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jan 2014 12:25:14 -0500
Received: by mail-ie0-f181.google.com with SMTP id tq11so2089329ieb.26
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jan 2014 09:25:12 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH] nfs(5): Clarify DATA AND METADATA COHERENCE section
From: Trond Myklebust <trondmy@gmail.com>
In-Reply-To: <D29E5BC8-70DF-4612-93D3-117E7D9B2BC1@oracle.com>
Date: Thu, 16 Jan 2014 12:25:09 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <67C0EBB4-AF42-44C7-B3C2-CFE29E046E17@gmail.com>
References: <20140116170841.1489.82372.stgit@seurat.1015granger.net> <EDDCEDED-2C93-460F-A5B4-91A50C44F2B7@gmail.com> <D29E5BC8-70DF-4612-93D3-117E7D9B2BC1@oracle.com>
To: Lever Charles Edward <chuck.lever@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 16, 2014, at 12:20, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Jan 16, 2014, at 12:14 PM, Trond Myklebust <trondmy@gmail.com> wrote:
> 
>> 
>> On Jan 16, 2014, at 12:09, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> How about something like this?
>> 
>> We really want something in the acregmin/max, acdirmin/max descriptions that refers to the cache coherency discussion too.
> 
> “noac” now has:
> 
>                      The DATA  AND  METADATA  COHERENCE  section  contains  a
>                      detailed discussion of these trade-offs.
> 
> “lookupcache” has:
> 
>                      The DATA  AND  METADATA  COHERENCE  section  contains  a
>                      detailed discussion of these trade-offs.
> 
> And “cto” has:
> 
>                      server changes only occasionally.  The DATA AND METADATA
>                      COHERENCE section discusses the behavior of this  option
>                      in more detail.
> 
> We can add this to ac{reg,dir}{min,max}:
> 
>                      See the DATA AND METADATA COHERENCE section for  a  full
>                      discussion of attribute caching.
> 
> Is that what you were thinking?

Yes, that should be sufficient.

Thanks!
  Trond