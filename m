Return-Path: <SRS0=FZjK=ZO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25C03C432C0
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Nov 2019 16:27:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F03C820714
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Nov 2019 16:27:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GKVt+sqq"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726705AbfKVQ1N (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Nov 2019 11:27:13 -0500
Received: from mail-wr1-f65.google.com ([209.85.221.65]:37918 "EHLO
        mail-wr1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726664AbfKVQ1N (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Nov 2019 11:27:13 -0500
Received: by mail-wr1-f65.google.com with SMTP id i12so9328734wro.5
        for <linux-nfs@vger.kernel.org>; Fri, 22 Nov 2019 08:27:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=rl2ryMHKtRg5FMKlXbQ08a+V2KrKF6g8Ox6urptdp2k=;
        b=GKVt+sqqYfeb/Gzb+p7fgJFyQFI/LxmPs9e9viSvrYiRUgQT5fK2HA6th/feyeVOTn
         T+K+7PPbgAAeGdvgHzjf60mvGRR4MEkrPagTeMXQaOgVm8PrmM5bFhJQLAYD8E4e0Kw4
         RI/gAYtKefNMhfoyyd3XKLjMExjCdxF+RjF5LNA2yL5P9fCYwG1qBLbx5eSUoxU8jLnC
         FMZW3xCetzly/2UMGnWW7BjONgClhXhafcxkOE8ULMDaxeoQVwBxaJWXfeinjAz+iWpr
         10geALi3YWslzWxbF51fV2cdnR6ZPAtDrNbPg3tGGmcq0IJj4TH1/NysPMJMnehEswJU
         sO/A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:reply-to
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=rl2ryMHKtRg5FMKlXbQ08a+V2KrKF6g8Ox6urptdp2k=;
        b=Ci4gE1MiiX0UZYpqLW0H9Z9Bts904H9xc9SsEImiWcpq3zgF9g7i9hHjPy+fGDnid2
         AuYAgdwrzDcp7hxJKNw/qt8uQhZc299SG8YfPxlTCaBn7iijaooCnpUISD5x5OpKWwD9
         XyUE1UY7CY/tWQF+haGkP098VvhABTuB/oHMsseoWKXsVzK3YFS274pukRVoKLLc5ktN
         P7zfsaFjYe+Yq7BAmHG2alsJkbT6qP2bVpQY8ZvJ+zlLW2Z7eUGE2kQ83Qr6i+jh7SD8
         1WRNmDLlLjDWDE64V0bK5kloHFHqFYRCajoKI7bkJqbpP8/SE9CKGSi3ElmAh2xB6yNy
         w8yw==
X-Gm-Message-State: APjAAAWYMnCqtKtQ1Ciknj7ghnOdEyzSCClatVbTGWShSpbstOvdF4Lg
        ac3TojfKWL7S0jDEUnnL5nk=
X-Google-Smtp-Source: APXvYqxlguB+owVTBkg1ym/qRpXz9qQlUTI8bBL7RoDjOe3WfS1KuyK8ueYgFnLE8gR+5xzdnyVkeg==
X-Received: by 2002:a05:6000:18e:: with SMTP id p14mr18515432wrx.98.1574440031173;
        Fri, 22 Nov 2019 08:27:11 -0800 (PST)
Received: from dell5510 ([178.21.189.11])
        by smtp.gmail.com with ESMTPSA id p9sm8035601wrs.55.2019.11.22.08.27.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 22 Nov 2019 08:27:10 -0800 (PST)
Date:   Fri, 22 Nov 2019 17:27:08 +0100
From:   Petr Vorel <petr.vorel@gmail.com>
To:     Steve Dickson <SteveD@redhat.com>
Cc:     linux-nfs@vger.kernel.org, Joey Hess <joeyh@debian.org>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [nfs-utils PATCH 1/1] mount: Do not overwrite /etc/mtab if it's
 symlink
Message-ID: <20191122162708.GB4477@dell5510>
Reply-To: Petr Vorel <petr.vorel@gmail.com>
References: <20191120183529.29366-1-petr.vorel@gmail.com>
 <938c3cf9-0584-d6b9-b3a1-ec12795761c5@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <938c3cf9-0584-d6b9-b3a1-ec12795761c5@RedHat.com>
User-Agent: Mutt/1.12.2 (2019-09-21)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Steve,

> On 11/20/19 1:35 PM, Petr Vorel wrote:
> > From: Joey Hess <joeyh@debian.org>

> > Some systems have /etc/mtab symlink to /proc/mounts. In that case
> > mount.nfs complains:
> > Can't set permissions on mtab: Operation not permitted

> > See https://bugs.debian.org/476577

> > This change makes mount.nfs handle symlinked /etc/mtab the way
> > umount.nfs and util- linux handle it.

> > Cc: Chuck Lever <chuck.lever@oracle.com>
> > Signed-off-by: Joey Hess <joeyh@debian.org>
> > [ pvorel: took patch from Debian, rebased for 2.4.3-rc1 and created commit
> > message. Patch is also used in Gentoo. ]
> > Signed-off-by: Petr Vorel <petr.vorel@gmail.com>
> Committed... (tag: nfs-utils-2-4-3-rc2)
I'm sorry for introducing a regression.

Send a patch fixing this.
https://patchwork.kernel.org/patch/11258155/

> steved.

Kind regards,
Petr
