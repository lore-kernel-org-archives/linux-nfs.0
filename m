Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f181.google.com ([209.85.220.181]:44942 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702AbaGGMgC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jul 2014 08:36:02 -0400
Received: by mail-vc0-f181.google.com with SMTP id il7so3764854vcb.26
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jul 2014 05:36:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <lp1gar$eb6$1@ger.gmane.org>
References: <lp1gar$eb6$1@ger.gmane.org>
Date: Mon, 7 Jul 2014 08:36:00 -0400
Message-ID: <CAHVgHyVjoVb--cfbaopoUYA4vbDCjufJVng6OM2e82q0yEMthA@mail.gmail.com>
Subject: Re: NFSv4 cross-realm support
From: Andy Adamson <androsadamson@gmail.com>
To: Jaap Winius <jwinius@umrk.nl>
Cc: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

I have a personal IETF draft that deals with some of the NFSv4 cross
realm issues. This is a good place to start.

http://datatracker.ietf.org/doc/draft-adamson-nfsv4-multi-domain-federated-fs-reqs/


On Wed, Jul 2, 2014 at 1:42 PM, Jaap Winius <jwinius@umrk.nl> wrote:
> Hi folks,
>
> Recently I've been working on cross-realm support to give my own MIT
> Kerberos realm, UMRK.NL, access to the services of a realm that I manage.
> All systems involved run Debian wheezy. So far, SSH, OpenLDAP, OpenAFS
> and Dovecot IMAP are all working properly this way, but NFSv4 with
> sec=krb5i is not; I keep getting "Permission denied" when attempting to
> read or write to any file or directory that is not globally accessible.
>
> When the log output verbosity for rpc.gssd and rpc.svcgssd is increased
> about as far as it will go (-vvvvv), little is different when things go
> wrong, other than this one line produced by rpc.svcgssd on the server:
>
>   nss_gss_princ_to_ids: Local-Realm 'UMRK.NL': NOT FOUND
>
> However, even that seems a bit misleading, because the log output for
> rpc.idmapd (with Verbosity = 5) shows that the user and group IDs for my
> account are being identified properly.
>
> Should I prepare a bug report for this issue, or does cross-realm support
> for NFSv4 require something extra?

So you are supporting two Kerberos realms under one NFSv4 domain? You
are using LDAP for id mapping?

Which version of nfs-utils and which client kernel?

e.g.

# rpm -qa | grep nfs-utils
# uname -a

-->Andy

>
> Thanks,
>
> Jaap
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
