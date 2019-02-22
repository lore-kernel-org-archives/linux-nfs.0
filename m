Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB9F4C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 17:10:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 96C0D20700
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 17:10:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kd5KtuIB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726869AbfBVRKr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 12:10:47 -0500
Received: from mail-vk1-f196.google.com ([209.85.221.196]:43270 "EHLO
        mail-vk1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726749AbfBVRKq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 12:10:46 -0500
Received: by mail-vk1-f196.google.com with SMTP id e131so646641vkf.10
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 09:10:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+eqhrNwhq+CQzmEKZCn4oP2fGah0LdpMfPdvDnjvTZk=;
        b=kd5KtuIBtHP62pZqYX12bJBh7NegKY8yt7y8yTFfJb8svb3tR426r5W5snyK6kNCNS
         aV8Q0Y4yjTNI4rrj8zRvxbgg7+HemXVlOEbwZMN3ZETHiXF/7eYjVQoKlNYetCBFpmjR
         V9/usNYWC5+EPQiHgfk1tMSASFYlwPT49d5vjEQcFfv8B97RRm/z5Oe+OoZ5/xS1Q4vQ
         k5Ko1LiAbv2QUOKH/FmM02y0/clXZsxT/kQbq8uvORqyqEEtHqB1gkF81dwj2+gwfdSL
         5N1Vp2XolX7G2fyCMuguwpjJmg9eS2HlYpmDqrOHfVXYoe6LYEllgSymgPPTUEXkqcd/
         oABQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=+eqhrNwhq+CQzmEKZCn4oP2fGah0LdpMfPdvDnjvTZk=;
        b=LrQ5NItoHov4YnEIl3U4+Mb4nxbUq9w39gqlhrRdZ7wgTHyyOsaixGmhVc8CURcNlX
         cAhuPhF4j04M+awGKfBVwyGph1mUA+6BA1QaFvc+yCfRR/OIezL4oopDmug1cCI3578S
         Ro3NxEQUmmrrq4ZiABAzXjxOp7s58e7jblyu67c1Ni9Ptbk72VW5TjLyEuCWUX0ByWxW
         JcXP+akCDLGe6NXWKrG8XRtoDO5ArzT6bTbLTr3aSkWU7IqoYUYXreAtRewHqW6pVx75
         JHcfgz4E0BJikkS2BvN+8lEnDt6/wDrsFLwSQiEMufMaJkbJo4v0hBukkw6zpVjRtk22
         21SQ==
X-Gm-Message-State: AHQUAuYe/ejAgSyx5ZUn6jDqBEBQpm1zZHBxFodMYvI1Cx0/Annub1x0
        4eLX3AjSdnE6+f+gPRN3Y69/nlwiZtfyqMNTMcAGYQ==
X-Google-Smtp-Source: AHgI3IbqhK6UnCXLpgzInNefsW2ZSEn82xGQZjj2v9w2KmY3UUPWnPr5lAGBn/Fy2tmpNozr2FOoAMXqvkbOCVpcpqc=
X-Received: by 2002:a1f:1ac3:: with SMTP id a186mr2754568vka.34.1550855445512;
 Fri, 22 Feb 2019 09:10:45 -0800 (PST)
MIME-Version: 1.0
References: <20190220145650.21566-1-olga.kornievskaia@gmail.com>
 <1550837576.6456.3.camel@redhat.com> <CAN-5tyH1e_cakjmU5VkQraw=ht71y8vxvaZbe2W6zAdfEnWLPA@mail.gmail.com>
 <1550853168.9958.1.camel@redhat.com>
In-Reply-To: <1550853168.9958.1.camel@redhat.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Fri, 22 Feb 2019 12:10:34 -0500
Message-ID: <CAN-5tyEpWevmXJb8weecFBm_V=FZm4Zc=b+rrwJFtMgUYhm2tg@mail.gmail.com>
Subject: Re: [PATCH 1/1] SUNRPC: fix handling of half-closed connection
To:     Dave Wysochanski <dwysocha@redhat.com>
Cc:     trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Feb 22, 2019 at 11:32 AM Dave Wysochanski <dwysocha@redhat.com> wrote:
>
> On Fri, 2019-02-22 at 09:44 -0500, Olga Kornievskaia wrote:
> > Hi Dave,
> >
> > A re-producer is a server that sends an ACK to the client's FIN/ACK
> > request and does nothing afterwards (I can reproduce it 100% with a
> > hacked up server. It was discovered with a "broken" server that
> > doesn't fully closes a connection). It leave this client unable to
> > connect to this server again indefinitely/forever/reboot required
> > kind
> > of state. Once it was considered that doing something like that to
> > the
> > client is a form of an attack (denial-of-server) and thus the kernel
> > has a tcp_fin_timeout option after which the kernel will abort the
> > connection. However this only applies to the sockets that have been
> > closed by the client. This is NOT the case. NFS does not close the
> > connection and it ignores kernel's notification of FIN_WAIT2 state.
> >
> Interesting.  I had the same reproducer but eventually an RST would get
> sent from the NFS client due to the TCP keepalives.  It sounds like
> that is not the case anymore.  When I did my testing was over a year
> and a half ago though.

after the keepalives the TCP also sends a FIN/ACK if the server
properly sent a FIN/ACK back, then keep alive will indeed be
sufficient. Can you check if in your trace server in one time sent
just an ACK but in another case sent the FIN/ACK?

> > One can argue that this is a broken server and we shouldn't bother.
> > But this patch is an attempt to argue that the client still should
> > care and deal with this condition. However, if the community feels
> > that a broken server is a broken server and this form of an attack is
> > not interested, this patch can live will be an archive for later or
> > never.
> >
>
> This isn't IPoIB is it?

No, just normal TCP.


> Actually, fwiw, looking back I had speculated on changes in this area.
> I'm adding you to the CC list of this bug which had some of my musings
> on it:
> https://bugzilla.redhat.com/show_bug.cgi?id=1466802#c43
> That bug I ended up closing when we could no longer prove there was any
> state where the NFS client could get stuck in FIN_WAIT2 after the
> keepalive patch.

I can reproduce current behavior with the current upstream code.


> It can happen that the server only sends the ACK back to the clients
> FIN,ACK so in general the testcase is valid.  But then the question is
> how long should one wait for the final data and FIN from the server, or
> are there ever instances where you shouldn't wait forever?  Is there a
> way for us to know for sure there is no data left to receive so it's
> safe to timeout?  No RPCs outstanding?

Yep all good questions which I don't have answers to. I realize that
for instance, that a server might send an ACK and then send a FIN/ACK
after that. But why is it bad for the client to proactively send an
RST (by shutting down the connection in TCP_FIN_WAIT2 if the client
was shutting down the connection anyway.

> I don't claim to know many of the subtleties here as far as would the
> server wait forever in LAST_ACK or do implementations eventually
> timeout after some time?  Seems like if these last packets get lost
> there is likely a bug somewhere (either firewall or TCP stack, etc).
> https://tools.ietf.org/html/rfc793#page-22
>
> It looks like at least some people are putting timeouts into their
> stacks though I'm not sure that's a good idea or not.

I saw only one other driver in the kernel that does have handling of
the TCP_FIN_WAIT2 state (driver/crypto/chelsio) ...
