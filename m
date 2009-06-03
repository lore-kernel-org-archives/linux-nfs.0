From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH]  bug in old-cache handling in mountd.
Date: Wed, 03 Jun 2009 15:45:28 -0400
Message-ID: <4A26D2D8.5090200@RedHat.com>
References: <18975.16159.264056.854413@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42503 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751311AbZFCTsb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 15:48:31 -0400
In-Reply-To: <18975.16159.264056.854413-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Neil Brown wrote:
> Hi,
>  there is a bug in the old-cache behaviour of mountd.
>  Hopefully no-one is using this but you never know....
> 
>  The bug was reported to redhat
>     https://bugzilla.redhat.com/show_bug.cgi?id=164186
> 
>  It was fixed incorrectly and never (that I recall) reported
>  upstream. :-(
> 
>  A SLES customer thinks they have hit the same problem, which is why
>  I'm looking at it.  (They shouldn't really hit it because that
>  version of sles uses 'new_cache' but maybe nfsdfs was disabled
>  somehow - don't know yet).
> 
>  Anyway, when mountd gets a mount request, it tells the kernel about it
>  and remembers that it told the kernel so it doesn't have to tell the
>  kernel again.
>  It is possible that "exportfs -r" will tell the kernel to forget that
>  information if the client has since unmounted.
>  So mountd really needs to tell the kernel even if it thinks the
>  kernel should already know.
> 
>  The following patch does this if the kernel refuses to provide a
>  valid filehandle.
> 
>  Does RHEL3 use old-cache or new-cache ??
The new cache, if it exists...

Committed..

steved.
