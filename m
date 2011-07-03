Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.ugent.be ([157.193.71.182]:57810 "EHLO smtp1.UGent.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752599Ab1GCNTn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 3 Jul 2011 09:19:43 -0400
Message-ID: <4E106A56.1050802@debian.org>
Date: Sun, 03 Jul 2011 15:10:46 +0200
From: Luk Claes <luk@debian.org>
To: Jim Rees <rees@umich.edu>
CC: NeilBrown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Do not segfault because of kernel version
References: <1309617149-3993-1-git-send-email-luk@debian.org> <20110703150421.2db09d94@notabene.brown> <4E100E17.5000304@debian.org> <20110703130237.GA9889@merit.edu>
In-Reply-To: <20110703130237.GA9889@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/03/2011 03:02 PM, Jim Rees wrote:
> Luk Claes wrote:
> 
>   > So if the version number is not recognised - e.g. it was written in Sanskrit
>   > rather than arabic numberals, it is assumed to be a future version, not a
>   > past version.
>   > 
>   >  https://lkml.org/lkml/2011/6/14/293
>   
>   Ah, not a bad idea. In that case a parse error can be distinguished from
>   other errors. Would 'return -1' do the expected or will it give a
>   compiler warning/error we should avoid?
> 
> You can't return -1 from a function returning unsigned int.  I think you
> want to return something like
> 
> MAKE_VERSION(9999, 255, 255)

Would it not be better to return UINT_MAX in that case to avoid having
to change it when version 10000 would be released and to avoid overflows
that could potentially order lower?

Cheers

Luk
