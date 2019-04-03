Return-Path: <SRS0=5sV6=SF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF7A3C4360F
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Apr 2019 20:57:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 883202082C
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Apr 2019 20:57:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="cdjZ2xFd"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726263AbfDCU5i (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 3 Apr 2019 16:57:38 -0400
Received: from smtp-o-3.desy.de ([131.169.56.156]:57880 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726144AbfDCU5i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 Apr 2019 16:57:38 -0400
X-Greylist: delayed 368 seconds by postgrey-1.27 at vger.kernel.org; Wed, 03 Apr 2019 16:57:36 EDT
Received: from smtp-buf-3.desy.de (smtp-buf-3.desy.de [131.169.56.166])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 85136280939
        for <linux-nfs@vger.kernel.org>; Wed,  3 Apr 2019 22:51:27 +0200 (CEST)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-3.desy.de 85136280939
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
        t=1554324687; bh=3qaiXFLKToTC1JrCOrATIzgeYL2BjEqVD+Dsm5xOVxc=;
        h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
        b=cdjZ2xFd7k7q73Zw7m2cGRHj3KujvyROuAP5HrZzuK8o476oUFxhS2zYzIDqxPkNB
         /BrPlHrOfsQQj6n2DDBB4zATs+7rLj/Nz09/C8XsJkqtgYsxjBds4VfrASK6nWd/NI
         xvTMv0siY5CRIEiOj5rld/BfwpbenYFKD4Oq4d7s=
Received: from smtp-m-3.desy.de (smtp-m-3.desy.de [131.169.56.131])
        by smtp-buf-3.desy.de (Postfix) with ESMTP id 7ED03A003E;
        Wed,  3 Apr 2019 22:51:27 +0200 (CEST)
X-Virus-Scanned: amavisd-new at desy.de
Received: from z-mbx-2.desy.de (z-mbx-2.desy.de [131.169.55.140])
        by smtp-intra-1.desy.de (DESY-INTRA-1) with ESMTP id 424AB3E901;
        Wed,  3 Apr 2019 22:51:27 +0200 (MEST)
Date:   Wed, 3 Apr 2019 22:51:27 +0200 (CEST)
From:   "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To:     Trond Myklebust <trondmy@gmail.com>
Cc:     Olga Kornievskaia <aglo@umich.edu>,
        linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <995086222.2639035.1554324687132.JavaMail.zimbra@desy.de>
In-Reply-To: <1778bf6d42f956d0226fe05683b385654b4c0109.camel@gmail.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com> <CAN-5tyHGWp1o7v4bYCsEFxRJpBhH9Qg9ieGZYDjBVdmtua9KPA@mail.gmail.com> <1778bf6d42f956d0226fe05683b385654b4c0109.camel@gmail.com>
Subject: Re: [PATCH v2 00/28] Fix up soft mounts for NFSv4.x
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Mailer: Zimbra 8.8.10_GA_3781 (ZimbraWebClient - FF66 (Linux)/8.8.10_GA_3786)
Thread-Topic: Fix up soft mounts for NFSv4.x
Thread-Index: 94S8mvOLQRKQVLFhzP4BTvuqrPYC7g==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond,

----- Original Message -----
> From: "Trond Myklebust" <trondmy@gmail.com>
> To: "Olga Kornievskaia" <aglo@umich.edu>
> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>
> Sent: Tuesday, April 2, 2019 8:28:38 PM
> Subject: Re: [PATCH v2 00/28] Fix up soft mounts for NFSv4.x

> On Mon, 2019-04-01 at 12:54 -0400, Olga Kornievskaia wrote:
>> On Fri, Mar 29, 2019 at 6:02 PM Trond Myklebust <trondmy@gmail.com>
>> wrote:
>> > This patchset aims to make soft mounts a viable option for NFSv4
>> > clients
>> > by minimising the risk of false positive timeouts, while allowing
>> > for
>> > faster failover of reads and writes once a timeout is actually
>> > observed.
>> > 
>> > The patches rely on the NFS server correctly implementing the
>> > contract
>> > specified in RFC7530 section 3.1.1 with respect to not dropping
>> > requests
>> > while the transport connection is up. When this is the case, the
>> > client
>> > can safely assume that if the request has not received a reply
>> > after
>> > transmitting a RPC request, it is not because the request was
>> > dropped,
>> > but rather is due to congestion, or slow processing on the server.
>> > IOW: as long as the connection remains up, there is no need for
>> > requests
>> > to time out.
>> > 
>> > The patches break down roughly as follows:
>> > - A set of patches to clean up the RPC engine timeouts, and ensure
>> > they
>> >   are accurate.
>> > - A set of patches to change the 'soft' mount semantics for
>> > NFSv4.x.
>> > - A set of patches to add a new 'softerr' mount option that works
>> > like
>> >   soft, but explicitly signals timeouts using the ETIMEDOUT error
>> > code
>> >   rather than using EIO. This allows applications to tune their
>> >   behaviour (e.g. by failing over to a different server) if a
>> > timeout
>> >   occurs.
>> 
>> I'm just curious why would an application be aware of a different
>> server to connect to and an NFS layer would not be? I'm also curious
>> wouldn't it break application that typically expect to get an EIO
>> errors? Do all system calls allow to return ETIMEDOUT error?
> 
> This is why it is a separate mount option. ...and actually most
> applications blow up when they get EIO as well. However you can imagine
> an application that might decide to retry if it hits an ETIMEDOUT,
> while failing if it hits an EIO.

What is the reason of introducing new error code for IO operations, which
is not in the list of POSIX specified values for read(2) and write(2). Is
there expected application behavior change compared to EAGAIN?

I would like to use the opportunity to bring the topic of O_NONBLOCK open(2)
flag for offline files.

Tigran.

> 
> Cheers
>   Trond
