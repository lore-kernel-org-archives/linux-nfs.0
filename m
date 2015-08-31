Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47766 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752858AbbHaPXF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Aug 2015 11:23:05 -0400
Date: Mon, 31 Aug 2015 11:23:04 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas =?utf-8?Q?Gr=C3=BCnbacher?=
	<andreas.gruenbacher@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux API Mailing List <linux-api@vger.kernel.org>,
        linux-cifs@vger.kernel.org,
        LSM List <linux-security-module@vger.kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: Re: [RFC v6 10/40] richacl: Permission check algorithm
Message-ID: <20150831152304.GE17812@fieldses.org>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
 <1438689218-6921-11-git-send-email-agruenba@redhat.com>
 <20150828214917.GC23326@fieldses.org>
 <CAHpGcMJT0kQyrvCkur0csCmRn-LwUOJcRWqAfLaqCpNd2b8UXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAHpGcMJT0kQyrvCkur0csCmRn-LwUOJcRWqAfLaqCpNd2b8UXA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 29, 2015 at 12:06:22AM +0200, Andreas Grünbacher wrote:
> 2015-08-28 23:49 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> > On Tue, Aug 04, 2015 at 01:53:08PM +0200, Andreas Gruenbacher wrote:
> >> +             /*
> >> +              * We don't care which class the process is in when the acl is
> >> +              * not masked.
> >> +              */
> >> +             in_owner_or_group_class = 1;
> >
> > So why bother setting it at all, then?  Oh, I see, it lets you break out
> > of the loop below earlier.  OK.
> 
> Comment changed to:
> 
>                 /*
>                  * When the acl is not masked, there is no need to determine if
>                  * the process is in the group class and we can earlier break
>                  * out of the loop below.
>                  */

makes sense, just replace "earlier break out" by "break out earlier".

> 
> > Patch makes sense to me, ACK.
> 
> Thanks,
> Andreas
