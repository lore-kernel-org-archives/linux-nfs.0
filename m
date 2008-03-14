From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [opensuse] nfs_update_inode: inode X mode changed, Y to Z
Date: Fri, 14 Mar 2008 22:21:27 +0100
Message-ID: <9a8748490803141421l5455084bp2305289121fcc0b7@mail.gmail.com>
References: <47CF0829.4020502@m2000.com>
	 <1204752463.5035.34.camel@heimdal.trondhjem.org>
	 <47CF157B.1010908@m2000.com>
	 <18383.24847.381754.517731@notabene.brown>
	 <47CF62C5.7000908@m2000.com>
	 <18384.50909.866848.966192@notabene.brown>
	 <9a8748490803121513w285cd45rb6b26a3d842cac1b@mail.gmail.com>
	 <20080312221511.GC31632@fieldses.org>
	 <9a8748490803121516u36395872i70cc88b0439adc74@mail.gmail.com>
	 <18394.1501.991087.80264@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Adam Schrotenboer" <adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>,
	"Trond Myklebust" <Trond.Myklebust@netapp.com>,
	lkml@vger.kernel.org, linux-nfs@vger.kernel.org,
	"Thomas Daniel" <tdaniel-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
To: "Neil Brown" <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.184]:49281 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759470AbYCNVV2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 17:21:28 -0400
Received: by rn-out-0910.google.com with SMTP id v46so2971834rnb.15
        for <linux-nfs@vger.kernel.org>; Fri, 14 Mar 2008 14:21:27 -0700 (PDT)
In-Reply-To: <18394.1501.991087.80264-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 14/03/2008, Neil Brown <neilb@suse.de> wrote:
> On Wednesday March 12, jesper.juhl@gmail.com wrote:
>  > On 12/03/2008, J. Bruce Fields <bfields@fieldses.org> wrote:
>  > >
>
> > > What was the exported filesystem?
>  > >
>  > XFS
>  >
>
>
> It's a bit of along shot, but could you try mounting the XFS file
>  system with
>    -o ikeep
>
>  and see if it makes a difference.
>
>  When you have "ikeep", I can find the code that increments the
>  generation number between different uses of the one inode number.
>
>  When you have "noikeep" (which I think is the default) it doesn't keep
>  the inode of disk when deleted and so (presumably) needs generate a
>  random generation number for each use.  But I cannot find the code
>  that does that.  I'm probably not looking in the right place, but I
>  don't think it can hurt to try "-o ikeep".
>
It's about a year since I posted my bug report and I'm no longer
responsible for the servers that showed the problem. I don't even know
what kernel they are running these days and if they still show this
problem. I'll try and talk to one of the guys who is currently
managing them on monday and see what information I can gather.


-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
