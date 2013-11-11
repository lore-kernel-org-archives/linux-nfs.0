Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:11218 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754197Ab3KKTLg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Nov 2013 14:11:36 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: "NFS: v4 server 127.0.0.1 does not accept raw uid/gids.
 Reenabling the idmapper."
Date: Mon, 11 Nov 2013 19:11:34 +0000
Message-ID: <C75D4AA2-1EC2-4623-B19A-7F7C7F19C24D@netapp.com>
References: <20131111184033.GA7760@infradead.org>
In-Reply-To: <20131111184033.GA7760@infradead.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 11, 2013, at 13:40, Christoph Hellwig <hch@infradead.org> wrote:

> I regularly get the above message when running xfstest generic/013
> against a local server.  The comment in the code mentions working
> around a Linux server bug, but it's not quite clear what that bug
> is, and why it's still around after almost three years since it was
> found.

Hi Christoph,

The above message should be harmless.

A lot of servers interpreted section 5.8 of RFC3530 to mean that clients should always send user/group information in the user@domain / group@domain format, and that it should never use numeric uids and gids. However when using AUTH_SYS authentication, using numeric uids/gids make a lot of sense, and doing so ensures that upgrades from NFSv3 to NFSv4 are a lot easier. It also means that you don’t need to run the idmapper.

For that reason, when you try to use NFSv4 with AUTH_SYS these days, the Linux client will try to use numeric uids/gids, and then fall back to using user@domain/group@domain if the server doesn’t support it. The above printk is there in order to help admins to recognize that their server requires the idmapper service.

Note that you can change the default behaviour using the nfs4_disable_idmapping kernel parameter (see Documentation/kernel-parameters.txt).

Cheers
  Trond