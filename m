Return-Path: <SRS0=HFWl=6K=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6762BC55191
	for <linux-nfs@archiver.kernel.org>; Sun, 26 Apr 2020 11:05:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 369E92075B
	for <linux-nfs@archiver.kernel.org>; Sun, 26 Apr 2020 11:05:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LGv8SG6b"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726118AbgDZLFo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 26 Apr 2020 07:05:44 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33728 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1725965AbgDZLFo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Apr 2020 07:05:44 -0400
Received: from mail-lj1-x231.google.com (mail-lj1-x231.google.com [IPv6:2a00:1450:4864:20::231])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 4669AC061A0C
        for <linux-nfs@vger.kernel.org>; Sun, 26 Apr 2020 04:05:42 -0700 (PDT)
Received: by mail-lj1-x231.google.com with SMTP id b2so14469951ljp.4
        for <linux-nfs@vger.kernel.org>; Sun, 26 Apr 2020 04:05:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=kjNkLRYBDl040BJkWotTIwMlvE4L3BzU0RUdVNNo4Fo=;
        b=LGv8SG6bTlZNh05F3W3S/P02Tfuoi8x59STVZCcnNtz1eWuSI5BOXkFLPEOr44EELg
         pYw8+FiA//B8lWEP4GtDra4FvD7UWKOeq8Yr0YYDpuh3lYLqhUDOdJZYh4nYVlztp2o8
         a7qvil9brXJMJuQfupnRl964B65V8uVL0gVT/WtvOyVvimR/c5GfP5t1iZ8Ffsr+/ia+
         JPo9UH++VGmveyA5nZPRHIcpjpxio2urHRexJtf2GtlACTINRx0GzkLsF4s1x+KRZC/j
         j7dmZRksnynBtecanD1lpKp4gNH9FBvO05ISEQIIpmh8SCZuN2/Pw08oGuWg1VqGAJ/5
         XSmg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=kjNkLRYBDl040BJkWotTIwMlvE4L3BzU0RUdVNNo4Fo=;
        b=hexWAOe2CfyWyIal9OBFP+A20oIFJyslpK0O+WfeM3KMOsyy5Qq/unM+gSIygCXmQq
         09sCDZcQ/NM18QKV64Jzo7ZgBAieSpGA+Jhv4J1ZbtB2f8ZRkeRSRmJZeO8uXDAy4DW+
         PuHJuF70mGkoK7OeGkfN2rGAQOF8WvfIc3YaDuICaUCKOiTOpQc33v/zSdgMrTIKr1Ar
         hiCo2xBzkIaNqJ30f33oM4p58TsZ20CQDQ6+YGPKiL+SZ8aoeebB9XfOfir5+D+hE7G0
         VemFhRuIoatubGnXXNLjzXdsA5adstN4HlnKc0HrW0DYspEKjSkXd0BmfDFfv00V4ta3
         7QJQ==
X-Gm-Message-State: AGi0Puba5Z0j1Gi7/22Wv+c8JERZNhjzGvbMbIjhRHR8UWGNt+8IHtjG
        dIBiuD5B9X7O6JVsayPqojVYuVUSmFoAvf4K9YOr9rGv
X-Google-Smtp-Source: APiQypIo7Sp/s5MHVjftoWZhLHVNLlJDHjypDiENh2wUf11TzSn7RvX3F5EgSpza7uljjcaVizJRr2lTTeflxldku0Q=
X-Received: by 2002:a2e:a311:: with SMTP id l17mr11238084lje.106.1587899140254;
 Sun, 26 Apr 2020 04:05:40 -0700 (PDT)
MIME-Version: 1.0
From:   Nathael Pajani <nathael@gmail.com>
Date:   Sun, 26 Apr 2020 13:09:04 +0200
Message-ID: <CAOOz39+q76Ak4i5d5xTKdbty+JBi+qfo+W32WZaMj-LyLTDR-w@mail.gmail.com>
Subject: Typo in NFS "exports(5)" man page
To:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi !

There's a typo in the man page of exports(5) : two consecutive verbs
in pnfs option description:

"This  option  allows  enables the use of pNFS extension"

I think "allows" should be removed.

Thanks !
+++

-----
Nathael Pajani - ED3L - Techno-Innov
Internet : http://www.ed3l.fr - http://www.techno-innov.fr
