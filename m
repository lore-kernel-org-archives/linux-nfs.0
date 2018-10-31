Return-Path: <SRS0=WZcR=NL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41A49ECDE44
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 18:55:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ECACE20664
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 18:55:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ub2HqRIL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECACE20664
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730675AbeKADyW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 23:54:22 -0400
Received: from mail-vs1-f67.google.com ([209.85.217.67]:42762 "EHLO
        mail-vs1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730097AbeKADyV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 23:54:21 -0400
Received: by mail-vs1-f67.google.com with SMTP id e126so10691425vsc.9
        for <linux-nfs@vger.kernel.org>; Wed, 31 Oct 2018 11:55:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Z2bd/t0CKMRyVHfOY/xof4u0BYbqNdKFnoBYt1Zr4tc=;
        b=ub2HqRILdR0ic+Smsq/Kwoa2mUzUEWT56mh8GX5T3P2q8KWrH987cAnZNU2UlGTbWZ
         fHno0qahR5e5xJiUkk87C9cn6lp4z7bsS3v0fD+cySjrmFKf668Wy5nypQXe+R1L71oM
         EckA/sH3fTGB1Wy9GEcD+jBwn5c8YrUDkNXAW7ZzjjD9EPiFhzPCWSrojT29wF/1fO6F
         uXncLULGh9wag/rCJvYbxOmT0Hl8pZ0d1JaeNuN2UDGihW4E2lhC9sW0chNvwslV/BJo
         MclyVZ/S6YZcDlQ8U9GRy2kb+3gqphXJ9Hmuf+lhS5EZbL/t6PsoKuvU4ptjhrEq+CPH
         1CZw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Z2bd/t0CKMRyVHfOY/xof4u0BYbqNdKFnoBYt1Zr4tc=;
        b=ECGNOva02D4HSlYdnykwh42IC2eLBz/NL/8GoBBUVGq5rpClylU/GAzjF+/TGxsbio
         mqm3X7d4S1YJVgghoCYMnFOq7NFjt5o6Kvjqofjr2RLTsFvAD0GdRBcrBH9Vj0TfJXpm
         6E+WNdbUAAm8Q0Le4ryXVS0GpR6G+beEPeYgNPcgQZP9mVAi3a644R6bPrUAdQ3ITGsL
         OqgaWGr3ijXSBHK3BpwN2hiHynH1hLixVdBal2kqA7tn2enX0EDJXsmk+bxnY1urAy2L
         xZlHaboecHd7ycwamT39X3dACxcfaZNlSTs5k4tEtXqeqNwa3Z1soVGNlCR8lcd92/iF
         1eBQ==
X-Gm-Message-State: AGRZ1gKYZ14OBHiee+2xObfUUEd2h6V2+kPAlQ3ONLzGMVa7zaPvzDWA
        Eot3QmNTxuETM+PFHr0BWeao9r8KcrFwdcVNtXX+iA==
X-Google-Smtp-Source: AJdET5d4OoFwl12DMDeJiRU9nzbbH3YbeH8iu3gkjSGsd+QT9675LHIjx0diZ19Y2TsQUuOlsNYQ9A5PY7fTGxZSTNU=
X-Received: by 2002:a67:4285:: with SMTP id p127mr1865705vsa.134.1541012102760;
 Wed, 31 Oct 2018 11:55:02 -0700 (PDT)
MIME-Version: 1.0
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-5-olga.kornievskaia@gmail.com> <20181031184042.GD3377@fieldses.org>
In-Reply-To: <20181031184042.GD3377@fieldses.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Wed, 31 Oct 2018 14:54:51 -0400
Message-ID: <CAN-5tyGuVF30ynxYj_EaWDjJJyJTXLXWb=O516XJsThk9AsUvQ@mail.gmail.com>
Subject: Re: [PATCH v1 04/13] NFS inter ssc open
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Oct 31, 2018 at 2:40 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> Just to pick one thing that I don't understand yet:
>
> On Fri, Oct 19, 2018 at 11:28:56AM -0400, Olga Kornievskaia wrote:
> > +EXPORT_SYMBOL_GPL(nfs42_ssc_open);
> > +void nfs42_ssc_close(struct file *filep)
> > +{
> > +     struct nfs_open_context *ctx = nfs_file_open_context(filep);
> > +
> > +     ctx->state->flags = 0;
>
> Why is this needed?

This is needed so that CLOSE isn't going on the wire but closed internally.

> Also, given the name and the pairing with nfs42_ssc_open(), would it be
> more logical for it to do the fput() as well?

I'd like to keep that fput() in the nfsd to make it consistent with
the "intra". There are fput()s for intra but intra doesn't call into
nfs42_ssc_close().
