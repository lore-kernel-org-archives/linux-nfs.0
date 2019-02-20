Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F02F0C4360F
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 02:20:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B1D8F2183E
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 02:20:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="Hx/2U7zh"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727264AbfBTCUX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 21:20:23 -0500
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:45226 "EHLO
        bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726235AbfBTCUX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 21:20:23 -0500
Received: from localhost (localhost [127.0.0.1])
        by bedivere.hansenpartnership.com (Postfix) with ESMTP id 5C7498EE235;
        Tue, 19 Feb 2019 18:20:22 -0800 (PST)
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
        by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id s9oNZuQAem3F; Tue, 19 Feb 2019 18:20:22 -0800 (PST)
Received: from [153.66.254.194] (unknown [50.35.68.20])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id 7A7E28EE21A;
        Tue, 19 Feb 2019 18:20:21 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
        s=20151216; t=1550629221;
        bh=Sv05kO616trax6QX+MKM8GQoT95dBmrnAy9m8tcgS+U=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=Hx/2U7zh6bPP50kPafInPt5h8xpRnWpTE6DK1PBZw4PWDDrBwQMwyUajynAGYxcPd
         KxEkrdu1tD2aCxGQTLl5dxmVgEuC21bt3yFrqUir4ZIl6XB9G3miFn/zIFccie3Gox
         TX7lmNgsPT0d1ornz8fKEze4OEViFT4q5xX4Y0UA=
Message-ID: <1550629220.11684.3.camel@HansenPartnership.com>
Subject: Re: [RFC PATCH 02/27] containers: Implement containers as kernel
 objects
From:   James Bottomley <James.Bottomley@HansenPartnership.com>
To:     David Howells <dhowells@redhat.com>
Cc:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org, linux-security-module@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, rgb@redhat.com,
        linux-kernel@vger.kernel.org,
        containers@lists.linux-foundation.org, cgroups@vger.kernel.org
Date:   Tue, 19 Feb 2019 18:20:20 -0800
In-Reply-To: <19562.1550617574@warthog.procyon.org.uk>
References: <1550432358.2809.21.camel@HansenPartnership.com>
         <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
         <155024685321.21651.1504201877881622756.stgit@warthog.procyon.org.uk>
         <19562.1550617574@warthog.procyon.org.uk>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, 2019-02-19 at 23:06 +0000, David Howells wrote:
> James Bottomley <James.Bottomley@HansenPartnership.com> wrote:
> 
> > I thought we got agreement years ago that containers don't exist in
> > Linux as a single entity: they're currently a collection of cgroups
> > and namespaces some of which may and some of which may not be local
> > to the entity the orchestration system thinks of as a "container".
> 
> I wasn't party to that agreement and don't feel particularly bound by
> it.

That's not at all relevant, is it?  The point is we have widespread
uses of namespaces and cgroups that span containers today meaning that
a "container id" becomes a problematic concept.  What we finally got to
with the audit people was an unmodifiable label which the orchestration
system can set ... can't you just use that?

James

