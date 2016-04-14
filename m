Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56864 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752490AbcDNS5y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Apr 2016 14:57:54 -0400
Date: Thu, 14 Apr 2016 14:57:51 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: gssd and linux containers
In-Reply-To: <CAN-5tyH-ATtHtWuw4t07DjZnnzOit=rQ=H0vq+W04gU=Ys=b+g@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1604141447230.55780@planck>
References: <CAN-5tyH-ATtHtWuw4t07DjZnnzOit=rQ=H0vq+W04gU=Ys=b+g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 14 Apr 2016, Olga Kornievskaia wrote:

> Hi folks,
>
> Does somebody know if it's possible to do secure mounts within linux
> containers? I seem to recall that gssd is not container-aware. Or is
> container-magic makes it so that gssd runs per container and has its
> own dedicated krb5.conf+keytab configurations?
>
> Thank you.

Hi Olga,

As far as I know there's no good way to run multiple gssd inside containers.
There's only one global upcall mechanism, so even if we could keep track of
which container is doing IO, there doesn't exist a way to upcall to the
appropriate gssd.  Additionally, containers are a collection of shared
namespaces.  A gssd could share one or more of those namespaces with a
process doing IO, so what sort of rules do we use to pick the right gssd?

Ian Kent has led some discussion on solving this, and right now the thinking
is to always upcall into whichever namespace collection created the mount,
but the bet way to preserve those namespaces has not been agreed upon yet.

Ben
