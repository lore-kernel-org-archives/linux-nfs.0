Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:55524
        "EHLO osg.samsung.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754523AbcKEM7c (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Nov 2016 08:59:32 -0400
Message-ID: <581DD7B0.8080906@osg.samsung.com>
Date: Sat, 05 Nov 2016 12:59:28 +0000
From: Luis de Bethencourt <luisbg@osg.samsung.com>
MIME-Version: 1.0
To: linux-fsdevel@vger.kernel.org
CC: Richard Weinberger <richard@nod.at>, linux-nfs@vger.kernel.org
Subject: When is export_operations.get_parent triggered?
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I recently played with adding the basics to make befs exportable via NFS [0].

I want to implement the get_parent member of the export_operations struct as
well, but I can't seem to trigger this member being called. I have implemented
a solution which I feel is wrong [1], but want to be able to test it before
moving forward.

When is this member triggered? Any advice?

Thanks,
Luis


[0] https://lkml.org/lkml/2016/11/5/40
[1] https://github.com/luisbg/linux-befs/commit/a7d92c746469f1bd60dd1c905587915ecf9884f5
