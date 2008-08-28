From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/3] Fix handling of explicit uuid
Date: Thu, 28 Aug 2008 11:38:18 -0400
Message-ID: <48B6C66A.2030705@RedHat.com>
References: <48A5449F.7050205@nokia.com>	 <1218808776.3184.89.camel@pmac.infradead.org>	 <1218809892.7037.3.camel@localhost>	 <1219058258.3184.358.camel@pmac.infradead.org> <1219061850.3184.378.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Artem.Bityutskiy@nokia.com, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45867 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646AbYH1PmF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Aug 2008 11:42:05 -0400
In-Reply-To: <1219061850.3184.378.camel-ZP4jZrcIevRpWr+L1FloEB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



David Woodhouse wrote:
> Fix a couple of bugs which show up if you try to explicitly set a
> 16-byte UUID when exporting a file system. First, exportfs cuts the
> first two bytes off the UUID and writes something invalid to etab.
> Second, mountd writes the _ascii_ form of the UUID to the kernel,
> instead of converting it to hex.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
Committed...

steved
