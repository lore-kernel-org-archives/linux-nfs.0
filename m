From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] nfs-utils: Check for strlcat/cpy and compile our private
 version only if it's needed.
Date: Wed, 20 Oct 2010 22:14:37 -0400
Message-ID: <20101021021437.GA5241@infradead.org>
References: <20101020213554.GA27541@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:33339 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756775Ab0JUCOl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Oct 2010 22:14:41 -0400
In-Reply-To: <20101020213554.GA27541-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Not that I'd complain, but what Linux libc provides strlcat/cpy?

