From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/2] nfsstat: Add --list flag
Date: Tue, 17 Mar 2009 08:15:28 -0400
Message-ID: <49BF9460.4050108@RedHat.com>
References: <1237225556-27691-1-git-send-email-kevin.constantine@disneyanimation.com> <1237225556-27691-2-git-send-email-kevin.constantine@disneyanimation.com> <49BF2478.8080600@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>,
	linux-nfs@vger.kernel.org,
	Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56032 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755536AbZCQMSZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2009 08:18:25 -0400
In-Reply-To: <49BF2478.8080600@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Greg for taking a look... 

Greg Banks wrote:
> Kevin Constantine wrote:
> 
> Maybe you can smooth out this difference, and make the code simpler and
> cleaner, by making the output always be exactly two columns, one for the
> label and one for the value.  Then your earlier quoted example would be
> something like
> 
>        nfs v3 client total:   213
>         nfs v3 client null:     0
>      nfs v3 client getattr:    23
>      nfs v3 client setattr:     9
>       nfs v3 client lookup:     8
>       nfs v3 client access:     1
>     nfs v3 client readlink:     0
>         nfs v3 client read:     7
>        nfs v3 client write:    23
>       nfs v3 client create:     8
>        nfs v3 client mkdir:     0
>      nfs v3 client symlink:     0
>        nfs v3 client mknod:     0
>       nfs v3 client remove:     7
>        nfs v3 client rmdir:     0
>       nfs v3 client rename:     1
>         nfs v3 client link:     0
>      nfs v3 client readdir:     0
>  nfs v3 client readdirplus:     0
>       nfs v3 client fsstat:   126
>       nfs v3 client fsinfo:     0
>     nfs v3 client pathconf:     0
>       nfs v3 client commit:     0 
>        nfs v3 server total:     0
>         nfs v3 server null:     0
>      nfs v3 server getattr:     0
>      nfs v3 server setattr:     0
>       nfs v3 server lookup:     0
>       nfs v3 server access:     0
>     nfs v3 server readlink:     0
>         nfs v3 server read:     0
>        nfs v3 server write:     0
>       nfs v3 server create:     0
>        nfs v3 server mkdir:     0
>      nfs v3 server symlink:     0
>        nfs v3 server mknod:     0
>       nfs v3 server remove:     0
>        nfs v3 server rmdir:     0
>       nfs v3 server rename:     0
>         nfs v3 server link:     0
>      nfs v3 server readdir:     0
>  nfs v3 server readdirplus:     0
>       nfs v3 server fsstat:     0
>       nfs v3 server fsinfo:     0
>     nfs v3 server pathconf:     0
>       nfs v3 server commit:     0
Question... Now why are we *not* using the information from /proc/self/mountstats
and doing this per mount?

Also, can I assume (not looking at the patches yet) that this same type info
will be available v2 and v4?

Finally, does it really make sense to show a stats with zero occurrences?
Why not just show what has happen instead of including what has not happen?

steved.
 
 
