Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E20EC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 17:44:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3A1E12146E
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 17:44:06 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726152AbfBTRoF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 12:44:05 -0500
Received: from fieldses.org ([173.255.197.46]:49208 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725796AbfBTRoF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Feb 2019 12:44:05 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 985E8189; Wed, 20 Feb 2019 12:44:04 -0500 (EST)
Date:   Wed, 20 Feb 2019 12:44:04 -0500
To:     James Pearson <jcpearson@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: nfsd thread limit and UDP ?
Message-ID: <20190220174404.GB4399@fieldses.org>
References: <CAK3fRr9EL-YOp3yUr5tMe5zuiERxHjkLDhAaWkxxEHjtfSwisQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK3fRr9EL-YOp3yUr5tMe5zuiERxHjkLDhAaWkxxEHjtfSwisQ@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Feb 20, 2019 at 11:28:53AM +0000, James Pearson wrote:
> On a very busy NFSv3 server (running CentOS 6), we recently upped the
> nfsd thread count to 1024 - but this caused client mount requests over
> UDP to fail.
> 
> We configure all our clients to use TCP for NFS mounts, but the
> automounter (automountd) on MacOS (up to version MacOS 10.12) seeds a
> 'null call' to the NFS server over UDP before attempting the mount -
> but the server appears to ignore any UDP requests - and the automount
> fails
> 
> I can also reproduce the issue on a Linux client via:
> 
>  mount -o udp,nfsvers=3 server:/export /mount/point
> 
> I've found, by trial and error, that the maximum number of nfsd
> threads that can be run on the server is 1017 before UDP mount
> requests fail

Thanks for investigating, that's very weird and interesting!

Just looking through the UDP code in net/sunrpc/svcsock.c....  I wonder
if it's this:

	svc_sock_setbufsize(svsk->sk_sock,
                                (serv->sv_nrthreads+3) * serv->sv_max_mesg,
                                (serv->sv_nrthreads+3) * serv->sv_max_mesg);

sv_max_mesg will be about 2^20, so the result will be about 2^30 in your case.
Then svc_sock_setbufsize throws in another multiple of 2:

	sock->sk->sk_sndbuf = snd * 2;
        sock->sk->sk_rcvbuf = rcv * 2;

so we've got to be very close to overflowing sk_sndbuf and sk_rcvbuf, which are
ints.

--b.
