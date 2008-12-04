From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 1/1] NFS: map nfs_probe_fsinfo errors
Date: Thu, 4 Dec 2008 15:31:39 -0500
Message-ID: <89c397150812041231v4eeeb6a4y5106b7db9b53c037@mail.gmail.com>
References: <1228410550-17040-1-git-send-email-andros@netapp.com>
	 <1228411011.7475.6.camel@heimdal.trondhjem.org>
	 <1228411282.7475.9.camel@heimdal.trondhjem.org>
	 <89c397150812041050u184afda7s2d33bc1aa82b8171@mail.gmail.com>
	 <1228417616.7475.16.camel@heimdal.trondhjem.org>
	 <89c397150812041116t74692ca1k5ce2ca87e64b5a2b@mail.gmail.com>
	 <1228420665.7475.19.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:4221 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754596AbYLDUbl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 15:31:41 -0500
Received: by fg-out-1718.google.com with SMTP id 19so2933332fgg.17
        for <linux-nfs@vger.kernel.org>; Thu, 04 Dec 2008 12:31:40 -0800 (PST)
In-Reply-To: <1228420665.7475.19.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

How about -EPROTONOSUPPORT?

On Thu, Dec 4, 2008 at 2:57 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2008-12-04 at 14:16 -0500, William A. (Andy) Adamson wrote:
>> >> and the one that I saw when I tried to mount a v4.0 server with a v4.1
>> >> client which caused a segfault.
>> >>
>> >> NFS4ERR_MINOR_VERS_MISMATCH.
>> >
>> > Should never happen on a v4.0 client...
>
> Hmm...
>
> That said, it wouldn't harm to add the MINOR_VERS_MISMATCH error to
> nfs_errtbl[]. I suppose the only thing we can do is to map it to EIO,
> but that would be better than letting it slip through the cracks...
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
