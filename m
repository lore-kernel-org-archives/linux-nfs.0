Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx5-phx2.redhat.com ([209.132.183.37]:41789 "EHLO
        mx5-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751452AbdB1OUk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Feb 2017 09:20:40 -0500
Date: Tue, 28 Feb 2017 09:20:40 -0500 (EST)
From: Jan Stancek <jstancek@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bcodding@redhat.com, asavkov@redhat.com
Message-ID: <122689774.757995.1488291640173.JavaMail.zimbra@redhat.com>
In-Reply-To: <20283.1488277729@warthog.procyon.org.uk>
References: <25524.1488241404@warthog.procyon.org.uk> <343033867.485297.1488235638227.JavaMail.zimbra@redhat.com> <cover.1487802542.git.jstancek@redhat.com> <9557.1488233061@warthog.procyon.org.uk> <20283.1488277729@warthog.procyon.org.uk>
Subject: Re: [PATCH 0/2] key payload access with just rcu_read_lock()
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


----- Original Message -----
> Here's an updated patch with fixed user_key_payload_locked() and user_read().
> 

That problem didn't show up with my NFS based reproducer.
I re-run it again with latest version of your patch, plus also
keyutils testsuite. Both completed OK for me, dmesg looks clean.

Regards,
Jan
