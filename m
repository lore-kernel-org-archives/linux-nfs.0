Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:20983 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752923Ab0IONEt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Sep 2010 09:04:49 -0400
Message-ID: <4C90BADB.10700@parallels.com>
Date: Wed, 15 Sep 2010 16:23:55 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 0/9] sunrpc: Start making sunrpc work in containers
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello everyone!

I would like to prepare the sunrpc layer for working in a containerized
environments. The ultimate goal is to make both nfs client and server
work in containers. Hopefully you won't object :)

Not to look like an idle talker I've prepared this set which makes the
/proc/net/rpc appear in net namespaces and made the ip_map_cache be per-net.

I do not have any plans about when this patches appear at Linus tree and
thus do not know which git tree to hack on. That said I prepared the patches
against the net-next tree (I have some custom netns debugging code in it
and don't want to port it around in vain).

Looking forward to your feedback.

Thanks,
Pavel
