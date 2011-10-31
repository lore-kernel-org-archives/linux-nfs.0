Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:19295 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932268Ab1JaQpT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 12:45:19 -0400
Subject: Re: [PATCH 2/2] nfs41: handle BLK_LAYOUT CB_RECALL_ANY
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Peng Tao <bergwolf@gmail.com>
Cc: linux-nfs@vger.kernel.org, bhalevy@tonian.com, Peng Tao <peng_tao@emc.com>
Date: Mon, 31 Oct 2011 12:45:01 -0400
In-Reply-To: <CA+a=Yy4L4GDsQL6hHG4DRLNPmvkMBpk4mW9ofWbQob+z2a1G2A@mail.gmail.com>
References: <1320074136-3087-1-git-send-email-bergwolf@gmail.com>
	 <1320074136-3087-2-git-send-email-bergwolf@gmail.com>
	 <1320076148.4714.4.camel@lade.trondhjem.org>
	 <CA+a=Yy4L4GDsQL6hHG4DRLNPmvkMBpk4mW9ofWbQob+z2a1G2A@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1320079501.4714.9.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2011-11-01 at 00:38 +0800, Peng Tao wrote: 
> On Mon, Oct 31, 2011 at 11:49 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > On Mon, 2011-10-31 at 08:15 -0700, Peng Tao wrote:
> >> For blocklayout, we need to issue layoutreturn to return layouts when
> >> handling CB_RECALL_ANY.
> >
> > Why?
> Because replying NFS4_OK to CB_RECALL_ANY indicates that client knows
> that server wants client to return layout. And server will be waiting
> for layoutreturn in such case.

No it doesn't. NFS4_OK means that the client acknowledges that it has
been given a new limit on the number of recallable objects it can keep.
There is no requirement in the text that it should send layoutreturn or
that the server should expect that.

In any case, there is no reason to make a difference between block,
object and file layouts when it comes to CB_RECALL_ANY. The code to
handle it should be the same for all.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

