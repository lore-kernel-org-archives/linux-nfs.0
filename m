From: Ian Munsie <imunsie-8fk3Idey6ehBDgjK7y7TUQ@public.gmane.org>
Subject: Re: NFS sillyrename side effect
Date: Tue, 19 Oct 2010 16:18:54 +1100
Message-ID: <1287465288-sup-9227@au1.ibm.com>
References: <1287362142-sup-777@au1.ibm.com> <20101018101059.574b715a@corrin.poochiereds.net>
Content-Type: text/plain; charset=UTF-8
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	=?utf-8?q?Cl=C3=A1udio_Martins?= <ctpm-s6mEjpzMaPUVhHzd4jOs4w@public.gmane.org>,
	Trond Myklebust <trond.myklebust@netapp.com>,
	linux-nfs <linux-nfs@vger.kernel.org>,
	Scott Romanowski <romansc@us.ibm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e23smtp01.au.ibm.com ([202.81.31.143]:33674 "EHLO
	e23smtp01.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501Ab0JSFS7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Oct 2010 01:18:59 -0400
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp01.au.ibm.com (8.14.4/8.13.1) with ESMTP id o9J5FoQe024934
	for <linux-nfs@vger.kernel.org>; Tue, 19 Oct 2010 16:15:50 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9J5Iu8g876570
	for <linux-nfs@vger.kernel.org>; Tue, 19 Oct 2010 16:18:56 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9J5It8s020888
	for <linux-nfs@vger.kernel.org>; Tue, 19 Oct 2010 16:18:56 +1100
In-reply-to: <20101018101059.574b715a-4QP7MXygkU+dMjc06nkz3ljfA9RmPOcC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

Excerpts from Jeff Layton's message of Tue Oct 19 01:10:59 +1100 2010:
> See:
> 
> http://nfs.sourceforge.net/
> 
> ...section D2. The faq mentions that NFSv4 could do away with it
> because it's stateful, but that's not really the case either.

Thanks for the pointer.

> > It seems to me that if the sillyrename function is indeed necessary that
> > we should not reveal the temporary filename it produces to userspace,
> > but I wonder if that might create issues (say if userspace thinks a
> > directory is empty when it acutally has a sillyrename file in it)?
> > 
> > Basically I want to know if the behaviour I've outlined below is
> > the expected behaviour of NFS, or if you considder this a bug?
> > 
> 
> 
> It's expected. Sillyrenaming sucks, but there really is no great
> alternative to it. It's one of the prices we pay for having NFSv2/3 be
> stateless.
> 
> I suppose in principle we could do things like hide silly-renamed
> dentries from userspace, but that might also be problematic. You'd
> still be unable to remove a directory that has a silly-renamed file in
> it, for instance even though it looks empty. There would also be
> inconsistencies as other machines and the server would still see
> the .nfsXXXXX files.

I had a feeling that would be the case.

> The bottom line is that you need to be really careful with programs
> that use delete-on-last-close when running on NFS.


Thanks to everyone who replied for clarifying this matter for me.

Cheers,
-Ian
