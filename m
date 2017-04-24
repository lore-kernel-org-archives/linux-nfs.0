Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helmsgagent01.f-secure.com ([193.110.108.21]:57164 "EHLO
        helmsgagent01.f-secure.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1165670AbdDXHk4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Apr 2017 03:40:56 -0400
From: Marko Rauhamaa <marko.rauhamaa@f-secure.com>
To: Amir Goldstein <amir73il@gmail.com>
CC: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>,
        Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        <linux-api@vger.kernel.org>
Subject: Re: fanotify read returns with errno == EOPENSTALE
References: <20170322193122.GV29622@ZenIV.linux.org.uk>
        <CAOQ4uxhTd1j4HLgZFTdr7wwrhjzkVT8QeoXjca_AMZmYHF31sQ@mail.gmail.com>
        <87a88c2yxq.fsf@drapion.f-secure.com>
        <CAOQ4uxggwSDcjdyCDreKs7m0ZNy+6PQQNojm6qDU7mH2tQE-Bw@mail.gmail.com>
        <1490270212.3921.10.camel@poochiereds.net>
        <8760j02mfz.fsf@drapion.f-secure.com>
        <CAOQ4uxja14p02jQurLTGv_fHrs+UBa5qfacrgY_-7tyv6UJqdw@mail.gmail.com>
        <87lgqwa4tg.fsf@drapion.f-secure.com>
        <CAOQ4uxirSfVVYBexXrWccDHnE5oqxNgUh3-X5Ey1w4R=nHXDjA@mail.gmail.com>
        <CAOQ4uxjA8Z7wnwuHFCKeKT1xz0Gh-qS40Y6cfPi3fAM0MKsRuQ@mail.gmail.com>
        <20170420142035.GE22135@quack2.suse.cz>
        <CAOQ4uxgAOJjWP6PHY6WgOkNK0vmaTWnFZN+Jvea7zpjJ_VU8Bw@mail.gmail.com>
        <CAOQ4uxgkXz+8=m2o_faAh2g2Z21KhAf67WckgPNWhktz1=DaWA@mail.gmail.com>
Date: Mon, 24 Apr 2017 10:40:50 +0300
In-Reply-To: <CAOQ4uxgkXz+8=m2o_faAh2g2Z21KhAf67WckgPNWhktz1=DaWA@mail.gmail.com>
        (Amir Goldstein's message of "Sat, 22 Apr 2017 10:22:20 +0300")
Message-ID: <87shky6ynx.fsf@drapion.f-secure.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Amir Goldstein <amir73il@gmail.com>:

> Were you able to verify that both blocking and non-blocking mode work
> correctly? May I add your Tested-by and Reported-by tags?

I have only verified the nonblocking case in my tests (which are by no
means extensive). The reported issue can no longer be reproduced with
the patched kernel, and the regular OPEN_PERM function is still
operational.

Feel free to add me to the tags.


Marko
