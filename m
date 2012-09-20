Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:61069 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755520Ab2ITOfG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Sep 2012 10:35:06 -0400
Received: by pbbrr4 with SMTP id rr4so339557pbb.19
        for <linux-nfs@vger.kernel.org>; Thu, 20 Sep 2012 07:35:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJ75kXZuM_p3qknD4RgdjLLWd393u02S5FKQyu3Q8y8NwmfiVw@mail.gmail.com>
References: <CAJ75kXZuM_p3qknD4RgdjLLWd393u02S5FKQyu3Q8y8NwmfiVw@mail.gmail.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Thu, 20 Sep 2012 16:34:45 +0200
Message-ID: <CAJ75kXagDP6TPO+7pCCcUyac+ViPgKVThTsuehHNi_xwTpnGiQ@mail.gmail.com>
Subject: Re: unhandled error -10026
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Cc: R.Eggermont@tudelft.nl
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 18, 2012 at 11:49 AM, William Dauchy <wdauchy@gmail.com> wrote:
> I'm getting a trace following an unhandled error on a linux nfs client
> 3.4.7 x86_64.
> NFS: nfs4_reclaim_open_state: unhandled error -10026. Zeroing state

For the moment I don't know if the error is coming from a bad server
implementation or if it's on client side. Should I assume that this an
error that should never hit the client?

Regards,
-- 
William
