Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f171.google.com ([209.85.217.171]:35763 "EHLO
        mail-ua0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751801AbdGFOZL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Jul 2017 10:25:11 -0400
Received: by mail-ua0-f171.google.com with SMTP id j53so2485660uaa.2
        for <linux-nfs@vger.kernel.org>; Thu, 06 Jul 2017 07:25:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1499288361.63624.2.camel@primarydata.com>
References: <20170628144758.12225-1-trond.myklebust@primarydata.com>
 <20170702085354.GA20685@kroah.com> <CAFHi+KQShB-m6GT87uKO=KN0AF-1t0+uXbW7UE2NFyi_wOSLDg@mail.gmail.com>
 <1499288361.63624.2.camel@primarydata.com>
From: Robert Kudyba <rkudyba@fordham.edu>
Date: Thu, 6 Jul 2017 10:24:54 -0400
Message-ID: <CAFHi+KTpg8MKWH60-R9NqdjFhYyVeFKY5JrU1Ezw-kgDXNcEYg@mail.gmail.com>
Subject: Re: [PATCH] Stable request to fix a reference leak and list corruption
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "greg@kroah.com" <greg@kroah.com>,
        "kinglongmee@gmail.com" <kinglongmee@gmail.com>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> > > Could we please queue up the following patch as a stable fix for
>> > > commit a974deee47? It needs to be applied to v4.10 and older.
>> >
>> > Now applied, thanks.
>>
>> Until kernel 4.11.9 is into Fedora's updates, I downgraded our server
>> acting as the NIS master to 4.10.16-200. But all NIS users time out
>> with "ypserv: #011-> Error #-3. Could this be a different issue with
>> rpcbind or nfs-utils? Here are some debug enabled logs for RPC with a
>> different error "xs_error_report client ffff8d8223caa000, error=113"
>>
>
> Error 113 is EHOSTUNREACH. It means that either your server is down, or
> there is some other networking issue that is preventing the client from
> connecting to it (e.g. a firewall setting, route configuration, arp
> cache pollution?). Either way, it is unrelated to this particular
> patch.

Ahh indeed it was firewalld. Not sure why this just cropped up,
perhaps some update? Anyways once I ran:

firewall-cmd --permanent --add-service=nfs
firewall-cmd --permanent --add-service=mountd
firewall-cmd --permanent --add-service=rpc-bind
firewall-cmd --reload

We were back in business with NFS sharing. Thanks so much for the
reply & hint as I couldn't find what error 113 meant.
