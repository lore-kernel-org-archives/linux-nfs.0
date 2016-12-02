Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.46]:59081 "EHLO minas.ics.muni.cz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751866AbcLBLln (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Dec 2016 06:41:43 -0500
Date: Fri, 2 Dec 2016 12:41:34 +0100
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: RFC rpc.gssd enhancement
Message-ID: <20161202114134.rvzqptnsqo3odxay@ics.muni.cz>
References: <20161128183757.d5pz64tsigmaxdc7@ics.muni.cz>
 <645d0f56-f357-6c58-5e2f-e85bbae93db1@RedHat.com>
 <20161129184843.jrwbnytggrz6kdir@ics.muni.cz>
 <2ff5b760-a3ca-9ab8-d1a8-efe5f36aaaf3@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <2ff5b760-a3ca-9ab8-d1a8-efe5f36aaaf3@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 29, 2016 at 02:28:10PM -0500, Steve Dickson wrote:
> > maybe it is not considered secure, but it is still more secure to me than
> > using sec=sys. 
> True.

So, I was asking, if I provide such patch, will it be accepted into mainline
nfs-utils?

> > the problem is, that kerberized home is problem for .k5login file and also for
> > .ssh/authorized_keys. While the .k5login file is accessed with root context
> > (sshd), the authorized_keys is accessed with user context, so login via ssh
> > pubkey is not possible at all. 
> What would the .k5login look like and what would the principal look like?
> My apologies but I'm not very familar with how sshd interacts with 
> the .k5login. 

ok, I did more testing. It seems that kinit does not search ~/.k5login but
~/.krb5/config.

If NFS client gets permission denied, it is ok and kinit just creates a new
ticket.

However, if user has ticket that expired, NFS client returns EKEYEXPIRED
instead of EPERM. In such a case, kinit/kdestoy does not deal with this errno
and returns:
kinit: krb5_init_context failed: 127
or
kdestroy: krb5_init_context failed: 127

if you do rm /tmp/krb5cc_`id -u`_*, EKEYEXPIRED is changed to EPERM and
kinit/kdestroy works again.


Colleague of me says that EKEYEPIRED should not be returned by NFS client at
all, EPERM should be always returned and he sees this as a bug in kernel code.

-- 
Luká¹ Hejtmánek
