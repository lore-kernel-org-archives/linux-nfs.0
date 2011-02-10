Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay03.bluemeaney.com ([205.234.16.187]:56107 "EHLO
	relay03.bluemeaney.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755928Ab1BJMMF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Feb 2011 07:12:05 -0500
Subject: [PATCH 0/2] nfsv4: Fix two remote DOS vulnerabilities  v2
From: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        David Howells <dhowells@redhat.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 10 Feb 2011 14:54:54 +0300
Message-ID: <1297338894.3667.0.camel@vT510>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello!

Next patches fix two NFSv4 client vulnerabilities.

First (memory corruption) can be raises anytime whereas second
(dereference ->lookup and call NULL pointer) can be raised during mount.

Repeatability 100%

-- 
Thanks,
Vitaliy Gusev

