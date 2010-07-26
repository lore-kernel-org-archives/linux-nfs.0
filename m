From: Yudong Gao <stgyd@umich.edu>
Subject: Re: config delegation lease time
Date: Mon, 26 Jul 2010 10:14:30 -0700
Message-ID: <AANLkTikb+8LuFFDrSW5AE+ZKYuR_tP94wKb5UoJHiwro@mail.gmail.com>
References: <AANLkTikMa7FzBewHyZ=7Pxrf=EmKU3jb8y9hrO+QhfWd@mail.gmail.com>
	<1279935504.5268.23.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:57835 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816Ab0GZROw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Jul 2010 13:14:52 -0400
Received: by vws3 with SMTP id 3so2596826vws.19
        for <linux-nfs@vger.kernel.org>; Mon, 26 Jul 2010 10:14:51 -0700 (PDT)
In-Reply-To: <1279935504.5268.23.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I see. Thanks a lot for the pointer, Trond!

Is there a through document about all the available configurations?

Thanks!

best,

Yudong

On Fri, Jul 23, 2010 at 6:38 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Fri, 2010-07-23 at 17:29 -0700, Yudong Gao wrote:
>> Hi,
>>
>> I am trying to change the delegation lease time in NFS4.1, but I can
>> not find any documentation talking about this.
>>
>> Do I need to change the source code directly to change the lease time?
>
> Change the contents of /proc/fs/nfsd/nfsv4leasetime on the server.
>
> Trond
>
>
