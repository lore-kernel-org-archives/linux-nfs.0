Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.0 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_CR_TRAILER,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE660C433E0
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Mar 2021 20:12:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 8C37965141
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Mar 2021 20:12:59 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231489AbhCIUM0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Mar 2021 15:12:26 -0500
Received: from us-smtp-delivery-124.mimecast.com ([216.205.24.124]:60962 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S230431AbhCIUMK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Mar 2021 15:12:10 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1615320730;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=TRfKdPrmqvSCWFhsAB8HGeGpSOoesCI0ujxU5bUBUVg=;
        b=dAk7H+4E4u+DQGyMtU331U0wpqPCXF3bpgba6rd6ozOCBM8BNlnAAEhIoiH769DaOpA4vj
        UHAzAZ7A6R/n9eVKVqBHYAGxcV1+Rf1f/t04aR1H85LEoe9xaraH1JSToiqtw89yEc4cl5
        qRVlXATQEibxi0gKdFgPHpiusgTxfLw=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-263-FDd_AXTTNXy3Y_Rzljjn4g-1; Tue, 09 Mar 2021 15:12:08 -0500
X-MC-Unique: FDd_AXTTNXy3Y_Rzljjn4g-1
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 40E59800C78;
        Tue,  9 Mar 2021 20:12:07 +0000 (UTC)
Received: from pick.fieldses.org (ovpn-114-27.phx2.redhat.com [10.3.114.27])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 239031037E82;
        Tue,  9 Mar 2021 20:12:07 +0000 (UTC)
Received: by pick.fieldses.org (Postfix, from userid 2815)
        id 2C22A120594; Tue,  9 Mar 2021 15:12:06 -0500 (EST)
Date:   Tue, 9 Mar 2021 15:12:06 -0500
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] NFSD: fix error handling in callbacks
Message-ID: <YEfWlkKaIr2lz896@pick.fieldses.org>
References: <20210309144127.57833-1-olga.kornievskaia@gmail.com>
 <YEeWK+gs4c8O7k0u@pick.fieldses.org>
 <20210309194519.GF2597609@aion.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210309194519.GF2597609@aion.usersys.redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Mar 09, 2021 at 02:45:19PM -0500, Scott Mayhew wrote:
> On Tue, 09 Mar 2021, J. Bruce Fields wrote:
> 
> > On Tue, Mar 09, 2021 at 09:41:27AM -0500, Olga Kornievskaia wrote:
> > > From: Olga Kornievskaia <kolga@netapp.com>
> > > 
> > > When the server tries to do a callback and a client fails it due to
> > > authentication problems, we need the server to set callback down
> > > flag in RENEW so that client can recover.
> > 
> > I was looking at this.  It looks to me like this should really be just:
> > 
> > 	case 1:
> > 		if (task->tk_status)
> > 			nfsd4_mark_cb_down(clp, task->tk_status);
> > 
> > If tk_status showed an error, and the ->done method doesn't return 0 to
> > tell us it something worth retrying, then the callback failed
> > permanently, so we should mark the callback path down, regardless of the
> > exact error.
> 
> That switch was added because the server was erroneously setting
> SEQ4_STATUS_CB_PATH_DOWN in the event that a client returned an
> NFS-level error for a CB_RECALL that the client had already done a
> FREE_STATEID for.  Removing the switch will cause the server to go back
> to that behaviour, won't it?

Oh, thanks for the history.

My knee-jerk reaction is: that sounds like a recall-specific issue, so
maybe that logic should be in nfsd4_cb_recall_done?

I guess I'm OK continuing instead to enumerate transport-layer errors in
nfsd4_cb_done, but do we know that EACCES makes it a complete list?

--b.

> 
> -Scott
> > 
> > --b.
> > 
> > > 
> > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > ---
> > >  fs/nfsd/nfs4callback.c | 1 +
> > >  1 file changed, 1 insertion(+)
> > > 
> > > diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> > > index 052be5bf9ef5..7325592b456e 100644
> > > --- a/fs/nfsd/nfs4callback.c
> > > +++ b/fs/nfsd/nfs4callback.c
> > > @@ -1189,6 +1189,7 @@ static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
> > >  		switch (task->tk_status) {
> > >  		case -EIO:
> > >  		case -ETIMEDOUT:
> > > +		case -EACCES:
> > >  			nfsd4_mark_cb_down(clp, task->tk_status);
> > >  		}
> > >  		break;
> > > -- 
> > > 2.27.0
> > > 
> > 

