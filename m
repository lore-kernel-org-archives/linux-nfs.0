Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34027 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932081AbcCGTt4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Mar 2016 14:49:56 -0500
Date: Mon, 7 Mar 2016 14:49:53 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Mark Valites <mvalites@buffalo.edu>
cc: linux-nfs@vger.kernel.org
Subject: Re: RH 7 nfs-utils update causes segfault
In-Reply-To: <56DDABE2.3040204@buffalo.edu>
Message-ID: <alpine.OSX.2.19.9992.1603071443060.66950@dhcp0201.cthon.org>
References: <56DDA2C2.3010806@buffalo.edu> <alpine.OSX.2.19.9992.1603071059490.66950@dhcp0201.cthon.org> <56DDABE2.3040204@buffalo.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 7 Mar 2016, Mark Valites wrote:

> On 03/07/2016 11:00 AM, Benjamin Coddington wrote:
>
> > Hey Mark, could it be this one?
> >
> > https://bugzilla.redhat.com/show_bug.cgi?id=1313090
> >
> > Ben
> >
>
> Doesn't look like it:
>
> $ sudo restorecon -v /etc/krb5.keytab
> <no output>
> $ ls -laZ /etc/krb5.keytab
> -rw-------. root root unconfined_u:object_r:krb5_keytab_t:s0 /etc/krb5.keytab
>
> I'd only had selinux in permissive mode, so I tried disabling it as well, but
> that too unfortunately made no difference.

That bug was only tickled in my case if the normal host principals were not
found in the keytab.  In that specific case, selinux prohibited access to
the keytab, causing the host keys to be unable to be looked up, and the bug
was hit.

Best bet would be to attache a debugger to rpc.gssd and get a stack trace of
it when it crashes.  That will give us something to work from.

You can do that with gdb -p <pid of gssd>.  Something like `gdb -p $(pidof
rpc.gssd)` will work -- then type "continue" to let the process continue to
run.  When it fails you can enter "bt" to emit a back trace.  That
information would be very helpful.

Ben
