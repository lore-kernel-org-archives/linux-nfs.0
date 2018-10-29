Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA7A4C2BC61
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 06:29:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5E9C02082D
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 06:29:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E9C02082D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729198AbeJ2PQt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 11:16:49 -0400
Received: from mx1.redhat.com ([209.132.183.28]:52110 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729186AbeJ2PQt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 29 Oct 2018 11:16:49 -0400
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2B3AC30013E7;
        Mon, 29 Oct 2018 06:29:34 +0000 (UTC)
Received: from pluto-themaw-net.localdomain (ovpn-116-32.sin2.redhat.com [10.67.116.32])
        by smtp.corp.redhat.com (Postfix) with ESMTP id AB25619753;
        Mon, 29 Oct 2018 06:29:33 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
        by pluto-themaw-net.localdomain (Postfix) with ESMTP id 9B2711C0051;
        Mon, 29 Oct 2018 14:29:31 +0800 (AWST)
Message-ID: <7f3f7fc5125ae1840a553ea85d761c9e1e63cbe8.camel@redhat.com>
Subject: Re: [Libtirpc-devel] [PATCH 04/13] clnt_vc.c: resource_leak
From:   Ian Kent <ikent@redhat.com>
To:     Steve Dickson <steved@redhat.com>,
        Libtirpc-devel Mailing List 
        <libtirpc-devel@lists.sourceforge.net>
Cc:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date:   Mon, 29 Oct 2018 14:29:31 +0800
In-Reply-To: <08441cd678693753ee63ff40568ddaf2168da637.camel@redhat.com>
References: <20180907180151.178872-1-steved@redhat.com>
         <20180907180151.178872-5-steved@redhat.com>
         <08441cd678693753ee63ff40568ddaf2168da637.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Mon, 29 Oct 2018 06:29:34 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 2018-10-29 at 14:24 +0800, Ian Kent wrote:
> On Fri, 2018-09-07 at 14:01 -0400, Steve Dickson wrote:
> > Variable "ct" going out of scope leaks the storage it points to.
> > 
> > Signed-off-by: Steve Dickson <steved@redhat.com>
> > ---
> >  src/clnt_vc.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/src/clnt_vc.c b/src/clnt_vc.c
> > index 3d775c7..10ee91a 100644
> > --- a/src/clnt_vc.c
> > +++ b/src/clnt_vc.c
> > @@ -325,6 +325,8 @@ clnt_vc_create(fd, raddr, prog, vers, sendsz, recvsz)
> >  	recvsz = __rpc_get_t_size(si.si_af, si.si_proto, (int)recvsz);
> >  	xdrrec_create(&(ct->ct_xdrs), sendsz, recvsz,
> >  	    cl->cl_private, read_vc, write_vc);
> > +	mem_free(ct->ct_addr.buf, ct->ct_addr.len);
> > +	mem_free(ct, sizeof (struct ct_data));
> >  	return (cl);
> >  
> >  err:
> 
> Are you sure about this one Steve?
> 
> aka:
>         /*
>          * Create a client handle which uses xdrrec for serialization
>          * and authnone for authentication.
>          */
>         cl->cl_ops = clnt_vc_ops();
>         cl->cl_private = ct;             <------?
>         cl->cl_auth = authnone_create();
>         sendsz = __rpc_get_t_size(si.si_af, si.si_proto, (int)sendsz);
>         recvsz = __rpc_get_t_size(si.si_af, si.si_proto, (int)recvsz);
>         xdrrec_create(&(ct->ct_xdrs), sendsz, recvsz,
>             cl->cl_private, read_vc, write_vc);
>         return (cl);

Oh!

My bad, reverted in commit e49077d2fa.

