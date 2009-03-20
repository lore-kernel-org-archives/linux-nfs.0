From: Timo Aaltonen <tjaalton-kf+aQKke1yb1KXRcyAk9cg@public.gmane.org>
Subject: Re: atomic rename buggy on NFS?
Date: Fri, 20 Mar 2009 09:46:37 +0200 (EET)
Message-ID: <alpine.OSF.1.99.0903200940280.384018@replicant.hut.fi>
References: <alpine.OSF.1.99.0903191403140.384018@replicant.hut.fi> <1237471797.7534.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-2.hut.fi ([130.233.228.92]:51419 "EHLO smtp-2.hut.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750836AbZCTHrM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Mar 2009 03:47:12 -0400
In-Reply-To: <1237471797.7534.1.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 19 Mar 2009, Trond Myklebust wrote:

> On Thu, 2009-03-19 at 14:23 +0200, Timo Aaltonen wrote:
>> * http://bugzilla.gnome.org/show_bug.cgi?id=575684
>>
>
> Does the appended patch fix it?

Oh yes, thanks!

Tested-by: Timo Aaltonen <tjaalton-kf+aQKke1yb1KXRcyAk9cg@public.gmane.org>

(tested with Ubuntu 9.04 alpha 2.6.28.x client, ONTAP 7.2.x server)

t
