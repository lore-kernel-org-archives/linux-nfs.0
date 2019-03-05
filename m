Return-Path: <SRS0=HPA/=RI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 746F2C43381
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 17:23:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 28E3220684
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 17:23:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mQ8pZd4n"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728017AbfCERXJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Mar 2019 12:23:09 -0500
Received: from mail-vs1-f66.google.com ([209.85.217.66]:34445 "EHLO
        mail-vs1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727935AbfCERXJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Mar 2019 12:23:09 -0500
Received: by mail-vs1-f66.google.com with SMTP id h7so495890vsl.1
        for <linux-nfs@vger.kernel.org>; Tue, 05 Mar 2019 09:23:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=esdIIqFHxbdNh3OEragtwof/oepcGbiBhD5EiKif5JE=;
        b=mQ8pZd4nlMqylQY2AXwLhFSCv5n5egkVXTjBdgtnIiHXcew3hq3n3eCkDaAj9QSwaC
         Hu9TcvZXrRR2MIm1ioVlYV6PphMl3DdMPcyetJeyYvrFNDfwVaj1Sly4WEsfnh5o1ckg
         84vixdvUp7kTldTRiW58Ad0Pi+Q+cDFMwZLs2+O7dYxg+hmIZZLPy0EXMJ8RdgBE8gtY
         0ShuVUYxePgS5rC6rYdACNm6HzCyFS7aKXC3pVQQUhb0vCdyFu1SlAK6RSsfg0d2Fppy
         ZOfbRZEnAlpjjHHTNlauIxbQTtx788geybnPs6y8Ng4/pM61JMSQwB1q9fH0Qmo/aQJL
         3g1A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=esdIIqFHxbdNh3OEragtwof/oepcGbiBhD5EiKif5JE=;
        b=YY9lsQayQlLN5LDS3e2/E+RtKzyNO20VDBRT9d3Dlia9Chs9X8uM0tFkCEv5wlBS1x
         1+iX9bTqrRkd9OWiT0TYH+GjoUZZlZK2rJjWGzS/7o+wlYxvP3eiVlp9Ix4XTXcGm5er
         RXKcFCeD2XRejDwQkCCTj8u4Z+BEFljodsPdnEb5AQ8prGoatxeWsPct3QUlp+ak8Hos
         f5byFjxIt0co26Y0oVSljsxISlOsSIOyU4Mk9/7ZxsfdT4Rj5AOlivl+ooGEmJYWOXZT
         VFvOnmtZdPG1NB0hcaz4OuXF1/323uDy0bEq1tzy5O/0TVE+vY/LyFG9mDLQiolxKJ0Q
         Tzpg==
X-Gm-Message-State: APjAAAUANaYnVziAMCI2RBtcMBsFYHW3Sjqn+F8t1upOr95Pyp6WaYaO
        A5D8yaB1/k6DYETErkivGcnRdep+Yuv+OpkM4bE=
X-Google-Smtp-Source: APXvYqwKLNNAcUZ4hB9H5pY/dQKNR1QwvMku42eHXc60pGjAeZtnyWq7Uq4Ji8v1ArozcvYBLf1f7cpsHI3WXp3c7Eg=
X-Received: by 2002:a67:3112:: with SMTP id x18mr1624935vsx.194.1551806586703;
 Tue, 05 Mar 2019 09:23:06 -0800 (PST)
MIME-Version: 1.0
References: <20190220145650.21566-1-olga.kornievskaia@gmail.com>
 <1550837576.6456.3.camel@redhat.com> <CAN-5tyH1e_cakjmU5VkQraw=ht71y8vxvaZbe2W6zAdfEnWLPA@mail.gmail.com>
 <1550853168.9958.1.camel@redhat.com> <CAN-5tyEpWevmXJb8weecFBm_V=FZm4Zc=b+rrwJFtMgUYhm2tg@mail.gmail.com>
 <1550863049.9958.3.camel@redhat.com> <cac1ddc0f4f2e70e1bfc2dc142f9675b68073440.camel@hammerspace.com>
In-Reply-To: <cac1ddc0f4f2e70e1bfc2dc142f9675b68073440.camel@hammerspace.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Tue, 5 Mar 2019 12:22:55 -0500
Message-ID: <CAN-5tyHd8QS+etzRjo_=ikg4smzL8T+xe6a3FMdge871VFKKsg@mail.gmail.com>
Subject: Re: [PATCH 1/1] SUNRPC: fix handling of half-closed connection
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "dwysocha@redhat.com" <dwysocha@redhat.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Feb 22, 2019 at 3:00 PM Trond Myklebust <trondmy@hammerspace.com> w=
rote:
>
> On Fri, 2019-02-22 at 14:17 -0500, Dave Wysochanski wrote:
> > On Fri, 2019-02-22 at 12:10 -0500, Olga Kornievskaia wrote:
> > > On Fri, Feb 22, 2019 at 11:32 AM Dave Wysochanski <
> > > dwysocha@redhat.co
> > > m> wrote:
> > > > On Fri, 2019-02-22 at 09:44 -0500, Olga Kornievskaia wrote:
> > > > > Hi Dave,
> > > > >
> > > > > A re-producer is a server that sends an ACK to the client's
> > > > > FIN/ACK
> > > > > request and does nothing afterwards (I can reproduce it 100%
> > > > > with
> > > > > a
> > > > > hacked up server. It was discovered with a "broken" server that
> > > > > doesn't fully closes a connection). It leave this client unable
> > > > > to
> > > > > connect to this server again indefinitely/forever/reboot
> > > > > required
> > > > > kind
> > > > > of state. Once it was considered that doing something like that
> > > > > to
> > > > > the
> > > > > client is a form of an attack (denial-of-server) and thus the
> > > > > kernel
> > > > > has a tcp_fin_timeout option after which the kernel will abort
> > > > > the
> > > > > connection. However this only applies to the sockets that have
> > > > > been
> > > > > closed by the client. This is NOT the case. NFS does not close
> > > > > the
> > > > > connection and it ignores kernel's notification of FIN_WAIT2
> > > > > state.
> > > > >
> > > >
> > > > Interesting.  I had the same reproducer but eventually an RST
> > > > would
> > > > get
> > > > sent from the NFS client due to the TCP keepalives.  It sounds
> > > > like
> > > > that is not the case anymore.  When I did my testing was over a
> > > > year
> > > > and a half ago though.
> > >
> > > after the keepalives the TCP also sends a FIN/ACK if the server
> > > properly sent a FIN/ACK back, then keep alive will indeed be
> > > sufficient. Can you check if in your trace server in one time sent
> > > just an ACK but in another case sent the FIN/ACK?
> > >
> >
> > I had two reproducers actually.  In both cases the NFS server would
> > never send a FIN.
> >
> > The first bug (https://bugzilla.redhat.com/show_bug.cgi?id=3D1458421)
> > was
> > about a NFS server crash after being in the half-close state.  An
> > NFS4
> > client without that keepalive patch would hang.
> > This is a valid test case and we check for that now in all releases.
> > Here's the outline:
> > # Outline
> > # Step 1. On NFS client: tcpdump -U -q -i $INTERFACE -w $PCAP_FILE -s
> > 0 port 2049 and host $NFS_SERVER
> > # Step 2. On NFS client, mount NFS4 server export with
> > "vers=3D4,timeo=3D5"
> > # Step 3. On NFS server, block outgoing FIN packets from the NFS
> > server"
> > # Step 4. On NFS server, using systemtap script, to delay
> > NFS4OPEN_CONFIRM response for a few seconds
> > # Step 5. On NFS client, open a file, which should get delayed and
> > trigger a FIN from the NFS client
> > # Step 6. On NFS server, after a short delay, crash the server by
> > 'echo c > /proc/sysrq-trigger'
> > # Step 7. On NFS client, wait for NFS server to reboot
> > # Step 8. On NFS client, wait for the NFS to reconnect TCP connection
> > # Step 9. On NFS client, wait for NFS4 grace period
> > # Step 10. On NFS client, try a 'ls' of the file created earlier
> > # Step 11. On NFS client, sleep for $DELAY seconds to allow all
> > operations to complete
> > # Step 12. On NFS client, ensure all operations have completed
> > # Step 13. Cleanup
> >
> >
> > The second test case (after the keepalive patch) was arguably invalid
> > test as I used systemtap on the NFS server to never close the socket
> > so
> > it would never send a FIN.  This obviously should never happen but at
> > the time I wanted to see if the NFS client would recover.
> > I did that with this:
> > probe module("sunrpc").function("svc_xprt_enqueue") {
> >       printf("%s: %s removing XPT_CLOSE from xprt =3D %p\n",
> > tz_ctime(gettimeofday_s()), ppfunc(), $xprt);
> >       $xprt->xpt_flags =3D $xprt->xpt_flags & ~(1 << 2);
> > }
> > Here's the full outline for this test:
> >
> > # This test checks automatic NFS TCP recovery after a specific
> > failure scenario.
> > # The failure scenario is with an NFSv3 mount that goes idle and the
> > NFS client closes the
> > # TCP connection, and the final FIN from the NFS server gets lost.
> > # This can be a tricky scenario since the NFS client's TCP may get
> > stuck in FIN-WAIT-2 indefinitely.
> > # The NFS client should be able to recover the NFS TCP connection
> > automatically without unmount/mount
> > # cycle or reboot, and the TCP connection should not be stuck in FIN-
> > WAIT-2 or any other non-connected
> > # state.
> > #
> > # Outline
> > # Step 1. On NFS client: tcpdump -U -q -i $INTERFACE -w $PCAP_FILE -s
> > 0 port 2049 and host $NFS_SERVER
> > # Step 2. On NFS client, mount NFS3 server export
> > # Step 3. On NFS server, using systemtap script, force the NFS server
> > to never send a FIN (avoid close)
> > # Step 4. On NFS client, verify the NFS mount with 'ls' and TCP
> > connection in TCP_ESTABLISHED
> > # Step 5. On NFS client, wait up to $time_limit seconds to allow NFS
> > TCP connection to transition to TIME_WAIT state
> > # Step 6. On NFS client, wait up to $time_limit seconds to allow NFS
> > TCP connection to disappear
> > # Step 7. Cleanup
> > #
> > # PASS: The state of NFS's TCP connection is usable by the end of the
> > test (commands don't hang, etc)
> > # FAIL: The state of the NFS TCP connection remains in FIN-WAIT-2
> > indefinitely
> >
> >
> > > > > One can argue that this is a broken server and we shouldn't
> > > > > bother.
> > > > > But this patch is an attempt to argue that the client still
> > > > > should
> > > > > care and deal with this condition. However, if the community
> > > > > feels
> > > > > that a broken server is a broken server and this form of an
> > > > > attack is
> > > > > not interested, this patch can live will be an archive for
> > > > > later
> > > > > or
> > > > > never.
> > > > >
> > > >
> > > > This isn't IPoIB is it?
> > >
> > > No, just normal TCP.
> > >
> > >
> > > > Actually, fwiw, looking back I had speculated on changes in this
> > > > area.
> > > > I'm adding you to the CC list of this bug which had some of my
> > > > musings
> > > > on it:
> > > > https://bugzilla.redhat.com/show_bug.cgi?id=3D1466802#c43
> > > > That bug I ended up closing when we could no longer prove there
> > > > was
> > > > any
> > > > state where the NFS client could get stuck in FIN_WAIT2 after the
> > > > keepalive patch.
> > >
> > > I can reproduce current behavior with the current upstream code.
> > >
> > >
> > > > It can happen that the server only sends the ACK back to the
> > > > clients
> > > > FIN,ACK so in general the testcase is valid.  But then the
> > > > question
> > > > is
> > > > how long should one wait for the final data and FIN from the
> > > > server, or
> > > > are there ever instances where you shouldn't wait forever?  Is
> > > > there a
> > > > way for us to know for sure there is no data left to receive so
> > > > it's
> > > > safe to timeout?  No RPCs outstanding?
> > >
> > > Yep all good questions which I don't have answers to. I realize
> > > that
> > > for instance, that a server might send an ACK and then send a
> > > FIN/ACK
> > > after that. But why is it bad for the client to proactively send an
> > > RST (by shutting down the connection in TCP_FIN_WAIT2 if the client
> > > was shutting down the connection anyway.
> > >
> > I think you could lose data from the server if you RST and don't wait
> > but other than that I don't know.  We may be splitting hairs here
> > though if there's no demonstrable harm to the application (NFS).  As
> > Trond points out elsewhere reconnect / port reuse may be an issue.
> >
> > When I looked at this in the second bug I was almost convinced that
> > there was a problem with the 'close' method in xs_tcp_ops - we needed
> > to be calling xs_close(), but I ran into some problems and I wasn't
> > sure about the test case.
> >
> >
> > > > I don't claim to know many of the subtleties here as far as would
> > > > the
> > > > server wait forever in LAST_ACK or do implementations eventually
> > > > timeout after some time?  Seems like if these last packets get
> > > > lost
> > > > there is likely a bug somewhere (either firewall or TCP stack,
> > > > etc).
> > > > https://tools.ietf.org/html/rfc793#page-22
> > > >
> > > > It looks like at least some people are putting timeouts into
> > > > their
> > > > stacks though I'm not sure that's a good idea or not.
> > >
> > > I saw only one other driver in the kernel that does have handling
> > > of
> > > the TCP_FIN_WAIT2 state (driver/crypto/chelsio) ...
> >
> > One final thought - is it possible that we could have a network that
> > does not support TCP keepalives?  In that instance, I'll bet we could
> > get an indefinite hang in FIN_WAIT2 on my first test case (server
> > crashed after the half-close state).
> >
> > It does not look like TCP keepalives have to be implemented and maybe
> > some routers / NATs / firewalls disallow them (due to extra traffic)?
> > https://tools.ietf.org/html/rfc1122#page-101
>
>
> Again, that's a corner case of a corner case. I've never seen any
> reports of this occurring.
>
> On the other hand, I _have_ seen lots of reports of problems due to the
> reconnection issues when the server still holds the socket open. Those
> reports were the main reason for the current design.

Continuing on with this thread: what I can gather so far.

NFS has an idle timer itself which expires
        INIT_WORK(&xprt->task_cleanup, xprt_autoclose);
        if (xprt_has_timer(xprt))
               timer_setup(&xprt->timer, xprt_init_autodisconnect, 0);
        else
               timer_setup(&xprt->timer, NULL, 0);

The xprt_autoclose() is what triggers TCP client to send tcp_send_fin().

Xprt_autoclose() calls kernel_Sock_shutdown() but I don=E2=80=99t believe
that=E2=80=99s sufficient to =E2=80=9Cclose the socket=E2=80=9D. What is ne=
eded is to call
sock_release() so socket is not orphaned.

As a reply to its FIN/ACK it gets back an ACK (putting it in FIN_WAIT2
which TCP notifies the NFS and NFS ignores it instead of closing the
socket as it does for other states like CLOSE_WAIT). Socket is not
closed so no tcp_fin_timeout is set.

>
> --
> Trond Myklebust
> CTO, Hammerspace Inc
> 4300 El Camino Real, Suite 105
> Los Altos, CA 94022
> www.hammer.space
>
>
