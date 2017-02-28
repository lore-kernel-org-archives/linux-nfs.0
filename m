Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:46858 "EHLO
        mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750957AbdB1JPJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Feb 2017 04:15:09 -0500
Date: Tue, 28 Feb 2017 04:12:48 -0500 (EST)
From: Jan Stancek <jstancek@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bcodding@redhat.com, asavkov@redhat.com
Message-ID: <275589099.574523.1488273168507.JavaMail.zimbra@redhat.com>
In-Reply-To: <25524.1488241404@warthog.procyon.org.uk>
References: <343033867.485297.1488235638227.JavaMail.zimbra@redhat.com> <cover.1487802542.git.jstancek@redhat.com> <9557.1488233061@warthog.procyon.org.uk> <25524.1488241404@warthog.procyon.org.uk>
Subject: Re: [PATCH 0/2] key payload access with just rcu_read_lock()
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> Jan Stancek <jstancek@redhat.com> wrote:
> 
> > Looks like there are still couple users that need updating,
> > I'm hitting following compilation error:
> 
> Aargh - I remembered to grep for rcu_dereference_key() but not
> user_key_payload().
> 
> How about the attached?

v2 builds OK (on top of 4.10), "suspicious RCU usage"
warning is gone and NFS connectathon is PASS-ing cleanly.

Regards,
Jan
