Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:14980 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764046AbZD3Owc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 10:52:32 -0400
Received: by qw-out-2122.google.com with SMTP id 5so1571553qwd.37
        for <linux-nfs@vger.kernel.org>; Thu, 30 Apr 2009 07:52:31 -0700 (PDT)
In-Reply-To: <20090429214300.25811.81332.stgit@jazz.citi.umich.edu>
References: <20090429214300.25811.81332.stgit@jazz.citi.umich.edu>
Date: Thu, 30 Apr 2009 10:52:31 -0400
Message-ID: <4d569c330904300752o5c122b99q905e3bc65ee5a684@mail.gmail.com>
Subject: Re: [PATCH 0/7] nfs-utils: add support for authenticated callbacks
From: Kevin Coffman <kwc@citi.umich.edu>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Apr 29, 2009 at 5:56 PM, Kevin Coffman <kwc@citi.umich.edu> wrote:
> This series adds support to gssd and svcgssd to support
> authenticated callbacks.
>
> [...]
>
> NOTE:  For authenticated callbacks to work, an NFS client or an
> NFS server must be running both rpcgssd _and_ rpcsvcgssd.
> This will require a configuration change.

Also note that when running svcgssd on an NFS cllient which does not
have an "nfs" key in its keytab, it must be run with the "-n" flag or
it will fail to start.
