Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:36343 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1761338AbdEWPfx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 May 2017 11:35:53 -0400
Message-Id: <1495553752.2751759.986007384.4E1A6A8B@webmail.messagingengine.com>
From: Colin Walters <walters@verbum.org>
To: Jeff Layton <jlayton@redhat.com>,
        Djalal Harouni <tixxdz@gmail.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Cc: David Howells <dhowells@redhat.com>, trondmy@primarydata.com,
        Miklos Szeredi <mszeredi@redhat.com>,
        linux-nfs@vger.kernel.org,
        "linux-kernel" <linux-kernel@vger.kernel.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
 <87lgpoww67.fsf@xmission.com> <1495491733.25946.3.camel@redhat.com>
 <874lwbraxh.fsf@xmission.com>
 <CAEiveUcbmm5m4=11ZppxAWppeoFWUBFpLC7dAZRuBCTFHR548g@mail.gmail.com>
 <1495551292.2742620.985957224.3FCF254A@webmail.messagingengine.com>
 <1495553491.2946.16.camel@redhat.com>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
In-Reply-To: <1495553491.2946.16.camel@redhat.com>
Date: Tue, 23 May 2017 11:35:52 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 23, 2017, at 11:31 AM, Jeff Layton wrote:
> 
> nfsdcltrack was originally nfsdcld, a long running daemon that used
> rpc_pipefs to talk to the kernel. That meant that you had to make sure
> it gets enabled by systemd (or sysvinit, etc). If it dies, then you also
> want to ensure that it gets restarted lest the kernel server hang,
> etc...
> 
> It was pretty universally hated, as it was just one more daemon that you
> needed to run to work a proper nfs server. So, I was encouraged to
> switch it to a call_usermodehelper upcall and since then it has just
> worked, as long as the binary is installed.

Note that with the "read()/write() fd" model you don't need
a whole process just to do that...the functionality could be rolled into systemd
or equivalent easily enough.

> "You're doing it wrong. You just need to run all of these services as
> long-running daemons."

Also, I imagine we could figure out a clean model to do *activation*
from kernel -> userspace too.  systemd's socket activation model
where pid 1 activates units on demand is quite nice and obviates
the need to configure things on in advance.
