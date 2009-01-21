From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Wed, 21 Jan 2009 15:39:29 -0500
Message-ID: <20090121203929.GA7389@infradead.org>
References: <49711BDF.3010605@melbourne.sgi.com> <x49ab9ntlpp.fsf@segfault.boston.devel.redhat.com> <20090121101329.GA4876@in.ibm.com> <49774FDC.5090307@RedHat.com> <20090121170401.GD4394@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, prasad@linux.vnet.ibm.com,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	SystemTAP <systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org>
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:39025 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152AbZAUUje (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jan 2009 15:39:34 -0500
In-Reply-To: <20090121170401.GD4394-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 21, 2009 at 03:04:01PM -0200, Arnaldo Carvalho de Melo wrote:
> I suggest you provide an ftrace plugin, just like I'm doing with
> blktrace, see:

*nod*

ftrace for now, long-term we also want some ltt integration (hopefully
we'll have some form of a generic shim so that one data source can
provide trace information for both ftrace and ltt)

