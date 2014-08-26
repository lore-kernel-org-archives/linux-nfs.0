Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:4141 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932326AbaHZPYj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Aug 2014 11:24:39 -0400
Date: Tue, 26 Aug 2014 11:24:22 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Adam C. Emerson" <aemerson@linuxbox.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-ID: <1435166875.78.1409066662291.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <53FCA183.8000605@plexistor.com>
Subject: Re: [PATCH] pnfs: Kick a pnfs_layoutcommit_inode on recall
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

IIUC, the problem is the forechannel slot count, since the call you want to make synchronously is on the forechannel?

Matt

----- "Boaz Harrosh" <boaz@plexistor.com> wrote:

> On 08/26/2014 05:55 PM, Trond Myklebust wrote:
> > On Tue, Aug 26, 2014 at 10:37 AM, Boaz Harrosh <boaz@plexistor.com>
> wrote:
> > 
> > The above can deadlock if there are no session slots available to
> send
> > the layoutcommit, in which case the recall won't complete, and the
> > layoutget won't get a reply (which would free up the slot).
> > 
> 
> What? the back-channel and the fore-channel do not use the same
> slots. these are two different slots, No?
> 
> Matt, Adam you need to chip in here.
> 
> If it is as you say, then yes it must be as Christoph wrote it.
> 
> And the Ganesha server must be fixed because it has a slot system per
> channel.
> 
> Thanks
> Boaz

-- 
Matt Benjamin
The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel.  734-761-4689 
fax.  734-769-8938 
cel.  734-216-5309 
