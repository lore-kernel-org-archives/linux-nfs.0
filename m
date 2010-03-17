From: Eric Paris <eparis@parisplace.org>
Subject: Re: [PATCH 0/6][v4][RFC] NFSv3: implement extended attribute protocol
	(XATTR)
Date: Wed, 17 Mar 2010 16:13:06 -0400
Message-ID: <7e0fb38c1003171313i3bb81da3xda3a1d28f822d019@mail.gmail.com>
References: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org>
	 <alpine.LRH.2.00.1003082122340.6314@tundra.namei.org>
	 <20100309035932.GA14237@cynthia.pants.nu>
	 <4B95E167.40306@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Brad Boyer <flar-POGeQm5F+FGB+jHODAdFcQ@public.gmane.org>, James Morris <jmorris@namei.org>,
	linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, linux-fsdevel@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:60803 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754937Ab0CQUNR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Mar 2010 16:13:17 -0400
In-Reply-To: <4B95E167.40306@schaufler-ca.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 9, 2010 at 1:49 AM, Casey Schaufler <casey@schaufler-ca.com> wrote:

> Another is to NFS mount the filesystem back on to the server,
> in which case James' scheme works just dandy. It's a trick that
> I've used more than once in the Unix world for this exact purpose.
> Of course you have to arrange your mount points in advance with
> malice aforethought, but that's likely something you're used to
> by now.

Is this safe with NFS on Linux?  I know in the past (RHEL5) mounting
NFS over loopback can cause deadlocks under even slight memory
pressure.  I complained about it and was told 'don't do that, just
bind mount.'

-Eric
