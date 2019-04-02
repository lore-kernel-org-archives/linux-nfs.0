Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A0DAC4360F
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 18:28:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 041342082C
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 18:28:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="J0wNBnky"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726496AbfDBS2m (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 14:28:42 -0400
Received: from mail-pl1-f193.google.com ([209.85.214.193]:46813 "EHLO
        mail-pl1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726083AbfDBS2l (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2019 14:28:41 -0400
Received: by mail-pl1-f193.google.com with SMTP id y6so6675952pll.13
        for <linux-nfs@vger.kernel.org>; Tue, 02 Apr 2019 11:28:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=sG1dKYDRqj7TgS11DdQhLFgfmr3kA+p3pdLAcRyKhsc=;
        b=J0wNBnkyG2IJUVVhXUnx8OU3USf4wAYJf1j9TNvX08V98BlXAZIqkjcncW0S1c2eqW
         vRX9Vbrs1UJBwVWae/1e0B2jQhMRey2lBagYM5QItGumpPw+9Efg4GLKN5sPEwnv4piX
         Z1fl+85o/JHvc+VL6+qZwMnXPuvSf66zN/2zwj+3alnJallOfnbzCUN7QOBdTEMUj80f
         js9PIdXOFjj3xyQsYplGr7JM9suoqkjhnZwaWJnqiSzphlGutDIi4ILf1jS0h1TcDBwk
         OwhuyATrTQBGVnwa2Ws3U0mgHsJ3Sz1HyPEYX75QknpeSEZy8DqmNMUmQnLx042061Qn
         HUkg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=sG1dKYDRqj7TgS11DdQhLFgfmr3kA+p3pdLAcRyKhsc=;
        b=rGalRHdB8gp0za7BtczIRB7nWr6XjARQIwPoZnw3CR6XQQmXfLNqn9xf6H01fKV1y0
         2tGyaoxSe5r8uNMx2Uy81n+JvaZ/qBA9hq8ACrRIYIQdaHAb+gKDPclLtkr7cGio8gVV
         MfV+w1B71GMYj4kDUSAMSBa4uKYVx8OT31eCJZgfPqPqIIDtE2HepKWBd/ZaaMnq0VEX
         wE4gd6xe+k5ujgOqO7vnAIvhoweJRzoga6RZnYNw7D3Y1XVSJupw6+8d04vwXk5kCqlb
         x0vRTFxj4TGHz+x089J+y+c209c5xQk97branKJH6QLMAncuXFKGPW7UvNvrLmiR9Gcp
         Jn7Q==
X-Gm-Message-State: APjAAAWodCwAN+o5+suorYO6hbE39Bs2F3FN3wxX/tUzey1JZGSJoZNN
        xI2kag4Bfmr7QE5Gt7mp3w==
X-Google-Smtp-Source: APXvYqy2EFHKTwXCGsUiFUT97EjUKrQi85qDciEq2EODagFI9XqfqH9hoWmapdPrEY1pOjbtoIM1DQ==
X-Received: by 2002:a17:902:b286:: with SMTP id u6mr33654746plr.310.1554229720799;
        Tue, 02 Apr 2019 11:28:40 -0700 (PDT)
Received: from leira (63-235-104-78.dia.static.qwest.net. [63.235.104.78])
        by smtp.gmail.com with ESMTPSA id o68sm39453926pfi.140.2019.04.02.11.28.39
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Apr 2019 11:28:39 -0700 (PDT)
Message-ID: <1778bf6d42f956d0226fe05683b385654b4c0109.camel@gmail.com>
Subject: Re: [PATCH v2 00/28] Fix up soft mounts for NFSv4.x
From:   Trond Myklebust <trondmy@gmail.com>
To:     Olga Kornievskaia <aglo@umich.edu>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>
Date:   Tue, 02 Apr 2019 11:28:38 -0700
In-Reply-To: <CAN-5tyHGWp1o7v4bYCsEFxRJpBhH9Qg9ieGZYDjBVdmtua9KPA@mail.gmail.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
         <CAN-5tyHGWp1o7v4bYCsEFxRJpBhH9Qg9ieGZYDjBVdmtua9KPA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 2019-04-01 at 12:54 -0400, Olga Kornievskaia wrote:
> On Fri, Mar 29, 2019 at 6:02 PM Trond Myklebust <trondmy@gmail.com>
> wrote:
> > This patchset aims to make soft mounts a viable option for NFSv4
> > clients
> > by minimising the risk of false positive timeouts, while allowing
> > for
> > faster failover of reads and writes once a timeout is actually
> > observed.
> > 
> > The patches rely on the NFS server correctly implementing the
> > contract
> > specified in RFC7530 section 3.1.1 with respect to not dropping
> > requests
> > while the transport connection is up. When this is the case, the
> > client
> > can safely assume that if the request has not received a reply
> > after
> > transmitting a RPC request, it is not because the request was
> > dropped,
> > but rather is due to congestion, or slow processing on the server.
> > IOW: as long as the connection remains up, there is no need for
> > requests
> > to time out.
> > 
> > The patches break down roughly as follows:
> > - A set of patches to clean up the RPC engine timeouts, and ensure
> > they
> >   are accurate.
> > - A set of patches to change the 'soft' mount semantics for
> > NFSv4.x.
> > - A set of patches to add a new 'softerr' mount option that works
> > like
> >   soft, but explicitly signals timeouts using the ETIMEDOUT error
> > code
> >   rather than using EIO. This allows applications to tune their
> >   behaviour (e.g. by failing over to a different server) if a
> > timeout
> >   occurs.
> 
> I'm just curious why would an application be aware of a different
> server to connect to and an NFS layer would not be? I'm also curious
> wouldn't it break application that typically expect to get an EIO
> errors? Do all system calls allow to return ETIMEDOUT error?

This is why it is a separate mount option. ...and actually most
applications blow up when they get EIO as well. However you can imagine
an application that might decide to retry if it hits an ETIMEDOUT,
while failing if it hits an EIO.

Cheers
  Trond

