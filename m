Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:33579 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941Ab3KUXs6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Nov 2013 18:48:58 -0500
Received: by mail-qc0-f180.google.com with SMTP id w7so13353qcr.11
        for <linux-nfs@vger.kernel.org>; Thu, 21 Nov 2013 15:48:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJ75kXahPFSMsec27Eu2cR2N7cNrv_cwtL9cN3At5RNU1fZC-Q@mail.gmail.com>
References: <1384551376-8734-1-git-send-email-andros@netapp.com>
 <1384897797.45997.1.camel@leira.trondhjem.org> <CAJ75kXahPFSMsec27Eu2cR2N7cNrv_cwtL9cN3At5RNU1fZC-Q@mail.gmail.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Fri, 22 Nov 2013 00:48:38 +0100
Message-ID: <CAJ75kXY6WKe3frNpH3U2C2uB7W6uPPq1QzoAnWy5wvw18Rse1A@mail.gmail.com>
Subject: Re: [PATCH Version 3 1/1] NFSv4 wait on recovery for async session errors
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 20, 2013 at 10:29 AM, William Dauchy <wdauchy@gmail.com> wrote:
> ba64b36 NFSv4: Update list of irrecoverable errors on DELEGRETURN
> is cc'ed for stable
>
> If these two patches are connected, why the first one:
> d3b173a NFSv4 wait on recovery for async session errors
> is not cc'ed for stable as well?

you last push
4a82fd7 NFSv4 wait on recovery for async session errors
is now cc'ed for stable

Thanks,
-- 
William
