Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47752 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751499AbdCAJrr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Mar 2017 04:47:47 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <122689774.757995.1488291640173.JavaMail.zimbra@redhat.com>
References: <122689774.757995.1488291640173.JavaMail.zimbra@redhat.com> <25524.1488241404@warthog.procyon.org.uk> <343033867.485297.1488235638227.JavaMail.zimbra@redhat.com> <cover.1487802542.git.jstancek@redhat.com> <9557.1488233061@warthog.procyon.org.uk> <20283.1488277729@warthog.procyon.org.uk>
To: Jan Stancek <jstancek@redhat.com>
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, bcodding@redhat.com, asavkov@redhat.com
Subject: Re: [PATCH 0/2] key payload access with just rcu_read_lock()
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 01 Mar 2017 09:40:13 +0000
Message-ID: <11141.1488361213@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jan Stancek <jstancek@redhat.com> wrote:

> That problem didn't show up with my NFS based reproducer.
> I re-run it again with latest version of your patch, plus also
> keyutils testsuite. Both completed OK for me, dmesg looks clean.

Can I put you down as a Tested-by?

David
