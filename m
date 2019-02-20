Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEDF3C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 07:01:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 907832087B
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 07:01:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=paul-moore-com.20150623.gappssmtp.com header.i=@paul-moore-com.20150623.gappssmtp.com header.b="G+5tK/0M"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726121AbfBTHBI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 02:01:08 -0500
Received: from mail-lj1-f194.google.com ([209.85.208.194]:39791 "EHLO
        mail-lj1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726082AbfBTHBI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Feb 2019 02:01:08 -0500
Received: by mail-lj1-f194.google.com with SMTP id g80so19833787ljg.6
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 23:01:06 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=paul-moore-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7n3R0LFJo2U7VhZo2UnoL8uJHngbkUminPwgfsqPKDo=;
        b=G+5tK/0MzLY46/Py/4V9aGTSfZ+YQfTTLAMVS4TC58uZMxoDqJ6QjISPNm9vxxZsnE
         oGDkmh5cV4YOHygpL350Z22maHptXHAuVWxg3YDMYHi3VB+Cyi41H+tCOmVzN8ZhlCB/
         GW+ju7jTGNaLIe3Aj9RiScx6wWGlsDE+G5V1TvgNM83JanhEBeylL9/5ctDtkuEh4uv2
         MuzFf9oC64CZRU36vt+T7ZZVpIJWGRa/UzbUf6MD8ofxYrPasIukccjLma8Pu0mIgQ8W
         IQgsPeFsRudZL/QzUH5+Atpjdd42xzBgHPLpigQGy0t+t6SGVG92UZ0uH1l3Ats9VEyU
         7tUA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=7n3R0LFJo2U7VhZo2UnoL8uJHngbkUminPwgfsqPKDo=;
        b=iSgTjrxQ5YsBE2P9qZdMzJVYrnz3kFztB3CVwY1O78LTv+H2qp5PhlkugmTvtfuJBr
         iUzON8juc7pgkKuSWvL5mzNqlk6RXM6tvLcVm4cxAmW5Ai410x6TnSAX7JK6J31zMyt3
         h9/9lu0hKpujUpbx5UET69giOHUJHX3Mh4jkvM5EeQHzGM/e7UVxXp6DfIeLATgF0s+g
         1/1lzpwgN1+k805Fj933NNEWfK/2EJwlLCxz8AsMp/ejHXjds2Tb+7kBuhKil1Td4ACa
         BJuIcKClx1z7EOaBGR8HlDlMOyjn5KczWHNcyUyfU/BLUn+wxhv++iIHZfKZoz+bRwj+
         ONzw==
X-Gm-Message-State: AHQUAubNkn65ybE3mOkopxj+mo7OY6Arz8pZ70tmcE4waz/GjM41Qgl/
        quyLqi/2+U/07se0P0oVp8mCH6PvE2gs0NhNTpE7
X-Google-Smtp-Source: AHgI3IaHO0iAVCrCLitFJ+Mt0v4Frblbu3fm1miPdhBeFL4cgYgEd2Ytz37yGjWDdBAEdE6kQNdX5UmRujc3Rh8Ce1A=
X-Received: by 2002:a2e:9d17:: with SMTP id t23-v6mr19395612lji.57.1550646065640;
 Tue, 19 Feb 2019 23:01:05 -0800 (PST)
MIME-Version: 1.0
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
 <8736ojybw7.fsf@xmission.com> <22055.1550619729@warthog.procyon.org.uk>
In-Reply-To: <22055.1550619729@warthog.procyon.org.uk>
From:   Paul Moore <paul@paul-moore.com>
Date:   Wed, 20 Feb 2019 02:00:54 -0500
Message-ID: <CAHC9VhTaZ4Gnx_NvoTBTtcrQZppL1_mKM03miOCE2KUBR8z5Sg@mail.gmail.com>
Subject: Re: [RFC PATCH 00/27] Containers and using authenticated filesystems
To:     David Howells <dhowells@redhat.com>
Cc:     "Eric W. Biederman" <ebiederm@xmission.com>,
        keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org, linux-security-module@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, rgb@redhat.com,
        linux-kernel@vger.kernel.org,
        Linux Containers <containers@lists.linux-foundation.org>,
        linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Feb 19, 2019 at 6:42 PM David Howells <dhowells@redhat.com> wrote:
> Eric W. Biederman <ebiederm@xmission.com> wrote:

...

> > Looking at your description you are introducing a container id.
>
> Yes.  For audit logging, which was why I cc'd Richard.

Not to pile on, but it is more important to CC the audit mailing list.
You can obviously still CC Richard, but you should send it to the
entire mailing list.

-- 
paul moore
www.paul-moore.com
