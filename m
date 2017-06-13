Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:35213 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750899AbdFMQVD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jun 2017 12:21:03 -0400
Received: by mail-qt0-f175.google.com with SMTP id w1so177920092qtg.2
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jun 2017 09:21:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <991293071.14131572.1497360717136.JavaMail.zimbra@desy.de>
References: <991293071.14131572.1497360717136.JavaMail.zimbra@desy.de>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 13 Jun 2017 12:21:01 -0400
Message-ID: <CAN-5tyHeaNHVxQLnXVfQyyS20jwk0L-2UjY-pH-azM6ADQBEtQ@mail.gmail.com>
Subject: Re: "nfs4_discover_server_trunking unhandled error" on Ctrl-C
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 13, 2017 at 9:31 AM, Mkrtchyan, Tigran
<tigran.mkrtchyan@desy.de> wrote:
>
> If I hit Ctrl-C during mount, then I see following message in the log file:
>
>  NFS: nfs4_discover_server_trunking unhandled error -512. Exiting with error EIO
>
>
> produced at nfs4state.c:2533. Is this expected behavior?

What kernel version (or upstream commit) is that? Is this
reproducible? Anything on the network trace that server returns that
could explain an error it doesn't expect. Also I'm thinking that
nfs_wait_client_init_complete() could be interrupted by ctrl-c and
return ERESTARTSYS and that could translate to "unhanded error".
