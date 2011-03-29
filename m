Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:46155 "EHLO
	opensource2.wolfsonmicro.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752809Ab1C2VWC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Mar 2011 17:22:02 -0400
Date: Wed, 30 Mar 2011 06:22:11 +0900
From: Mark Brown <broonie@opensource.wolfsonmicro.com>
To: Will Simoneau <simoneau@ele.uri.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Belisko Marek <marek.belisko@gmail.com>, Trond.Myklebust@netapp.com,
        bdowning@lavos.net, linux-nfs@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: [bisect] kernel 2.6.38 regression with root nfs mounting
Message-ID: <20110329212210.GB30482@opensource.wolfsonmicro.com>
References: <43F07477-9075-444D-9BBB-368650538EA8@oracle.com>
 <AANLkTinHUQkBvcvh9APVutOqcKOug6CA066kS_O4p4Tq@mail.gmail.com>
 <DC2B75F8-382A-4AFB-9286-4A55EAF7609A@oracle.com>
 <AANLkTikWyUbtHbbnSh8NBeP3mT4jDOu5Pbtfw=TwKrwE@mail.gmail.com>
 <977C528D-4540-4EB2-92F9-6DAF357D8C81@oracle.com>
 <AANLkTik0UgB+k2i=E5t9XcF50SoSr_iXaFYrhctDx0FJ@mail.gmail.com>
 <8F19F0FE-0800-4C45-B857-1C682CF6A30D@oracle.com>
 <AANLkTin4-+Mc7d0a-XnZvPKL-C_Cf+Kmnm1Bmh1XZZu4@mail.gmail.com>
 <4AD2FFC1-E777-4C29-8718-4E1717EFCD86@oracle.com>
 <20110329202408.GM1966@ele.uri.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110329202408.GM1966@ele.uri.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Mar 29, 2011 at 04:24:08PM -0400, Will Simoneau wrote:

> Interestingly, we are both using DM9000 network chips. I wonder if there
> is a UDP-related problem on the DM9000. I will play with my
> configuration a little more (in particular testing proto=tcp and revert
> of 53d4737580535e073963b91ce87d4216e434fab5) but my guess is the DM9000
> driver/chip is to blame. The DM9000A on my board has 16K of on-chip SRAM
> used for its RX/TX buffers which may be playing a part in the problem.

It's more likely that the DM9000 is just slow and fragile.  One thing to
note with a lot of the lower end network chips is that you end up
needing to specify rsize and wsize so that you don't get fragmentation -
about 1k tends to work well IME.  Otherwise performance often degrades
to the point of unusability.
