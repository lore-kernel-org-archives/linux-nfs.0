Return-Path: <SRS0=dvvl=UU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.3 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60380C43613
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Jun 2019 19:25:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2B3102084E
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Jun 2019 19:25:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YK7OX3NK"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726326AbfFUTZH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 21 Jun 2019 15:25:07 -0400
Received: from mail-io1-f67.google.com ([209.85.166.67]:40695 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726266AbfFUTZH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Jun 2019 15:25:07 -0400
Received: by mail-io1-f67.google.com with SMTP id n5so333604ioc.7
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jun 2019 12:25:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:message-id:subject:from:to:cc:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=E4wjllSRg8/0o3Ngklhd1sDQyRtWiiWzJj3lMu/HOj4=;
        b=YK7OX3NKXU0UdTJ2EeVKVDCzN/EbXdrU9X0yfB5nf6UjPCaTV6Oqqt6uf9z3wRHFyU
         TYQEoq7bHysUYYiQeGiIMVzNn6dOOEKJM7lFBJwnifa2JFb80Os0XRfgniMjHf5nYo1Z
         zPRxRLBR/5vhLOcJOhnjYM3I05x5CD9hAMqCQ7LrgWgd+OFBdjOIoQpEomm8sUpe6xzw
         WGs8jNqKF3VsQ6ab7bOBq1MECXIRQR1vKlAh6IGsTmOuplLmkP3EqiAfseoWZgOLBwV/
         v96luIhivxguDLnoB2sayq8ZRquHNh2AgbK1pHJ0MGNX42xBjxaUXzkLH6gFQlt6c2Zn
         K3Lg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:message-id:subject:from:to:cc:date
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=E4wjllSRg8/0o3Ngklhd1sDQyRtWiiWzJj3lMu/HOj4=;
        b=iuqknY2j4c1hD6bYWiwx2aVR0MyS+S+0PDdyrmDb7D9+9KDUxxNQ+1vY7e3oJlqqeQ
         ffcGEl8U6Yf4x4F379UczN2wBxJImtILeSTAjB5VF2TBQUmvPUC+o40ixSyHCKOPATAX
         LPVZm99DHTdkV5pNYrf7aSpA81YxRH+acjz1iVj7lS15I1TB6Lu45k+eRu0u9iOb6LrP
         Yhpgwxu0XpQsNypDZ2VWpidlu9hpI2WLHUrKyfcTZNMeJKjzdtrbC+x3vuN9ROPYqZus
         01Keex+wa4IdZjMGg3aPbpxf92tOoBOYzx8KshQdW7lcWVWsyRWvbQcPqjqv9Uh487p9
         yuxA==
X-Gm-Message-State: APjAAAXdSOFeQi8GjPr5I3moK4yn/j6ZyU6ZQ6bmvMRobN+jhStkzSGH
        tvxTkIvJCh4YKJkRjGoTGNmF5sEJ
X-Google-Smtp-Source: APXvYqyVMYeJd2WdRZy0CxMaENU6p6M0Hfupq3RNHR6hw6iZqxqV4OIxpr4KGai6ep/uLATjdfB2rw==
X-Received: by 2002:a6b:f00c:: with SMTP id w12mr25486266ioc.280.1561145106539;
        Fri, 21 Jun 2019 12:25:06 -0700 (PDT)
Received: from gouda.nowheycreamery.com (d28-23-121-75.dim.wideopenwest.com. [23.28.75.121])
        by smtp.googlemail.com with ESMTPSA id z1sm6387411ioh.52.2019.06.21.12.25.05
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 21 Jun 2019 12:25:05 -0700 (PDT)
Message-ID: <760712b7d0b965974f18efcc47e73561621f9c4c.camel@gmail.com>
Subject: Re: [PATCH 00/16] exposing knfsd client state to userspace
From:   Anna Schumaker <schumaker.anna@gmail.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Date:   Fri, 21 Jun 2019 15:25:04 -0400
In-Reply-To: <20190621181309.GD25590@fieldses.org>
References: <1561042275-12723-1-git-send-email-bfields@redhat.com>
         <20190621181309.GD25590@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.3 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2019-06-21 at 14:13 -0400, J. Bruce Fields wrote:
> On Thu, Jun 20, 2019 at 10:50:59AM -0400, J. Bruce Fields wrote:
> > 	- this duplicates some functionality of the little-used fault
> > 	  injection code; could we replace it entirely?
> 
> I'd be really curious to hear from any users of that code, by the
> way.
> Anna, any ideas?

I'm not sure who else has used it besides me, and it's been a while
since I have too.

> 
> The idea was that it could be used to test client handling of
> exceptional conditions like recalled delegations and partially lost
> state.  Is anyone regularly running such tests?
> 
> I don't hate the code, and I'm not on a crusade to tear it all out
> Right
> Now, but it does create a few odd corner cases, so I'm wondering
> whether
> I could get away with replacing it eventually or whether that risks
> breaking someone's scripts.

I'm cool with replacing it if there is a better way to do things.

Anna

> 
> --b.

