Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:50896 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751375AbcFHCWT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 22:22:19 -0400
Subject: Re: Files leak from nfsd in 4.7.1-rc1 (and more?)
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <1465344205.3024.42.camel@poochiereds.net>
Date: Tue, 7 Jun 2016 22:22:06 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>
Message-Id: <AA8AB6FA-E3FF-42B9-A275-0173BD667B0F@linuxhacker.ru>
References: <4EDA6CFD-1FE8-4FCA-ACCF-84250BE342CB@linuxhacker.ru> <1465319435.3024.25.camel@poochiereds.net> <0F21EDD6-5CBB-4B5B-A1FF-E066011D18D6@linuxhacker.ru> <1465329897.3024.38.camel@poochiereds.net> <752F7196-1EE7-4FB3-8769-177131C8A793@linuxhacker.ru> <1465344205.3024.42.camel@poochiereds.net>
To: Jeff Layton <jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 7, 2016, at 8:03 PM, Jeff Layton wrote:

>>> That said, this code is quite subtle. I'd need to look over it in more
>>> detail before I offer up any fixes. I'd also appreciate it if anyone
>>> else wants to sanity check my analysis there.
>>> 
> Yeah, I think you're right. It's fine since r/w opens have a distinct
> slot, even though the refcounting just tracks the number of read and
> write references. So yeah, the leak probably is in an error path
> someplace, or maybe a race someplace.

So I noticed that set_access is always called locked, but clear_access is not,
this does not sound right.

So I placed this strategic WARN_ON:
@@ -3991,6 +4030,7 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
                        goto out_put_access;
                spin_lock(&fp->fi_lock);
                if (!fp->fi_fds[oflag]) {
+WARN_ON(!test_access(open->op_share_access, stp));
                        fp->fi_fds[oflag] = filp;
                        filp = NULL;
       
This is right in the place where nfsd set the access flag already, discovered
that the file is not opened and went on to open it, yet some parallel thread
came in and cleared the flag by the time we got the file opened.
It did trigger (but there are 30 minutes left till test finish, so I don't
know yet if this will correspond to the problem at hand yet, so below is speculation).

Now, at the exit from this function, the state will not have access for this file
set and the file would be leaked, since the matching call, probably in
release_all_access() does:
                if (test_access(i, stp))
                        nfs4_file_put_access(stp->st_stid.sc_file, i);
                clear_access(i, stp);

Meaning that the refcount is not dropped due to no access flag set.

I imagine we can just set the flag back right after setting fp->fi_fds[oflag]
and that particular race would be gone?

Would that be ok, or is it just wrong that somebody can come and drop
(delegation downgrade seems to be the most likely suspect) access bits like this
while they are in the middle of being acquired?

