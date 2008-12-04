From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 1/1] NFS: map nfs_probe_fsinfo errors
Date: Thu, 4 Dec 2008 13:50:22 -0500
Message-ID: <89c397150812041050u184afda7s2d33bc1aa82b8171@mail.gmail.com>
References: <1228410550-17040-1-git-send-email-andros@netapp.com>
	 <1228411011.7475.6.camel@heimdal.trondhjem.org>
	 <1228411282.7475.9.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.186]:44461 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755564AbYLDSuZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 13:50:25 -0500
Received: by fk-out-0910.google.com with SMTP id 18so3568316fkq.5
        for <linux-nfs@vger.kernel.org>; Thu, 04 Dec 2008 10:50:22 -0800 (PST)
In-Reply-To: <1228411282.7475.9.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 4, 2008 at 12:21 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2008-12-04 at 12:16 -0500, Trond Myklebust wrote:
>> On Thu, 2008-12-04 at 12:09 -0500, andros@netapp.com wrote:
>> > From: Andy Adamson <andros@netapp.com>
>> >
>> > Callers of nfs_probe_fsinfo return ERR_PTR errors. NFSv4 errors need to be
>> > mapped.
>> >
>> > Signed-off-by: Andy Adamson <andros@netapp.com>
>> > ---
>> >  fs/nfs/client.c |    2 +-
>> >  1 files changed, 1 insertions(+), 1 deletions(-)
>> >
>> > diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>> > index 7547600..e12495c 100644
>> > --- a/fs/nfs/client.c
>> > +++ b/fs/nfs/client.c
>> > @@ -817,7 +817,7 @@ static int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, str
>> >
>> >  out_error:
>> >     dprintk("nfs_probe_fsinfo: error = %d\n", -error);
>> > -   return error;
>> > +   return nfs4_map_errors(error);
>> >  }
>> >
>> >  /*
>>
>> No. This is still in generic code that is also called by both NFSv2 and
>> v3. We should _never_ be passing NFSv4 errors this far up the stack.

Sorry it took so long.
I think I finally see your point. I'll map the errors in nfs4_proc_fsinfo.

>
> ...besides, exactly which NFSv4 specific errors are supposed to be
> leaking here? I'm not aware of any v4-specific errors that may be
> returned by fsinfo.

fsinfo is a PUTFH and a GETATTR.

v4.0 specific errors:
NFS4ERR_SERVERFAULT, NFS4ERR_FHEXPIRED, NFS4ERR_MOVED,
NFS4ERR_RESOURCE, NFS4ERR_WRONGSEC

and the one that I saw when I tried to mount a v4.0 server with a v4.1
client which caused a segfault.

NFS4ERR_MINOR_VERS_MISMATCH.

v4.1 adds all the session related errors.

-->Andy
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
