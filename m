Return-Path: <SRS0=fB6X=RY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2ACEC43381
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Mar 2019 03:05:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9EC7120811
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Mar 2019 03:05:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aNjl3eP2"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727614AbfCUDFA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Mar 2019 23:05:00 -0400
Received: from mail-ua1-f51.google.com ([209.85.222.51]:35715 "EHLO
        mail-ua1-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727586AbfCUDFA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Mar 2019 23:05:00 -0400
Received: by mail-ua1-f51.google.com with SMTP id f88so1500979uaf.2
        for <linux-nfs@vger.kernel.org>; Wed, 20 Mar 2019 20:04:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=T0aQnse6iIzxJOpskOApZq2JlEKFRIbjMrQEEZcxW6o=;
        b=aNjl3eP2ksO4f2HFDfyvEd9mla2Ko/0Hxoslzm1t9XGxBqPJEiU+0Ot13UfO+Wnpp9
         IVN0QcPY3E8G96njR8Sa2pGSKdtyJp3vXQohl/r9sizeQ9ZTWuI+Xyk8w5IBIaVwJo0X
         U3gi3ghLW6uWc71lhUvbNvlfKFRU1dQ0rTDLOkDRHYIGSwvlGKVvwBAy7l39SggYDHcJ
         2b5HjaPJuJOO3NlPPodnbGQ8ucXoDCswS9o+IA5UkjmY21E7bcR+g1MZLBfdSrc2w4Ut
         X8WeVX7itYx/yd6ZcHB1HRQLNsUSw0NBbWJ9s+3b3k81zOV77nMY4U8DTv00kFFkh+Jy
         hZtA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=T0aQnse6iIzxJOpskOApZq2JlEKFRIbjMrQEEZcxW6o=;
        b=YyUzrnk40MkU1KSiNeveWjEq60jmVtUsDGJcR0Xa6uqM6i9PHNZwS/+y5HkP0sPa5q
         SGHFadSZj9gvJZNXFw6tgT0MJc3mMyIx/jw+DoIptnylZRDs4/ABtGeEFhr1/O0nrz4I
         wJfRbSWIlC+zh+APS46vJIIvw0vfc8BcUmWBxgcX0RsiFTStMsD3prHSNZQc0VqP/oD9
         B/oPLaDkEDgLCGqKe4t/IMa4VwcX6kDHgmC/SQ/M1xaaVeNBNVSGdg7dsEjFK/u9t0Eq
         eSS2XQYcNh6O0owfALQF8HbShdQWGjil0W6tMp/TgpyhPUNSzZ+9bcNPq9q/IwlLIlMc
         mluA==
X-Gm-Message-State: APjAAAUfcvVcL+wBwCQGHtFxN+wWkiwIRm0slFlqgRr/+lf7kXUioO3Q
        eC7PTnbYbd34Y7YFCWzCZhUIzwYMs93z9VyxbKY=
X-Google-Smtp-Source: APXvYqwgBb1rQliMvBY2qCFdT9Z9pBEGC49knnwhGPOrCDl/nbrYIzXqRDPG0mPzn9QjIER2YvdfKEKpJcdakkm/fls=
X-Received: by 2002:ab0:61da:: with SMTP id m26mr623382uan.140.1553137498531;
 Wed, 20 Mar 2019 20:04:58 -0700 (PDT)
MIME-Version: 1.0
References: <CA+5eE-TWSOGs+7wJnykbwD84iTuXStgmsprxbXdf27ciHMg2Ng@mail.gmail.com>
 <CAN-5tyHO0mJfwha2z1+bFcq6+R3E1qws2p_EYJZbm93BRaS=EQ@mail.gmail.com>
In-Reply-To: <CAN-5tyHO0mJfwha2z1+bFcq6+R3E1qws2p_EYJZbm93BRaS=EQ@mail.gmail.com>
From:   Marvin Zhang <fanzier@gmail.com>
Date:   Thu, 21 Mar 2019 11:04:42 +0800
Message-ID: <CA+5eE-QZ5J5jjSvGUGj8pOHNwZfHpFnyoQd0QanqOEGLW5LpcA@mail.gmail.com>
Subject: Re: Some questions about Trunking
To:     Olga Kornievskaia <aglo@umich.edu>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Mar 20, 2019 at 10:29 PM Olga Kornievskaia <aglo@umich.edu> wrote:
>
> This question is more of an NFSv4.1 protocol question thus I would
> encourage you to ask it on the nfsv4@ietf.org.
>
> On Tue, Mar 19, 2019 at 11:06 PM Marvin Zhang <fanzier@gmail.com> wrote:
> >
> > Hi Experts,
> > Here are some questions about trunking:
> > 1.  For session trunking. During first mount(or first connection),
> > client create a session. During the second mount(or second
> > connection), client will reuse the session which the first connection
> > created. Does the second mount create a new super block or reuse the
> > previous?
> > If there is a READ request on this session, how to judge to
> > use which connection?
>
> Session trunking does not require the client to create a different
> mount in your example. A single mount could have multiple TCP
> connections established between a client and a server and they would
> use the same NFSv4.1 session to send operations to the server. A read
> operation issued by the application using the NFS mount could use one
> of those connection and the question which one it would use is
> protocol implementation specific. Simplest implementation round robins
> connections for incoming RPC tasks.
I just followed this article:
https://packetpushers.net/multipathing-nfs4-1-kvm/ . In this article,
client mounts the server twice in differ conections. But as you said,
it's not session trunking. I still don't konw how to mount a server
only once with two connection. Could you give me a sample here? I
don't find any example in google searching result.

>
> If the client mounted a server and then decides to mount the same
> server again (given same mount options and credentials), in the linux
> implementation, the existing NFS client (and its TCP connection) would
> be re-used. Thus it would not be a case of session trunking.
>
> > 2. For client id truking. As protocol said, client can create multipl
> > session at the same time. I can't understand in which scenario client
> > can create multiple session
>
> Again IETF list can provide some examples and motivations for the
> clientid case. I think perhaps it was for the clustered server
> environment where the client would use the same client id across
> different cluster nodes but it would establish unique sessions to the
> nodes.
