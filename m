Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:36019 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828Ab2FKOFx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jun 2012 10:05:53 -0400
Message-ID: <4FD5FB28.4050003@panasas.com>
Date: Mon, 11 Jun 2012 17:05:28 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: bfields <bfields@fieldses.org>, Steve Dickson <steved@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Joerg Platte <jplatte@naasa.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Hans de Bruin <jmdebruin@xmsnet.nl>
Subject: Re: Kernel 3.4.X NFS server regression
References: <4FD47D4E.9070307@naasa.net> <1339340441.4751.1.camel@lade.trondhjem.org> <20120611121634.GB7654@fieldses.org> <20120611083932.24e27e39@corrin.poochiereds.net> <4FD5F35A.3000903@panasas.com> <20120611095132.045a8d09@corrin.poochiereds.net>
In-Reply-To: <20120611095132.045a8d09@corrin.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/11/2012 04:51 PM, Jeff Layton wrote:

> 
> That was considered here, but the problem with the usermode helper is
> that you can't pass anything back to the kernel but a simple status
> code (and that's assuming that you wait for it to exit). In the near
> future, we'll need to pass back more info to the kernel for this, so
> the usermode helper callout wasn't suitable.
> 


I have answered that in my mail. Repeated here again. Well you made 
a simple mistake. Because it is *easy* to pass back any number and
size of information from user-mode.

You just setup a sysfs entry points where the answers are written
back to. It's an easy trick to setup a thread safe, way with a
cookie but 90% of the time you don't have to. Say you set up
a structure of per-client (identified uniquely) then user mode
answers back per client, concurrency will not do any harm, since
you answer to the same question the same answer. ans so on. Each
problem it's own.

If you want we can talk about this, it would be easy for me to setup
a toll free conference number we can all use.

Cheers
Boaz
