Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:40832
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750916AbcFAWKh convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Jun 2016 18:10:37 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Olga Kornievskaia'" <aglo@umich.edu>,
        "'Trond Myklebust'" <trondmy@primarydata.com>
Cc: "'linux-nfs'" <linux-nfs@vger.kernel.org>
References: <CAN-5tyFXzH+Je8Th_irarJtBb+9QziFj8p7xH0NRLupOsTYBrw@mail.gmail.com>	<F693F912-2BA0-4899-A73C-65CB7536B090@primarydata.com> <CAN-5tyEdttEMqepHWmd-KgUcH-azbnko4QJsVuwQha=GSVgzoA@mail.gmail.com>
In-Reply-To: <CAN-5tyEdttEMqepHWmd-KgUcH-azbnko4QJsVuwQha=GSVgzoA@mail.gmail.com>
Subject: RE: open_downgrade use
Date: Wed, 1 Jun 2016 15:10:18 -0700
Message-ID: <061c01d1bc52$628e05f0$27aa11d0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Wed, Jun 1, 2016 at 4:41 PM, Trond Myklebust
> <trondmy@primarydata.com> wrote:
> > You are misreading what I wrote. Your test should indeed give rise to
> > an OPEN_DOWNGRADE (unless there is a delegation involved). The code
> > that was misbehaving and that was fixed by the patch was triggering an
> > OPEN_DOWNGRADE from a stateid that had only been opened for RW.
> 
> I see. With this patch, the upstream code no longer sends an
> OPEN_DOWNGRADE. I will investigate why then as it seems like a bug.

Does the client send an open for the read only? If not, per spec, having opened read/write, you can't downgrade to read only.

The server should allow the 2nd open for read only as an "upgrade" (which won't actually do anything, except allow the subsequent downgrade to read only).

Such a scenario should be allowed by Ganesha, though my algorithm isn't perfect, when downgrading to read only, we don't "forget" that the file had been opened read/write, so Ganesha would allow the following sequence:

Open read only
Open write only (upgrades to read/write)
Downgrade to read only
Open read/write (upgrades to read/write)
Downgrade to write only

That last downgrade should be rejected per the RFC.

Frank



---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

