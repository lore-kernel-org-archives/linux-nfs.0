Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:43068 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751247AbdKVNav (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Nov 2017 08:30:51 -0500
Received: by mail-wr0-f170.google.com with SMTP id u40so14524814wrf.10
        for <linux-nfs@vger.kernel.org>; Wed, 22 Nov 2017 05:30:51 -0800 (PST)
Received: from [192.168.10.7] ([195.142.102.158])
        by smtp.gmail.com with ESMTPSA id m23sm2202368wmc.29.2017.11.22.05.30.49
        for <linux-nfs@vger.kernel.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 05:30:49 -0800 (PST)
From: =?utf-8?Q?=C3=96zkan_G=C3=B6ksu?= <ozkan.goksu@usishi.com>
Content-Type: text/plain; charset=us-ascii
Subject: How to get NFS user list
Message-Id: <296856FF-A18F-47EB-96AF-5C0E6C9BB5E1@usishi.com>
Date: Wed, 22 Nov 2017 16:31:43 +0200
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I want to get NFS user list (client list) like "smbstatus"
I want to see which user & ip is using which share and when connected.
I want to kill a nfs user.
I want to log what an user is doing like "Create, modify, delete".

In the end; I want to manage nfs users. There is not enough information =
and tools about this problem.

How you manage your nfs server?

Best Regards.=
