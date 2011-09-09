From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V6 14/26] richacl: Permission mapping functions
Date: Fri, 09 Sep 2011 17:24:07 +0530
Message-ID: <87ipp23p9c.fsf@skywalker.in.ibm.com>
References: <1315243548-18664-15-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <23273.1315564570@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dhowells@redhat.com, agruen@kernel.org, bfields@fieldses.org,
	akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:36119 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933670Ab1IILzU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Sep 2011 07:55:20 -0400
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 9 Sep 2011 07:55:19 -0400
In-Reply-To: <23273.1315564570@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 09 Sep 2011 11:36:10 +0100, David Howells <dhowells@redhat.com> wrote:
> Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > +unsigned int
> > +richacl_want_to_mask(int want)
> 
> unsigned int want?
> 

updated the patch

-aneesh

