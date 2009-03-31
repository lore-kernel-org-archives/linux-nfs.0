From: Steve Dickson <SteveD@redhat.com>
Subject: Re: lookup_one_len() returning d_count == 0
Date: Tue, 31 Mar 2009 15:40:04 -0400
Message-ID: <49D27194.50201@RedHat.com>
References: <49CE2C59.7040102@RedHat.com> <1238261492.6679.9.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:43909 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752866AbZCaTm6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 15:42:58 -0400
In-Reply-To: <1238261492.6679.9.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> My guess is that the dentry is being dput() twice somewhere, and so ends
> up with a d_count==-1. I'd suggest adding a
> BUG_ON(atomic_read(&dentry->d_count) <= 0) after the 'repeat:' label at
> the top of dput() in order to try to catch the culprit.
Thanks for the tip... that worked like a charm... 

steved.
