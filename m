From: Jim Rees <rees@umich.edu>
Subject: Re: 2.6.30-rc deadline scheduler performance regression for iozone
	over NFS
Date: Wed, 13 May 2009 14:25:24 -0400
Message-ID: <20090513182524.GA20778@merit.edu>
References: <x49hc0f79k9.fsf@segfault.boston.devel.redhat.com> <20090508120119.8c93cfd7.akpm@linux-foundation.org> <20090511081415.GL4694@kernel.dk> <x49skjb21b7.fsf@segfault.boston.devel.redhat.com> <20090511165826.GG4694@kernel.dk> <x494ovp4r51.fsf@segfault.boston.devel.redhat.com> <20090512204433.7eb69075.akpm@linux-foundation.org> <x49y6t1rqw0.fsf@segfault.boston.devel.redhat.com> <b4ff356f0905130920v184ab529mb52a4346d4c77c14@mail.gmail.com> <20090513093229.097b47d2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olga Kornievskaia <aglo@citi.umich.edu>,
	Jeff Moyer <jmoyer@redhat.com>,
	Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:36018 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755816AbZEMSeE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 May 2009 14:34:04 -0400
In-Reply-To: <20090513093229.097b47d2.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Andrew Morton wrote:

  Jeff's computer got slower.  Can we fix that?

TCP autotuning can reduce performance by up to about 10% in some cases.
Jeff found one of these cases.  While the autotuning penalty never exceeds
10% as far as I know, I can provide examples of other cases where autotuning
improves nfsd performance by more than a factor of 100.

The right thing is to fix autotuning.  If autotuning is considered too
broken to use, it should be turned off everywhere, not just in nfsd, as it
hurts/benefits all TCP clients, not just nfs.

This topic has been discussed before on netdev:
http://www.spinics.net/lists/netdev/msg68650.html
http://www.spinics.net/lists/netdev/msg68155.html
