From: Dax Kelson <Dax.Kelson@gurulabs.com>
Subject: Re: [PATCH] Secure user authentication for NFS using RPCSEC_GSS
	[0/6]
Date: 12 Jan 2003 22:56:31 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1042437391.1677.8.camel@thud>
References: <15906.1154.649765.791797@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linus Torvalds <torvalds@transmeta.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	NFS maillist <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: trond.myklebust@fys.uio.no
In-Reply-To: <15906.1154.649765.791797@charged.uio.no>
List-ID: <nfs.lists.sourceforge.net>

On Sun, 2003-01-12 at 17:12, Trond Myklebust wrote:
> Hi Linus,
> 
>  The following set of 6 patches implements support for the RPCSEC_GSS
> security protocol (authentication only) and the Kerberos V5 security
> mechanism.

As a user and sysadmin, I've been waiting for this for a LONG time.
Standard NFS security/authentication sucks rocks. Without this NFS home
directory servers are just waiting to be ransacked by a rouge (or
compromised) root user on a client machine.

NFSv4 w/RPSEC_GSS is finally a native UNIX filesharing solution that I
don't have to be ashamed of when hanging with admins of those "other
OSes".

Dax
