Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:53400 "EHLO
        mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750704AbdCANji (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Mar 2017 08:39:38 -0500
Date: Wed, 1 Mar 2017 04:45:23 -0500 (EST)
From: Jan Stancek <jstancek@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bcodding@redhat.com, asavkov@redhat.com
Message-ID: <502629911.1125748.1488361523729.JavaMail.zimbra@redhat.com>
In-Reply-To: <11141.1488361213@warthog.procyon.org.uk>
References: <122689774.757995.1488291640173.JavaMail.zimbra@redhat.com> <25524.1488241404@warthog.procyon.org.uk> <343033867.485297.1488235638227.JavaMail.zimbra@redhat.com> <cover.1487802542.git.jstancek@redhat.com> <9557.1488233061@warthog.procyon.org.uk> <20283.1488277729@warthog.procyon.org.uk> <11141.1488361213@warthog.procyon.org.uk>
Subject: Re: [PATCH 0/2] key payload access with just rcu_read_lock()
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>





----- Original Message -----
> From: "David Howells" <dhowells@redhat.com>
> To: "Jan Stancek" <jstancek@redhat.com>
> Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, bcodding@redhat.com,
> asavkov@redhat.com
> Sent: Wednesday, 1 March, 2017 10:40:13 AM
> Subject: Re: [PATCH 0/2] key payload access with just rcu_read_lock()
> 
> Jan Stancek <jstancek@redhat.com> wrote:
> 
> > That problem didn't show up with my NFS based reproducer.
> > I re-run it again with latest version of your patch, plus also
> > keyutils testsuite. Both completed OK for me, dmesg looks clean.
> 
> Can I put you down as a Tested-by?

Yes. Thanks for having a look at this.

Regards,
Jan
