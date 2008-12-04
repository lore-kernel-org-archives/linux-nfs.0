From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 1/1] NFS: map nfs_probe_fsinfo errors
Date: Thu, 4 Dec 2008 14:16:19 -0500
Message-ID: <89c397150812041116t74692ca1k5ce2ca87e64b5a2b@mail.gmail.com>
References: <1228410550-17040-1-git-send-email-andros@netapp.com>
	 <1228411011.7475.6.camel@heimdal.trondhjem.org>
	 <1228411282.7475.9.camel@heimdal.trondhjem.org>
	 <89c397150812041050u184afda7s2d33bc1aa82b8171@mail.gmail.com>
	 <1228417616.7475.16.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:41852 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbYLDTQV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 14:16:21 -0500
Received: by fg-out-1718.google.com with SMTP id 19so2915594fgg.17
        for <linux-nfs@vger.kernel.org>; Thu, 04 Dec 2008 11:16:19 -0800 (PST)
In-Reply-To: <1228417616.7475.16.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 4, 2008 at 2:06 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2008-12-04 at 13:50 -0500, William A. (Andy) Adamson wrote:
>> fsinfo is a PUTFH and a GETATTR.
>>
>> v4.0 specific errors:
>> NFS4ERR_SERVERFAULT, NFS4ERR_FHEXPIRED, NFS4ERR_MOVED,
>> NFS4ERR_RESOURCE, NFS4ERR_WRONGSEC
>
> Should all be either handled or else mapped into generic errors by the
> call to nfs4_handle_exception in nfs4_do_fsinfo().
>
>> and the one that I saw when I tried to mount a v4.0 server with a v4.1
>> client which caused a segfault.
>>
>> NFS4ERR_MINOR_VERS_MISMATCH.
>
> Should never happen on a v4.0 client...
>
>> v4.1 adds all the session related errors.
>
> Those should be handled and/or mapped by the call to
> nfs4_handle_exception() in nfs4_do_fsinfo().


OK - Thanks.

-->Andy
>
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
