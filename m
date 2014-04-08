Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:60178 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756179AbaDHSpH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Apr 2014 14:45:07 -0400
Received: by mail-ie0-f180.google.com with SMTP id as1so1374410iec.11
        for <linux-nfs@vger.kernel.org>; Tue, 08 Apr 2014 11:45:06 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: v4.0 CB_COMPOUND authentication failures
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140408142421.2a26eeaa@tlielax.poochiereds.net>
Date: Tue, 8 Apr 2014 14:45:03 -0400
Cc: Dr Fields James Bruce <bfields@fieldses.org>,
        NFS <linux-nfs@vger.kernel.org>,
        Adamson William Andros <androsadamson@gmail.com>,
        Lever Charles Edward <chuck.lever@oracle.com>
Message-Id: <D5788D48-DFEB-4323-BBCB-B9D4C4273F11@primarydata.com>
References: <20140408082140.340c1328@tlielax.poochiereds.net> <20140408123501.GA3532@fieldses.org> <20140408094903.33e42de2@tlielax.poochiereds.net> <20140408140333.GD3882@fieldses.org> <6CC79B2A-8AE2-4A36-BB57-380C2F9813C0@primarydata.com> <20140408144652.GE3882@fieldses.org> <ECD8245B-CDEE-442E-A41A-BECE08BEEDA1@primarydata.com> <20140408164024.GH3882@fieldses.org> <8F132114-F44C-449B-8EA8-331C67FCE813@primarydata.com> <20140408135512.2397d97f@tlielax.poochiereds.net> <61C732F7-A053-4293-AB54-07979E048F53@primarydata.com> <20140408142421.2a26eeaa@tlielax.poochiereds.net>
To: Layton Jeff <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 8, 2014, at 14:24, Jeff Layton <jlayton@redhat.com> wrote:

> On Tue, 8 Apr 2014 14:03:04 -0400
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
>> 
>> On Apr 8, 2014, at 13:55, Jeff Layton <jlayton@redhat.com> wrote:
>> 
>> As far as I can tell, the downcall can be extended. Even the security context is an opaque, so its length is known. If we wanted to append a field after that, we could do so without affecting backward compatibility.
>> 
> 
> Yeah, I think you're right. It looks like gss_pipe_downcall will just
> ignore stuff that trails the security context. I'll have a look at
> see whether tacking a new field on is feasible.
> 
> So in nfs4_proc_setclientid after the call, we can add some code that
> copies the new acceptor field out of gss_cred->gss_cl_ctx, and attaches
> it to a new field in the nfs_client. Alternately, I wonder if we could
> get away with just replacing the clp->cl_hostname with that value?

I don’t think we want to replace clp->cl_hostname. If someone wants to play around with the ‘-p’ option in rpc.svcgssd, then we may end up with some rather strange hostnames on the client...

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

