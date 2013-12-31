Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47392 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753201Ab3LaMdH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Dec 2013 07:33:07 -0500
Date: Tue, 31 Dec 2013 07:33:00 -0500
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org, Simo Sorce <simo@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: should we change how the kernel detects whether gssproxy is
 running?
Message-ID: <20131231073300.0e0f220a@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm a bit concerned with how /proc/net/rpc/use-gss-proxy works...

For one thing, when the kernel first boots any read against that file
hangs. That's going to be extremely problematic for certain tools that
scrape info out of /proc for troubleshooting purposes (e.g. Red Hat's
sosreport tool).

Also, it seems like if gssproxy suddenly dies, then this switch stays
stuck in its position. There is no way switch back after enabling
gssproxy.

All of that seems unnecessarily complicated. Is there some rationale
for it that I'm missing?

Would it instead make more sense to instead just have gssproxy
hold a file open under /proc? If the file is being held open, then
send upcalls to gssproxy. If not then use the legacy code.

That way the upcalls would truly be conditional on whether gssproxy is
running...

-- 
Jeff Layton <jlayton@redhat.com>
