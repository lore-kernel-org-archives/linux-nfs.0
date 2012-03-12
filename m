Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:48265 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756897Ab2CLVKh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 17:10:37 -0400
Received: by yhmm54 with SMTP id m54so3043587yhm.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Mar 2012 14:10:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120312200221.GS29573@science-computing.de>
References: <20120312200221.GS29573@science-computing.de>
Date: Mon, 12 Mar 2012 17:10:36 -0400
Message-ID: <CAKnQG+dq4C+dw5W2Jgcgg7xk-Kj_-hxLnCbeR8879tZ7DMt3jA@mail.gmail.com>
Subject: Re: NFSv4 post-1.2.2 nfs-utils client fails to mount from pre-1.2.3
 nfs-utils server
From: Kevin Coffman <kwc@umich.edu>
To: Michael Weiser <M.Weiser@science-computing.de>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 12, 2012 at 4:02 PM, Michael Weiser
<M.Weiser@science-computing.de> wrote:
> Hi,
>
> from what I can gather, nfs-utils-1.2.3 introduced support for
> encryption other than Single DES for NFSv4: Previously, gssd would
> proactively limit Kerberos encryption types of session keys to
> des-cbc-crc (and perhaps -md5 and -md4). So while the actual ticket
> might be encrypted using something way stronger, the included session
> key would only be Single DES.
>
> Due to this self-limitation of the client, the server would never get
> anything else than Single DES session keys and therefore needed no
> mechanism of working around the problems caused by stronger session keys
> with a kernel that does not support them.
>
> Beginning with version 1.2.3 of nfs-utils, gssd does no longer limits
> itself to Single DES. Instead, it detects the encryption types supported
> by the *client's* kernel and limits the session key's encryption type to
> those reported as supported. This, however, ignores the fact, that the
> *server's* kernel might not support them. Since the userspace of the
> server (svcgssd) does not check what its kernel supports and has no
> mechanism of renegotiating with the client, it happily accepts stronger
> encryption types and tries to push them into the kernel.
>
> nfs-utils-1.2.4 includes a patch to svcgssd that uses
> /proc/fs/nfsd/supported_encryption_types of newer kernels (2.6.35+ ?) to
> determine the encryption types supported by the server's kernel and uses
> subkey negotiation of current MIT Kerberos versions (1.9.1+) to
> negotiate a possibly weaker encryption type with the client. While this
> is a good solution for future enhancements and backwards compatibility
> from now on it still leaves all the older installations with a problem.
> RHEL5 for example only has MIT Kerberos 1.6 and will therefore most
> likely never benefit from this fix.
>
> A direct workaround is to set the following options in /etc/krb5.conf of
> client and server:
>
> [libdefaults]
> default_tkt_enctypes = des-cbc-md5
> permitted_enctypes = des-cbc-md5
>
> , add des-cbc-md5 keys to the keytabs of both machines and allow Single
> DES for both machines' principals on the KDC (MS AD 2008r2 in particular
> wants it enabled explicitly). This however not only limits the
> encryption types of session keys but all tickets as well and applies to
> the whole machine not just the NFSv4 service. This has a needlessly high
> security impact on both machines.
>
> I quickly implemented a more self-contained fix that adds an option -l
> to rpc.gssd that effectively reverts it to legacy behaviour: It ignores
> its local kernel's capabilities and uses just Single DES. This option
> could be set in e.g. /etc/sysconfig/nfs:GSSDARGS on all RHEL6 clients
> that need to work with RHEL5 servers. It could possibly be enhanced to
> be configurable on a per-machine basis. Inclusion of this or a similar
> patch would be greatly appreciated.
>
> Obviously this is just a proof-of-concept and still needs some
> polishing. I was just wondering if my reasoning is sound and the
> solution acceptable.
>
> Thanks in advance,

To summarize, the base issue was not with gssd/svcgssd.  It was a
change in the Kerberos library code (if I recall correctly, in 1.7 or
1.8??) which ignores the limited enctypes in the server's keytab, and
instead uses the Kerberos library's capabilities to assert a subkey.

A proper fix needs to be on the server.  (Remember that non-Linux
clients may be trying to use that RHEL5 server, and have no such
mechanism to limit the requested enctypes.)

AFAIK, the only way to properly "fix" the issue is at the server by
adding "permitted_enctypes = des-cbc-md5" in krb5.conf.  This does
have the downside of limiting all services to DES, as you've stated.

I don't know if patches for Kerberos and nfs-utils could be pulled up
to RHEL5.  IMHO, that would be the ideal solution.

K.C.
