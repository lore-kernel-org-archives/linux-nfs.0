Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:35868 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934874Ab2JXP3V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2012 11:29:21 -0400
Received: by mail-qc0-f174.google.com with SMTP id o22so345865qcr.19
        for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 08:29:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90928F4E6@SACEXCMBX04-PRD.hq.netapp.com>
References: <CAFukC=5Mq3CwK=u7YP_=cF6gab+0K_mP-Sj0k8fCk_a2f=xsfg@mail.gmail.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928F4E6@SACEXCMBX04-PRD.hq.netapp.com>
From: Brock Noland <brock@cloudera.com>
Date: Wed, 24 Oct 2012 10:29:00 -0500
Message-ID: <CAFukC=6CW7bup1CtBkPYYotETswqwDHf9RcxYptwnSPP+SL25g@mail.gmail.com>
Subject: Re: readdir from Linux NFS4 client when cookieverf is no longer valid
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 24, 2012 at 7:42 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
...
>
> Until the recovery question is answered, the Linux client will continue to ignore the whole "cookie verifier" junk...

OK perfect, this is exactly what I needed to know. Thanks!

Brock
