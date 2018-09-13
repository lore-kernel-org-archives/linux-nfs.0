Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pl1-f195.google.com ([209.85.214.195]:37634 "EHLO
        mail-pl1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726950AbeIMXlS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Sep 2018 19:41:18 -0400
MIME-Version: 1.0
References: <17451.1536750676@warthog.procyon.org.uk> <87lg854ws2.fsf@suse.com>
In-Reply-To: <87lg854ws2.fsf@suse.com>
From: Steve French <smfrench@gmail.com>
Date: Thu, 13 Sep 2018 11:30:26 -0700
Message-ID: <CAH2r5mu72XVSBp48BYWcg_tmioC8feHmwzNM8UnzaZ=g3g9UZw@mail.gmail.com>
Subject: Re: Making the in-kernel DNS resolver handle server lists
To: =?UTF-8?Q?Aur=C3=A9lien_Aptel?= <aaptel@suse.com>
Cc: David Howells <dhowells@redhat.com>,
        trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Steve French <sfrench@samba.org>, linux-nfs@vger.kernel.org,
        CIFS <linux-cifs@vger.kernel.org>, linux-afs@lists.infradead.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 13, 2018 at 1:39 AM Aur=C3=A9lien Aptel <aaptel@suse.com> wrote=
:
>
> David Howells <dhowells@redhat.com> writes:
> > Is this something that NFS or CIFS (or anything else for that matter) c=
ould
> > find useful?
>
> That sounds useful indeed. I'm currently thinking about a failover
> mechanism for DFS (symbolic links across servers in cifs). The protocol
> supports multiple possible targets for the link in case one is down. The
> targets are usually using hostnames so with your change we could have a
> second layer of failover at the DNS level.
>
> > I also have this loading information from a configuration file as a
> > backup/override of the DNS.  Could that also be useful to NFS/CIFS?
>
> Cheers,
> --
> Aur=C3=A9lien Aptel / SUSE Labs Samba Team

Yes - the idea that Aurelien notes above is VERY important for some
improving some recovery scenarios, and if this helps us get there
faster it will greatly improve reliability of some common user scenarios.



--=20
Thanks,

Steve
