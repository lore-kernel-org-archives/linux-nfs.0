Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49584 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726832AbeIMOXP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Sep 2018 10:23:15 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <87lg854ws2.fsf@suse.com>
References: <87lg854ws2.fsf@suse.com> <17451.1536750676@warthog.procyon.org.uk>
To: =?us-ascii?Q?=3D=3Futf-8=3FQ=3FAur=3DC3=3DA9lien=3F=3D?= Aptel
        <aaptel@suse.com>
Cc: dhowells@redhat.com, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com, sfrench@samba.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-afs@lists.infradead.org, linux-fsdevel@vger.kernel.org
Subject: Re: Making the in-kernel DNS resolver handle server lists
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Date: Thu, 13 Sep 2018 10:14:37 +0100
Message-ID: <26010.1536830077@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Aurélien Aptel <aaptel@suse.com> wrote:

> > The payload handed to the kernel currently looks like something assembled
> > from the data obtained from a bunch of SRV records that have been further
> > looked up to A or AAAA.
> 
> I was wondering recently if the current kernel API lets you to access
> all A/AAAA records in case a same domain uses multiple ones. It seems
> not, is this correct?

It does permit this.  kAFS currently uses it.  Just don't pass "ipv4" or
"ipv6" in the callout info as those impose restrictions.

David
