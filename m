From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: [PATCH 2/2] nfsstat: Add --list flag
Date: Tue, 17 Mar 2009 09:16:58 -0700
Message-ID: <1237306618.4048.2.camel@dyn9047022153>
References: <1237225556-27691-1-git-send-email-kevin.constantine@disneyanimation.com>
	 <1237225556-27691-2-git-send-email-kevin.constantine@disneyanimation.com>
	 <49BF2478.8080600@sgi.com>  <49BF9460.4050108@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Banks <gnb@sgi.com>,
	Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>,
	linux-nfs@vger.kernel.org,
	Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:52929 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754772AbZCQP6b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2009 11:58:31 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n2HFoWnV030511
	for <linux-nfs@vger.kernel.org>; Tue, 17 Mar 2009 11:50:32 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2HFwTQi152416
	for <linux-nfs@vger.kernel.org>; Tue, 17 Mar 2009 11:58:29 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2HFwRRO006050
	for <linux-nfs@vger.kernel.org>; Tue, 17 Mar 2009 11:58:29 -0400
In-Reply-To: <49BF9460.4050108-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-03-17 at 08:15 -0400, Steve Dickson wrote:
> Thanks Greg for taking a look... 
> 
> Greg Banks wrote:
> > Kevin Constantine wrote:
> > 
> > Maybe you can smooth out this difference, and make the code simpler and
> > cleaner, by making the output always be exactly two columns, one for the
> > label and one for the value.  Then your earlier quoted example would be
> > something like
...
> >      nfs v3 server readdir:     0
> >  nfs v3 server readdirplus:     0
> >       nfs v3 server fsstat:     0
> >       nfs v3 server fsinfo:     0
> >     nfs v3 server pathconf:     0
> >       nfs v3 server commit:     0
> Finally, does it really make sense to show a stats with zero occurrences?
> Why not just show what has happen instead of including what has not happen?

I've done some playing with nfsstat and one thing I added was a -q
(--quick) option that suppressed zero entries. It does make it a lot
easier to look at stats when you only have to look at the interesting
data.

Frank


