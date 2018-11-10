Return-Path: <SRS0=tn5C=NV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7F28C43441
	for <linux-nfs@archiver.kernel.org>; Sat, 10 Nov 2018 03:48:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6CDAD2081C
	for <linux-nfs@archiver.kernel.org>; Sat, 10 Nov 2018 03:48:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ATmxAgTi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CDAD2081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728548AbeKJNc0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 10 Nov 2018 08:32:26 -0500
Received: from mail-wr1-f48.google.com ([209.85.221.48]:38404 "EHLO
        mail-wr1-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728094AbeKJNc0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 10 Nov 2018 08:32:26 -0500
Received: by mail-wr1-f48.google.com with SMTP id e3-v6so3840332wrs.5
        for <linux-nfs@vger.kernel.org>; Fri, 09 Nov 2018 19:48:53 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=MooZsKOBGcySj7cyKX2fnPOKCJUKLC87zhXA3zSWacg=;
        b=ATmxAgTiJOukB2j3WVIjpjhNN5Dan9OW/Zallr98n44/vNzWNypiE6CMGFol6ZWm5A
         65CcgE7DnXGe1BE4955b8y7KXTpD9YszU931NaaeERQa53AWpQM1hW4/YlUWp12o2cDG
         XsPgxWxMzFpkOvLmtsj0McH584zNvZGAdTnrFNMLMAwAy+SKrrrE8H/GDGMGoNHWftb3
         ZADW7V/r7id0Pwe50AsTGv0gG+vIRd+UskwyKV2WQQ4QwHZi+Vsnvz2LeEt0eHQ2m+ji
         GcVZUo9nMQNN0IYIC4uVkCML8VUBzz4spI56G9g9GwAUF3pDyaQhF04UCWTL75YIRxiA
         VT+Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=MooZsKOBGcySj7cyKX2fnPOKCJUKLC87zhXA3zSWacg=;
        b=AW2i4WQRAYQXP36/tD/SHcSusDQ/iHDMJDoil/fZBsIPRUiTrgf9zeIFVTBf7zXyWh
         KE8XiG+tJKbSScG+O/DOwagpEX2ZQ1JhjC9vHeH4qsehoqb5pmvqdDDv19umGedDMisD
         epSbktxn3nG0mcdWcUmCdqkhHU9NkW46kfcmqwpZPNwt7CyhDyfnDyDgSwLluaDqRmYV
         RQmn7+rMmoyyOwNiiiOXJ8E1GDUd127WyeqSEgt6qnbJ1CEjZqyUCRo6VTu8jQeRVgEN
         kt7awiSmz2PMF+Xq8we9dUQ5F3QScgRFYw5h3iyX1zABS0dlnWfzcOBv2rBawxQ0Zof4
         d/uA==
X-Gm-Message-State: AGRZ1gKxu57Zr4rVVNLmtoSX5aAma9uLJuE+NMtoZqjB3fo+Nr/xpAPz
        ppeFMHChVFTFb9bXpYAqyi4mxPGgBCzMPEttDU5BIQ==
X-Google-Smtp-Source: AJdET5esy2m2ZWXTvMWu8AgQFnMoqQoqrLaeErZs5svSWyg7UWoEZmjSzEZDNGXt8BukDjfSCcU+74o/i3eHnhEOYF0=
X-Received: by 2002:adf:bc8f:: with SMTP id g15-v6mr10734392wrh.250.1541821732559;
 Fri, 09 Nov 2018 19:48:52 -0800 (PST)
MIME-Version: 1.0
From:   Naruto Nguyen <narutonguyen2018@gmail.com>
Date:   Sat, 10 Nov 2018 10:48:41 +0700
Message-ID: <CANpxKHEmtZkfcFVhxyrF0PZ2TwTNHCGgYN4qNZu2dn=GasbOVg@mail.gmail.com>
Subject: mount client port allocated in privilege port range
To:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi everyone,

When running mount command with tcp under root account, I see that the
tcp client port is allocated in privilege range like 830... I do not
think it's a good behavior as port in privilege range is limited and a
lot of well known service is using it. Could you please let me know
any reason for that? It's better for mount nfs client port to be
allocated in dynamic port range instead even the system is running
under root permission? and any other way to make it happens besides
running under a normal user?

Thanks,
Brs,
Naruto
