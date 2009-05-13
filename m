From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.30-rc deadline scheduler performance regression for iozone
  over NFS
Date: Wed, 13 May 2009 09:32:29 -0700
Message-ID: <20090513093229.097b47d2.akpm@linux-foundation.org>
References: <x49hc0f79k9.fsf@segfault.boston.devel.redhat.com>
	<20090508120119.8c93cfd7.akpm@linux-foundation.org>
	<20090511081415.GL4694@kernel.dk>
	<x49skjb21b7.fsf@segfault.boston.devel.redhat.com>
	<20090511165826.GG4694@kernel.dk>
	<x494ovp4r51.fsf@segfault.boston.devel.redhat.com>
	<20090512204433.7eb69075.akpm@linux-foundation.org>
	<x49y6t1rqw0.fsf@segfault.boston.devel.redhat.com>
	<b4ff356f0905130920v184ab529mb52a4346d4c77c14@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Jeff Moyer <jmoyer@redhat.com>, Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
To: Olga Kornievskaia <aglo@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37447 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752003AbZEMQmK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2009 12:42:10 -0400
In-Reply-To: <b4ff356f0905130920v184ab529mb52a4346d4c77c14-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 13 May 2009 12:20:57 -0400 Olga Kornievskaia <aglo@citi.umich.edu> wrote:

> I believe what you are seeing is how well TCP autotuning performs.
> What old NFS code was doing is disabling autotuning and instead using
> #nfsd thread to scale TCP recv window. You are providing an example of
> where setting TCP buffer sizes outperforms TCP autotuning. While this
> is a valid example, there is also an alternative example of where old
> NFS design hurts performance.

<scratches head>

Jeff's computer got slower.  Can we fix that?
