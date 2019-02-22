Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF70AC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 19:17:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8C90B206B6
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 19:17:33 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725902AbfBVTRc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 14:17:32 -0500
Received: from mail-qt1-f193.google.com ([209.85.160.193]:36630 "EHLO
        mail-qt1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725767AbfBVTRc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 14:17:32 -0500
Received: by mail-qt1-f193.google.com with SMTP id p25so3794007qtb.3
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 11:17:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=n7FSBEECNe5Zqx3AJURAyltJvG5Xu/dxrO4UAmXQUNg=;
        b=kbCXaR7UMMHoSIVZLPOEo++JVs9TAD+9981gAZvBhVzztbJoQdGGVTwrRS+9kqcfOv
         wjwtFuuW1gUkJciTGjItEEJUMGWnOwcQkXUerfoC96yvoaUIE/yeQW4jB5CtxGkyZqKD
         KLVUPBB5eJE6IFUqeN2zwnR26TBaPeptWXPCdkmvBzIzPNSMvNDWcknCxCXvhYBqhcYB
         ucbL2x4CdIm+L+WMAnsFWVTZYXoIRYDDG3Ptzz5t/goqtTh5ueIsEFKFm5+LXYfStnhZ
         0ewyzq9w1YD12LRu4sYlZH6l5YKxnktjROA65P1a6UlqnTjfNeKuH1tS0KFkWMvp+iHi
         42Rw==
X-Gm-Message-State: AHQUAubd6kINdnuNnLsL2sD4xVvFvQkHhM+7TdBRhbxR0I6w1EbgO/1D
        y4ZM+6AK3yC0vwZjPTdWpoD0J804Txs=
X-Google-Smtp-Source: AHgI3Ia3he6HDl8YXr+cVZbr/uVfTuua43/UoliKg/IL1CQ01HOxNHrYZoalRI/dD5drF7H9UxjR3A==
X-Received: by 2002:a0c:8938:: with SMTP id 53mr4422667qvp.165.1550863051026;
        Fri, 22 Feb 2019 11:17:31 -0800 (PST)
Received: from dhcp-12-212-173.gsslab.rdu.redhat.com (nat-pool-rdu-t.redhat.com. [66.187.233.202])
        by smtp.gmail.com with ESMTPSA id z42sm1349822qta.28.2019.02.22.11.17.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 11:17:30 -0800 (PST)
Message-ID: <1550863049.9958.3.camel@redhat.com>
Subject: Re: [PATCH 1/1] SUNRPC: fix handling of half-closed connection
From:   Dave Wysochanski <dwysocha@redhat.com>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Date:   Fri, 22 Feb 2019 14:17:29 -0500
In-Reply-To: <CAN-5tyEpWevmXJb8weecFBm_V=FZm4Zc=b+rrwJFtMgUYhm2tg@mail.gmail.com>
References: <20190220145650.21566-1-olga.kornievskaia@gmail.com>
         <1550837576.6456.3.camel@redhat.com>
         <CAN-5tyH1e_cakjmU5VkQraw=ht71y8vxvaZbe2W6zAdfEnWLPA@mail.gmail.com>
         <1550853168.9958.1.camel@redhat.com>
         <CAN-5tyEpWevmXJb8weecFBm_V=FZm4Zc=b+rrwJFtMgUYhm2tg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-14.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2019-02-22 at 12:10 -0500, Olga Kornievskaia wrote:
> On Fri, Feb 22, 2019 at 11:32 AM Dave Wysochanski <dwysocha@redhat.co
> m> wrote:
> > 
> > On Fri, 2019-02-22 at 09:44 -0500, Olga Kornievskaia wrote:
> > > Hi Dave,
> > > 
> > > A re-producer is a server that sends an ACK to the client's
> > > FIN/ACK
> > > request and does nothing afterwards (I can reproduce it 100% with
> > > a
> > > hacked up server. It was discovered with a "broken" server that
> > > doesn't fully closes a connection). It leave this client unable
> > > to
> > > connect to this server again indefinitely/forever/reboot required
> > > kind
> > > of state. Once it was considered that doing something like that
> > > to
> > > the
> > > client is a form of an attack (denial-of-server) and thus the
> > > kernel
> > > has a tcp_fin_timeout option after which the kernel will abort
> > > the
> > > connection. However this only applies to the sockets that have
> > > been
> > > closed by the client. This is NOT the case. NFS does not close
> > > the
> > > connection and it ignores kernel's notification of FIN_WAIT2
> > > state.
> > > 
> > 
> > Interesting.  I had the same reproducer but eventually an RST would
> > get
> > sent from the NFS client due to the TCP keepalives.  It sounds like
> > that is not the case anymore.  When I did my testing was over a
> > year
> > and a half ago though.
> 
> after the keepalives the TCP also sends a FIN/ACK if the server
> properly sent a FIN/ACK back, then keep alive will indeed be
> sufficient. Can you check if in your trace server in one time sent
> just an ACK but in another case sent the FIN/ACK?
> 

I had two reproducers actually.  In both cases the NFS server would
never send a FIN.

The first bug (https://bugzilla.redhat.com/show_bug.cgi?id=1458421) was
about a NFS server crash after being in the half-close state.  An NFS4
client without that keepalive patch would hang.
This is a valid test case and we check for that now in all releases. 
Here's the outline:
# Outline
# Step 1. On NFS client: tcpdump -U -q -i $INTERFACE -w $PCAP_FILE -s 0 port 2049 and host $NFS_SERVER
# Step 2. On NFS client, mount NFS4 server export with "vers=4,timeo=5"
# Step 3. On NFS server, block outgoing FIN packets from the NFS server"
# Step 4. On NFS server, using systemtap script, to delay NFS4OPEN_CONFIRM response for a few seconds
# Step 5. On NFS client, open a file, which should get delayed and trigger a FIN from the NFS client
# Step 6. On NFS server, after a short delay, crash the server by 'echo c > /proc/sysrq-trigger'
# Step 7. On NFS client, wait for NFS server to reboot
# Step 8. On NFS client, wait for the NFS to reconnect TCP connection
# Step 9. On NFS client, wait for NFS4 grace period
# Step 10. On NFS client, try a 'ls' of the file created earlier
# Step 11. On NFS client, sleep for $DELAY seconds to allow all operations to complete
# Step 12. On NFS client, ensure all operations have completed
# Step 13. Cleanup


The second test case (after the keepalive patch) was arguably invalid
test as I used systemtap on the NFS server to never close the socket so
it would never send a FIN.  This obviously should never happen but at
the time I wanted to see if the NFS client would recover.
I did that with this:
probe module("sunrpc").function("svc_xprt_enqueue") {
	printf("%s: %s removing XPT_CLOSE from xprt = %p\n", tz_ctime(gettimeofday_s()), ppfunc(), $xprt);
	$xprt->xpt_flags = $xprt->xpt_flags & ~(1 << 2);
}
Here's the full outline for this test:

# This test checks automatic NFS TCP recovery after a specific failure scenario.
# The failure scenario is with an NFSv3 mount that goes idle and the NFS client closes the
# TCP connection, and the final FIN from the NFS server gets lost.
# This can be a tricky scenario since the NFS client's TCP may get stuck in FIN-WAIT-2 indefinitely.
# The NFS client should be able to recover the NFS TCP connection automatically without unmount/mount
# cycle or reboot, and the TCP connection should not be stuck in FIN-WAIT-2 or any other non-connected
# state.
# 
# Outline
# Step 1. On NFS client: tcpdump -U -q -i $INTERFACE -w $PCAP_FILE -s 0 port 2049 and host $NFS_SERVER
# Step 2. On NFS client, mount NFS3 server export
# Step 3. On NFS server, using systemtap script, force the NFS server to never send a FIN (avoid close)
# Step 4. On NFS client, verify the NFS mount with 'ls' and TCP connection in TCP_ESTABLISHED
# Step 5. On NFS client, wait up to $time_limit seconds to allow NFS TCP connection to transition to TIME_WAIT state
# Step 6. On NFS client, wait up to $time_limit seconds to allow NFS TCP connection to disappear
# Step 7. Cleanup
#
# PASS: The state of NFS's TCP connection is usable by the end of the test (commands don't hang, etc)
# FAIL: The state of the NFS TCP connection remains in FIN-WAIT-2 indefinitely


> > > One can argue that this is a broken server and we shouldn't
> > > bother.
> > > But this patch is an attempt to argue that the client still
> > > should
> > > care and deal with this condition. However, if the community
> > > feels
> > > that a broken server is a broken server and this form of an
> > > attack is
> > > not interested, this patch can live will be an archive for later
> > > or
> > > never.
> > > 
> > 
> > This isn't IPoIB is it?
> 
> No, just normal TCP.
> 
> 
> > Actually, fwiw, looking back I had speculated on changes in this
> > area.
> > I'm adding you to the CC list of this bug which had some of my
> > musings
> > on it:
> > https://bugzilla.redhat.com/show_bug.cgi?id=1466802#c43
> > That bug I ended up closing when we could no longer prove there was
> > any
> > state where the NFS client could get stuck in FIN_WAIT2 after the
> > keepalive patch.
> 
> I can reproduce current behavior with the current upstream code.
> 
> 
> > It can happen that the server only sends the ACK back to the
> > clients
> > FIN,ACK so in general the testcase is valid.  But then the question
> > is
> > how long should one wait for the final data and FIN from the
> > server, or
> > are there ever instances where you shouldn't wait forever?  Is
> > there a
> > way for us to know for sure there is no data left to receive so
> > it's
> > safe to timeout?  No RPCs outstanding?
> 
> Yep all good questions which I don't have answers to. I realize that
> for instance, that a server might send an ACK and then send a FIN/ACK
> after that. But why is it bad for the client to proactively send an
> RST (by shutting down the connection in TCP_FIN_WAIT2 if the client
> was shutting down the connection anyway.
> 
I think you could lose data from the server if you RST and don't wait
but other than that I don't know.  We may be splitting hairs here
though if there's no demonstrable harm to the application (NFS).  As
Trond points out elsewhere reconnect / port reuse may be an issue.

When I looked at this in the second bug I was almost convinced that
there was a problem with the 'close' method in xs_tcp_ops - we needed
to be calling xs_close(), but I ran into some problems and I wasn't
sure about the test case.


> > I don't claim to know many of the subtleties here as far as would
> > the
> > server wait forever in LAST_ACK or do implementations eventually
> > timeout after some time?  Seems like if these last packets get lost
> > there is likely a bug somewhere (either firewall or TCP stack,
> > etc).
> > https://tools.ietf.org/html/rfc793#page-22
> > 
> > It looks like at least some people are putting timeouts into their
> > stacks though I'm not sure that's a good idea or not.
> 
> I saw only one other driver in the kernel that does have handling of
> the TCP_FIN_WAIT2 state (driver/crypto/chelsio) ...


One final thought - is it possible that we could have a network that
does not support TCP keepalives?  In that instance, I'll bet we could
get an indefinite hang in FIN_WAIT2 on my first test case (server
crashed after the half-close state).

It does not look like TCP keepalives have to be implemented and maybe
some routers / NATs / firewalls disallow them (due to extra traffic)?
https://tools.ietf.org/html/rfc1122#page-101


