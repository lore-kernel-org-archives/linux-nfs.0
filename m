Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C84AC4360F
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 16:32:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 44D4420700
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 16:32:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726492AbfBVQcx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 11:32:53 -0500
Received: from mail-qt1-f193.google.com ([209.85.160.193]:36681 "EHLO
        mail-qt1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726131AbfBVQcx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 11:32:53 -0500
Received: by mail-qt1-f193.google.com with SMTP id p25so3173901qtb.3
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 08:32:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=fAhtg04z6I25GvP1V5MgkS/GhYYe58k8oe4vwDa+qiw=;
        b=JALEUS24oxmIAmSo5zXp0FhpoI+eCkF7Rc5Syd9NToe/HbZWtbkbGSVgYyouHK5tvf
         0EY9KbFILlQAh7fTN77a8nkDRjc3y9nOHXG4LU0mD6TLWCgxZ3Np5VcFLkiA5Zn9Y45V
         62r2u3fdUgMpfscTVO7gKisB4IC5NmyqpnVr2vdp+PVs+6pSquO5V3cTFcz4ETTCpYgC
         9+rDsy59d2fBPHUevm0ekXP9XJGRN5cI/BYbsbF1d0TwiRK5WzFbYOs1YuZ/Pw4XZsR/
         gJuIHM8tFYrvuiGHGG6D90Sb4/5nAqtQRVyKlJPMVpA8W/i7WvG1+K3i+p0footEYq55
         g//g==
X-Gm-Message-State: AHQUAuaObCBayk3C6EDcncR/weppV3E59W1JKn3tPDnHXhM9qbVePpcW
        ff0HViemMeJyv46LM8cynfBU7bluYq0=
X-Google-Smtp-Source: AHgI3IYMLIkZ8ixwQECxVkZcktoaWChrYYl6AGfbwE3/0KShbkCxY1Iq/fI5RKVgVu+zl1B2bGpfBA==
X-Received: by 2002:ac8:2ad9:: with SMTP id c25mr3751464qta.250.1550853171980;
        Fri, 22 Feb 2019 08:32:51 -0800 (PST)
Received: from dhcp-12-212-173.gsslab.rdu.redhat.com (nat-pool-rdu-t.redhat.com. [66.187.233.202])
        by smtp.gmail.com with ESMTPSA id f58sm1162140qtc.14.2019.02.22.08.32.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 08:32:51 -0800 (PST)
Message-ID: <1550853168.9958.1.camel@redhat.com>
Subject: Re: [PATCH 1/1] SUNRPC: fix handling of half-closed connection
From:   Dave Wysochanski <dwysocha@redhat.com>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Date:   Fri, 22 Feb 2019 11:32:48 -0500
In-Reply-To: <CAN-5tyH1e_cakjmU5VkQraw=ht71y8vxvaZbe2W6zAdfEnWLPA@mail.gmail.com>
References: <20190220145650.21566-1-olga.kornievskaia@gmail.com>
         <1550837576.6456.3.camel@redhat.com>
         <CAN-5tyH1e_cakjmU5VkQraw=ht71y8vxvaZbe2W6zAdfEnWLPA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-14.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2019-02-22 at 09:44 -0500, Olga Kornievskaia wrote:
> Hi Dave,
> 
> A re-producer is a server that sends an ACK to the client's FIN/ACK
> request and does nothing afterwards (I can reproduce it 100% with a
> hacked up server. It was discovered with a "broken" server that
> doesn't fully closes a connection). It leave this client unable to
> connect to this server again indefinitely/forever/reboot required
> kind
> of state. Once it was considered that doing something like that to
> the
> client is a form of an attack (denial-of-server) and thus the kernel
> has a tcp_fin_timeout option after which the kernel will abort the
> connection. However this only applies to the sockets that have been
> closed by the client. This is NOT the case. NFS does not close the
> connection and it ignores kernel's notification of FIN_WAIT2 state.
> 
Interesting.  I had the same reproducer but eventually an RST would get
sent from the NFS client due to the TCP keepalives.  It sounds like
that is not the case anymore.  When I did my testing was over a year
and a half ago though.


> One can argue that this is a broken server and we shouldn't bother.
> But this patch is an attempt to argue that the client still should
> care and deal with this condition. However, if the community feels
> that a broken server is a broken server and this form of an attack is
> not interested, this patch can live will be an archive for later or
> never.
> 

This isn't IPoIB is it?

Actually, fwiw, looking back I had speculated on changes in this area. 
I'm adding you to the CC list of this bug which had some of my musings
on it:
https://bugzilla.redhat.com/show_bug.cgi?id=1466802#c43
That bug I ended up closing when we could no longer prove there was any
state where the NFS client could get stuck in FIN_WAIT2 after the
keepalive patch.

It can happen that the server only sends the ACK back to the clients
FIN,ACK so in general the testcase is valid.  But then the question is
how long should one wait for the final data and FIN from the server, or
are there ever instances where you shouldn't wait forever?  Is there a
way for us to know for sure there is no data left to receive so it's
safe to timeout?  No RPCs outstanding?

I don't claim to know many of the subtleties here as far as would the
server wait forever in LAST_ACK or do implementations eventually
timeout after some time?  Seems like if these last packets get lost
there is likely a bug somewhere (either firewall or TCP stack, etc).
https://tools.ietf.org/html/rfc793#page-22

It looks like at least some people are putting timeouts into their
stacks though I'm not sure that's a good idea or not.

