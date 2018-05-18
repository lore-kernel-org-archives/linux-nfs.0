Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50370 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752403AbeERUmk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 May 2018 16:42:40 -0400
Message-ID: <1526676158.10011.29.camel@redhat.com>
Subject: Re: [PATCH RFC 0/4] Use correct NFSv4.0 callback credential
From: Simo Sorce <simo@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Fri, 18 May 2018 16:42:38 -0400
In-Reply-To: <CAN-5tyGOK+5OUGrn5i=97y+OhanNa8jdnof4BCXvFpW0-ch9dQ@mail.gmail.com>
References: <20180518153018.7706.87172.stgit@klimt.1015granger.net>
         <CAN-5tyGDGOqPKXKD+LQq8Ub3CUosmaaAq=ir3Gp7R3LKABwtEQ@mail.gmail.com>
         <DB8E23EF-80A4-48D0-B53C-AD2A4B0076E2@oracle.com>
         <CAN-5tyFs4nxAwVynpr=Q5d_t+N5s9sa=2+1mj4-pZ-m1Xe3ZRA@mail.gmail.com>
         <CAN-5tyGOK+5OUGrn5i=97y+OhanNa8jdnof4BCXvFpW0-ch9dQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2018-05-18 at 16:19 -0400, Olga Kornievskaia wrote:
> I think the srchost is needed only if we are going to deal with doing
> something cross-DNS domains so say if
> host@klim.ib.1015granger.net will authenticate to
> nfs@klim.roce.1015granger.net, then the target's domain would not be
> sufficient to match which source domain name to use. So if this the
> use case, then sorry I just had to think out-loud to get here, then we
> do need srcdomain (and it's really a domain isn't it and not host
> that's of interest?).

I am confused about your use of the term "domain" here.

Can you use either REALM or hostname appropriately ?

Or are you using the term "domain" to mean FQDN ?

Simo.

-- 
Simo Sorce
Sr. Principal Software Engineer
Red Hat, Inc

