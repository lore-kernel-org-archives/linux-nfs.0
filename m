Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:52522 "EHLO smtp-o-1.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751826AbdFMTWX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Jun 2017 15:22:23 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
        by smtp-o-1.desy.de (DESY-O-1) with ESMTP id DDC3C280706
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jun 2017 21:22:20 +0200 (CEST)
Date: Tue, 13 Jun 2017 21:22:18 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Message-ID: <1087115680.14242025.1497381738583.JavaMail.zimbra@desy.de>
In-Reply-To: <CAN-5tyHeaNHVxQLnXVfQyyS20jwk0L-2UjY-pH-azM6ADQBEtQ@mail.gmail.com>
References: <991293071.14131572.1497360717136.JavaMail.zimbra@desy.de> <CAN-5tyHeaNHVxQLnXVfQyyS20jwk0L-2UjY-pH-azM6ADQBEtQ@mail.gmail.com>
Subject: Re: "nfs4_discover_server_trunking unhandled error" on Ctrl-C
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

this is 4.12.-rc4.  I will check packet capture tomorrow, however, I am pretty sure that
this is client internal interrupt processing.

Tigran.

----- Original Message -----
> From: "Olga Kornievskaia" <aglo@umich.edu>
> To: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>, "Andy Adamson" <andros@netapp.com>
> Sent: Tuesday, June 13, 2017 6:21:01 PM
> Subject: Re: "nfs4_discover_server_trunking unhandled error" on Ctrl-C

> On Tue, Jun 13, 2017 at 9:31 AM, Mkrtchyan, Tigran
> <tigran.mkrtchyan@desy.de> wrote:
>>
>> If I hit Ctrl-C during mount, then I see following message in the log file:
>>
>>  NFS: nfs4_discover_server_trunking unhandled error -512. Exiting with error EIO
>>
>>
>> produced at nfs4state.c:2533. Is this expected behavior?
> 
> What kernel version (or upstream commit) is that? Is this
> reproducible? Anything on the network trace that server returns that
> could explain an error it doesn't expect. Also I'm thinking that
> nfs_wait_client_init_complete() could be interrupted by ctrl-c and
> return ERESTARTSYS and that could translate to "unhanded error".
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
