Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57378 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753508AbcLOVL3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Dec 2016 16:11:29 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Ketan Dixit" <ketan.dixit@apcera.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 idmapping issue with AUTH_UNIX
Date: Thu, 15 Dec 2016 16:11:27 -0500
Message-ID: <C4941FBA-843B-4252-A976-18EA7BC04EA8@redhat.com>
In-Reply-To: <CAOph5DA0Wmx346Q-525iW3JUaVYA=puMv1+sznX1TLtokmqkzQ@mail.gmail.com>
References: <CAOph5DA0Wmx346Q-525iW3JUaVYA=puMv1+sznX1TLtokmqkzQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 15 Dec 2016, at 14:24, Ketan Dixit wrote:

> Hi all,
>
> I was trying the NFS idmapping functionality by creating users with
> same name but different IDs and was getting strange results the ls
> commands would show me the proper output but the chown command would
> fail.
>
> On searching the internet, I found this link
>
> http://dfusion.com.au/wiki/tiki-index.php?page=Why+NFSv4+UID+mapping+breaks+with+AUTH_UNIX
>
>
> The link basically mentions that for the authentication (identifying
> the executor of the command) it uses SunRPC and that sends uid, gid in
> integers (Not as names)  Thus chown does not work as the IDs on server
> and client differ.

There's little point in doing a chown in the first place since you can
impersonate any user you want with AUTH_SYS.  The RPCv2 spec recommends
against auth_sys for any modifications:
https://tools.ietf.org/html/rfc5531#section-14

> Is there a plan to have the RPC layer send names too, so that NFSv4
> idmapping will work in the case of AUTH_UNIX?

No, not that I know about.

> Also is it reasonable  overriding the logic in
> https://github.com/torvalds/linux/blob/29fbff8698fc0ac1a1d74584b258e0bf18b469f9/net/sunrpc/auth_unix.c#L130
> to consider a fixed offset  (in case of unprivileged containers the
> UIDs are offseted by some fixed offset like 10000) will address the
> issue?

This sounds similar to shiftfs which was discussed on linux-fsdevel a 
short
time ago..  that might be close to what you want without doing 
RPC-specific
work.  I think there were some problems, but I don't recall any details.

Ben
