Return-Path: <SRS0=avcE=RX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DC90C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Mar 2019 14:29:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 097D62184E
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Mar 2019 14:29:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="PYmKmVpz"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726487AbfCTO3E (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Mar 2019 10:29:04 -0400
Received: from mail-ua1-f54.google.com ([209.85.222.54]:37841 "EHLO
        mail-ua1-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726782AbfCTO3E (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Mar 2019 10:29:04 -0400
Received: by mail-ua1-f54.google.com with SMTP id x1so836317uaj.4
        for <linux-nfs@vger.kernel.org>; Wed, 20 Mar 2019 07:29:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=D4aQt5bSonKqwF1VfT7ptur+XuGmxIh44dtG+H3IVzI=;
        b=PYmKmVpzB0qyDl3aM72jCewX1Zq/HaUEpvs+u78hYrtUdBKnDBGbUMzcAXiOSDn8Yk
         wcjsMgipUIQRZ1pdIFiGvj03catiiTobIx24cVk1vQTGYtu3whlGBS4ZaF/LQ294fHre
         WmMJTnT5ZYSFW+8lhhRz4ZdBVau6jBoCq4VLSTxiLa9Q6msWf3XWOu8GVgUtRJeqE7do
         iNc7m+F1qbWj1nhIlXipkZ3xiWJqyNGDGVeTcTaOzBZYByAOAFquccbxefQMABkSNu63
         DR8qL82CI7sl11kxKSBvqzcQ/VotSw/sbXq7J6WLdxCg+4oLMbU54sR5yFMEKUjAnyqA
         3w7w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=D4aQt5bSonKqwF1VfT7ptur+XuGmxIh44dtG+H3IVzI=;
        b=osRuWNnasrVzE/uwkYUTvDSpqTA+UnDahTfuMiaka275oXdGlEW1sxShEk2+chKsjw
         WQjGhjgKEMMYQDq792BBCwcsQZo9hq4sIhMz5/j3Oo9YeMZKljq+iAelQ0MbLj29k3Cv
         zn8lDor+f9s7i2w3Co1OsvtKKuT7YMQrB/llThSQXFK+bdOy8DLGJkZpDdycWi8tnwPJ
         y3OIt6hfjXbaBOjl7xn7h3I1leWRjAjDg7i1jBpNqPC822/LUIGFGXjpCJdKt/9HA/Mi
         TAPI1QVRdl2a80fWkuk+3vvrd/PUK6VSMBUmUqxf28aX2CMb/ruuZr1HtR7NAnb/OfZl
         mjVA==
X-Gm-Message-State: APjAAAX0Ok0uakDY66amr2K+7E7e+vdWrAlxSiYahwUZkIqjlLeM6m1y
        RXdu+0vrdcHPcOPlI1zLYcbhNIXfJk6Xw8A94/s=
X-Google-Smtp-Source: APXvYqzAOMVtqHYf9F2hESnAPRe4P5jFQI6BwJzOneVN1cjOfJBpKsLbofjxMToZPyzOOrBkFXtIIN/+jrLt64lhAkM=
X-Received: by 2002:ab0:2f8:: with SMTP id 111mr4521158uah.123.1553092143138;
 Wed, 20 Mar 2019 07:29:03 -0700 (PDT)
MIME-Version: 1.0
References: <CA+5eE-TWSOGs+7wJnykbwD84iTuXStgmsprxbXdf27ciHMg2Ng@mail.gmail.com>
In-Reply-To: <CA+5eE-TWSOGs+7wJnykbwD84iTuXStgmsprxbXdf27ciHMg2Ng@mail.gmail.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Wed, 20 Mar 2019 10:28:51 -0400
Message-ID: <CAN-5tyHO0mJfwha2z1+bFcq6+R3E1qws2p_EYJZbm93BRaS=EQ@mail.gmail.com>
Subject: Re: Some questions about Trunking
To:     Marvin Zhang <fanzier@gmail.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This question is more of an NFSv4.1 protocol question thus I would
encourage you to ask it on the nfsv4@ietf.org.

On Tue, Mar 19, 2019 at 11:06 PM Marvin Zhang <fanzier@gmail.com> wrote:
>
> Hi Experts,
> Here are some questions about trunking:
> 1.  For session trunking. During first mount(or first connection),
> client create a session. During the second mount(or second
> connection), client will reuse the session which the first connection
> created. Does the second mount create a new super block or reuse the
> previous?
> If there is a READ request on this session, how to judge to
> use which connection?

Session trunking does not require the client to create a different
mount in your example. A single mount could have multiple TCP
connections established between a client and a server and they would
use the same NFSv4.1 session to send operations to the server. A read
operation issued by the application using the NFS mount could use one
of those connection and the question which one it would use is
protocol implementation specific. Simplest implementation round robins
connections for incoming RPC tasks.

If the client mounted a server and then decides to mount the same
server again (given same mount options and credentials), in the linux
implementation, the existing NFS client (and its TCP connection) would
be re-used. Thus it would not be a case of session trunking.

> 2. For client id truking. As protocol said, client can create multipl
> session at the same time. I can't understand in which scenario client
> can create multiple session

Again IETF list can provide some examples and motivations for the
clientid case. I think perhaps it was for the clustered server
environment where the client would use the same client id across
different cluster nodes but it would establish unique sessions to the
nodes.
