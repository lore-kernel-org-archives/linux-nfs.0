Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AF7FC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 19:01:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5989C2064A
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 19:01:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=netronome-com.20150623.gappssmtp.com header.i=@netronome-com.20150623.gappssmtp.com header.b="G5lFCDqA"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726616AbfCOTBK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 15:01:10 -0400
Received: from mail-qt1-f196.google.com ([209.85.160.196]:38536 "EHLO
        mail-qt1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726157AbfCOTBK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Mar 2019 15:01:10 -0400
Received: by mail-qt1-f196.google.com with SMTP id s1so11305653qte.5
        for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2019 12:01:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=netronome-com.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:in-reply-to:references
         :organization:mime-version:content-transfer-encoding;
        bh=Tt74taR+I4n4EJ6GGKXdE9G8sRdEp6/HN0fFstPOZ3E=;
        b=G5lFCDqA3/fSrPG0Nm1i6o5WQblWoEajgnp320cKCSIp/1PGELZlaaMHhBTpqadTFx
         W4cimns3oAkV91LjnUqTep85XkHF1WljJ2NdDrbBYFyzsqXb77NOSEEVQ+X+KrNeOM3H
         2BDlWedpcXNL5+O5gLchUTWTJAw/hUFMTBJo508Bg/34mj9rz5R9V5wbglKTyKRjT949
         X4IEj86+kwG5O4VWiO/kwOJG/5BwDFR3YRoMSUm2xdDp9SN5zbUqmhg9FXuatcmmLq8w
         rJx8/pHZR9zbUzoKDjnJOu3GkiDqzTrxXPhJeNI1DsdM9glaFSjvrkndS3KCejZvCLU8
         MoZQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:in-reply-to
         :references:organization:mime-version:content-transfer-encoding;
        bh=Tt74taR+I4n4EJ6GGKXdE9G8sRdEp6/HN0fFstPOZ3E=;
        b=K/hBRQrV8FBGaGIiWwDoYUe/xuBAMzBVR5mcGbCb3q05LTW060xfrVW+Uu+myOGdPg
         AN4VsS373PRvayqE7qarWrQJgs2UDAge9H9/K3Ph0OnkWZePyekU2r1dc+jATEGiT70W
         NytcxGLWHc1ssDLw8KLroesg7zX17a/c1aapVVpdujQy2G2CNEN0UVAFHCUK1wFUeMLi
         yzbJs4KN2bUjOwIlUWaPhT11/xuCtH2eQxvKa/vcnAJ7aUmTHzmeRWKvZWwlugojfvwv
         jlpdZBofVDQPLTtIVY6tchP9Ep6iW6PvNh2OIQAMjK3Dq2/hTHGpovJD7eJI0J8dPm+M
         FSIA==
X-Gm-Message-State: APjAAAUBuGj/1jhjI4nvhRHY/hwvMphU2iquBjv/b2W/LpLMuVLJNazo
        VJnD9NPsIXoz9cZwCTmm5qUtTw==
X-Google-Smtp-Source: APXvYqwyT0HYBl1NyXTQ7T+x8i9qNmJ9HJ+V1jVX5PfgrCqFEKaP5aLKrllDpytoS9wCttrq9S2BgA==
X-Received: by 2002:ac8:4698:: with SMTP id g24mr3958975qto.137.1552676469336;
        Fri, 15 Mar 2019 12:01:09 -0700 (PDT)
Received: from cakuba.netronome.com ([66.60.152.14])
        by smtp.gmail.com with ESMTPSA id j34sm1677433qte.49.2019.03.15.12.01.08
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Mar 2019 12:01:09 -0700 (PDT)
Date:   Fri, 15 Mar 2019 12:01:05 -0700
From:   Jakub Kicinski <jakub.kicinski@netronome.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>
Cc:     linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: mount.nfs: Protocol error after upgrade to linux/master
Message-ID: <20190315120105.5541ad46@cakuba.netronome.com>
In-Reply-To: <20190315110555.0807d015@cakuba.netronome.com>
References: <20190315110555.0807d015@cakuba.netronome.com>
Organization: Netronome Systems, Ltd.
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 15 Mar 2019 11:05:55 -0700, Jakub Kicinski wrote:
> Hi,
> 
> I just upgraded from:
> 
> commit a3b1933d34d5bb26d7503752e3528315a9e28339 (net)
> Merge: c6873d18cb4a 24319258660a
> Author: David S. Miller <davem@davemloft.net>
> Date:   Mon Mar 11 16:22:49 2019 -0700
> 
> to
> 
> commit 3b319ee220a8795406852a897299dbdfc1b09911
> Merge: 9352ca585b2a b6e88119f1ed
> Author: Linus Torvalds <torvalds@linux-foundation.org>
> Date:   Thu Mar 14 10:48:14 2019 -0700
> 
> and I'm seeing:
> 
> # mount /home/
> mount.nfs: Protocol error
> 
> No errors in dmesg, please let me know if it's a known problem or what
> other info could be of use.

Hm.. I tried to bisect but reverting to that commit doesn't help.  

Looks like the server responds with:

  ICMP parameter problem - octet 22, length 80

pointing at some IP options (type 134)...
