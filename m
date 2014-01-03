Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f47.google.com ([209.85.212.47]:36428 "EHLO
	mail-vb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039AbaACSIy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jan 2014 13:08:54 -0500
Received: by mail-vb0-f47.google.com with SMTP id m10so1806541vbh.34
        for <linux-nfs@vger.kernel.org>; Fri, 03 Jan 2014 10:08:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201401031543.15051.lux-integ@btconnect.com>
References: <201401031543.15051.lux-integ@btconnect.com>
Date: Fri, 3 Jan 2014 13:08:53 -0500
Message-ID: <CAHVgHyVFsNwmOrw-fZhuZTn=GjPLqyh=2TZxMNifD8rJGqc2oQ@mail.gmail.com>
Subject: Re: spkm3, pku2u question
From: Andy Adamson <androsadamson@gmail.com>
To: lux-integ <lux-integ@btconnect.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 3, 2014 at 10:43 AM, lux-integ <lux-integ@btconnect.com> wrote:
> Greetings
>
> I have been scanning the Internet to find out if spkm3 has been removed from
> nfs4 and whether its proported replacement pku2u is available. I get
> conflicting reports as te the  demise of spkm3 and  most of my endeavours for
> pku2u seem to suggest it is available now only  as a binary release for
> microsoft windows.
>
>
> I would be grateful for some advice regarding
>
> --a) spkm3 status in current releases  of linux kernel and nfs-utils etc.  (
> i.e. is it or is it not there and working?)

SPKM3 failed to make it through the IETF - the draft I was working on
expired in 2005. It has therefore been removed from the upstream
kernel, nfs-utils etc, although some definitions remain.


> --b) wheher an 'open-source' pku2u for linux is availablea  as replacement for
> spkm3   and if  so   where to find it.

AFAIK there is no open source pku2u.  PKU2U is a good idea as it uses
the Kerberos protocol with different payloads so kernel Kerberos
implementations would not need to change. If I remember correctly the
job WRT MIT Kerberos would be to refactor the KDC code into library
calls so that a PKU2U server could instantiate a KDC of one entry for
itself backed by an X.509 cert - but it's been a long time since I
reviewed it.

-->Andy
>
> yours soncerely
> luxInteg
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
