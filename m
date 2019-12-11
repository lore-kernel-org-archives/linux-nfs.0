Return-Path: <SRS0=Tnvp=2B=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07B89C2BD09
	for <linux-nfs@archiver.kernel.org>; Wed, 11 Dec 2019 07:48:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C1EFC20637
	for <linux-nfs@archiver.kernel.org>; Wed, 11 Dec 2019 07:48:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="U5PHuxbR"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726983AbfLKHst (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 11 Dec 2019 02:48:49 -0500
Received: from mail-pg1-f194.google.com ([209.85.215.194]:38701 "EHLO
        mail-pg1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726451AbfLKHst (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Dec 2019 02:48:49 -0500
Received: by mail-pg1-f194.google.com with SMTP id a33so10139392pgm.5;
        Tue, 10 Dec 2019 23:48:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=YZr4Epca+GuujTKa3m7m+IfakHaCFSR+D2ApesAFk1c=;
        b=U5PHuxbRnHlJa1WF+pikiQbtPbj5pJ7lgV5v4nMGLt0Of0pIDalan3kAwk19+T1syH
         ky7XJJOk+Ns+WGs/KvQjndmdhnllQqGZvOdbFFpuK9+lrlM600XMxEE//PHAyFKeOFuK
         gTTc1HWEJFGqb+sbOKFDpdleIh8Av+xZ7FGZM0vYgdH+XdpaxC0hZgjCMDec5Jd4AKcW
         n5pWSscHt5SMundXJo+6cJ/RBX00VU2TQzUAMQFW++Priw7PoIYrMPi1ncUz+UHqhHJp
         oQ/5HJ1HkVRr95REdP9ZoW9T3XjRHobEwYMahgS8+VXu5xLi0hBey97bhL9s1OLBZjRJ
         6BCA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=YZr4Epca+GuujTKa3m7m+IfakHaCFSR+D2ApesAFk1c=;
        b=e96ixj9jHi1jzfq7kzRudP/LVElwoub0Nv4SrZhjIQ48wiP/CWt4i1zh4eOLI4wzO2
         19hxn99FRif7Cs8wT/WllUSH903rdLoBpUmomzeCa/z7mgVKbBW2bs/nE3noI6UUolSQ
         xy6vMGibL0cxvmjJ+JQsLx9oSGhLbiDW3MR/wZz+HfQ/bad2pIcic6cN1u6mFtElWf9B
         82AMcpf6szImFJlbWNJuAwlIUVNkxKLLcO250N+0qrg+BQcMxg0rCZDf0evVgzPVnz5u
         wD+sefuDUzGB/2919qdvRFsnB+FZYc4fSkHeW9MwdUsOOLGufxbpDjzdf3vkD1IBuVna
         2kGA==
X-Gm-Message-State: APjAAAUgkLRKOXzWy/5Wua0aj/kgir/9yDikAPV+ID+lqPqL7nxj4RaG
        8JPanng/v/m8KrfFxmsL1zQ=
X-Google-Smtp-Source: APXvYqyZDQK3BrPblKtF9yFedeidgw6D3UCAXB1xQ+YRFW+Bk+WImrFuf0ioiY/CAhm3NHCwwlxpEQ==
X-Received: by 2002:a62:b60c:: with SMTP id j12mr2351212pff.8.1576050528554;
        Tue, 10 Dec 2019 23:48:48 -0800 (PST)
Received: from localhost.localdomain ([2402:3a80:cdb:7615:9ccb:7dcb:bf59:4b2f])
        by smtp.gmail.com with ESMTPSA id i4sm1608055pgc.51.2019.12.10.23.48.45
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 10 Dec 2019 23:48:47 -0800 (PST)
From:   madhuparnabhowmik04@gmail.com
To:     kbuild-all@lists.01.org, trond.myklebust@hammerspace.com,
        paulmck@kernel.org, anna.schumaker@netapp.com,
        joel@joelfernandes.org
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        rcu@vger.kernel.org, linux-kernel-mentees@lists.linuxfoundation.org
Subject: Re: [PATCH] fs: nfs: dir.c: Fix sparse error
Date:   Wed, 11 Dec 2019 13:18:42 +0530
Message-Id: <20191211074842.21400-1-madhuparnabhowmik04@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <201912110621.WJ6oENgf%lkp@intel.com>
References: <201912110621.WJ6oENgf%lkp@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This build error is because the macro list_tail_rcu() is
not yet present in the mainline kernel.

This patch is dependent on the patch : https://lore.kernel.org/linux-kernel-mentees/CAF65HP2SC89k9HJZfcLgeOMRPBKRyasCMiLo2gZgBKycjHuU6A@mail.gmail.com/T/#t


Thank you,
Madhuparna





