Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:56732 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752900Ab0HFG3F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Aug 2010 02:29:05 -0400
Received: by gxk23 with SMTP id 23so2749023gxk.19
        for <linux-nfs@vger.kernel.org>; Thu, 05 Aug 2010 23:29:04 -0700 (PDT)
In-Reply-To: <AANLkTik_awWoER22GmhYeJw2cN4GoJe1Gj7SCVetMzte@mail.gmail.com>
References: <AANLkTik_awWoER22GmhYeJw2cN4GoJe1Gj7SCVetMzte@mail.gmail.com>
Date: Fri, 6 Aug 2010 16:29:03 +1000
Message-ID: <AANLkTiny1SXAzZSenaGwjdkWwE3Fs7eXXBtsB=RcD7kY@mail.gmail.com>
Subject: Re: shutting down socket
From: hce <webmail.hce@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I am running kernel 2.6.18. I searched from Internet and found
different views regarding to the error of "rpc-srv/tcp: nfsd: got
error -32 when sending 36 bytes - shutting down socket". Some say it
could be kernel bug (I am running kernel 2.6.18) and some said it
could be distribution package bug (I am running CentOS 5).

One view was that error could be caused by insufficient nfsd
resources. In normal operation, I have following statistics. Does that
implies it needs to increase number of nfsd?

th 8 2311379 141.373 7.943 8.199 0.000 10.755 10.693 10.615 96.889 0.000 946.537

Thank you.

Kind regards





On Wed, Aug 4, 2010 at 2:31 PM, hce <webmail.hce@gmail.com> wrote:
> Hi,
>
> I am running a networking application on CentOS 5, it got a SIGTERM
> and the application terminated. I looked at dmesg file and found
> following an error:
>
> rpc-srv/tcp: nfsd: got error -32 when sending 36 bytes - shutting down socket
>
> Could that error result a SIGTERM? If yes, what could possibly cause
> the nfsd error to shut down the socket?
>
> Thank you.
>
> hce
>
