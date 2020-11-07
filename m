Return-Path: <SRS0=Dbg8=EN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B059C4741F
	for <linux-nfs@archiver.kernel.org>; Sat,  7 Nov 2020 01:33:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5932120728
	for <linux-nfs@archiver.kernel.org>; Sat,  7 Nov 2020 01:33:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727394AbgKGBdT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 6 Nov 2020 20:33:19 -0500
Received: from namei.org ([65.99.196.166]:38844 "EHLO namei.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726447AbgKGBdS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 6 Nov 2020 20:33:18 -0500
Received: from localhost (localhost [127.0.0.1])
        by namei.org (8.14.4/8.14.4) with ESMTP id 0A71XBcT014094;
        Sat, 7 Nov 2020 01:33:11 GMT
Date:   Sat, 7 Nov 2020 12:33:11 +1100 (AEDT)
From:   James Morris <jmorris@namei.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        paul@paul-moore.com, stephen.smalley.work@gmail.com,
        linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
        selinux@vger.kernel.org
Subject: Re: [PATCH 1/2] [lsm] introduce a new hook to query LSM for
 functionality
In-Reply-To: <20201105173328.2539-1-olga.kornievskaia@gmail.com>
Message-ID: <alpine.LRH.2.21.2011071231160.13444@namei.org>
References: <20201105173328.2539-1-olga.kornievskaia@gmail.com>
User-Agent: Alpine 2.21 (LRH 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 5 Nov 2020, Olga Kornievskaia wrote:

> From: Olga Kornievskaia <kolga@netapp.com>
> 
> Add a new hook func_query_vfs to query an LSM module (such as
> SELinux) with the intention of finding whether or not it is enabled
> or perhaps supports some functionality.
> 
> NFS stores security labels for file system objects and SElinux
> or any other LSM module can query those objects. But it's
> wasteful to do so when no security enforcement is taking place.
> Using a new API call of security_func_query_vfs() and asking if

Seems we lost something here.



-- 
James Morris
<jmorris@namei.org>

