From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [PATCH 06/19] Use get_random_bytes() to create confounder
Date: Wed, 12 Mar 2008 14:37:26 -0400
Message-ID: <4d569c330803121137w755c5c76j4b692aac53d54619@mail.gmail.com>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu>
	 <20080221184417.19195.55123.stgit@jazz.citi.umich.edu>
	 <20080312164616.GF10015@fieldses.org> <1205344238.11354.59.camel@calx>
	 <20080312180337.GH10015@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Matt Mackall" <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:32340 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753439AbYCLSh2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Mar 2008 14:37:28 -0400
Received: by ug-out-1314.google.com with SMTP id z38so308755ugc.16
        for <linux-nfs@vger.kernel.org>; Wed, 12 Mar 2008 11:37:27 -0700 (PDT)
In-Reply-To: <20080312180337.GH10015@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 12, 2008 at 2:03 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Mar 12, 2008 at 12:50:38PM -0500, Matt Mackall wrote:
>
>  > Take a look at lib/random32.c for a moderately stong and fast PRND.
>  > Reseeding that periodically with get_random_bytes might be sufficient.
>  > Or look at secure_tcp_sequence_number in random.c for a more ad-hoc
>  > approach.
>
>  OK.  Yes, I'd definitely be happy to sacrifice quality for performance
>  in this case, at least until I see an argument pointing out some reason
>  we need good randomness here....
>
>  Thanks for the help!

Yes, thanks Matt.  It looks to me like random32() should be good (and
fast) enough for this.  Do you agree Bruce?

K.C.
