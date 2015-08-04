Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:33130 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753813AbbHDR0U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 13:26:20 -0400
Received: by wijp15 with SMTP id p15so15482739wij.0
        for <linux-nfs@vger.kernel.org>; Tue, 04 Aug 2015 10:26:19 -0700 (PDT)
Subject: Re: [PATCH V6 6/9] isert: Rename IO functions to more descriptive
 names
To: Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
 <20150724161848.25617.26092.stgit@build2.ogc.int>
 <55B4B190.7070305@dev.mellanox.co.il>
 <55B5404F.5040404@opengridcomputing.com>
 <000001d0ce23$27048810$750d9830$@opengridcomputing.com>
Cc: infinipath@intel.com, sagig@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55C0F5B7.4040100@dev.mellanox.co.il>
Date: Tue, 4 Aug 2015 20:26:15 +0300
MIME-Version: 1.0
In-Reply-To: <000001d0ce23$27048810$750d9830$@opengridcomputing.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Hey Sagi, how is this coming along?  How can I help?
>

Hi Steve,

This is taking longer than I expected, the changes needed seem
pretty extensive throughout the IO path. I don't think it will be ready
for 4.3

I'll try to send you soon a preliminary version to play with.
Acceptable?


