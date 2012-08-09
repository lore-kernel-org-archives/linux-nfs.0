Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46879 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932196Ab2HIMSv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Aug 2012 08:18:51 -0400
Date: Thu, 9 Aug 2012 08:18:32 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Namjae Jeon <linkinjeon@gmail.com>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        michael.brantley@deshaw.com, hch@infradead.org, miklos@szeredi.hu,
        pstaubach@exagrid.com
Subject: Re: [PATCH v5 00/19] vfs: add the ability to retry on ESTALE to
 several syscalls
Message-ID: <20120809081832.022e6a7d@corrin.poochiereds.net>
In-Reply-To: <CAKYAXd9QyKtH7ZvCJs=X2DxhDn9_THXUooWVCWkxuEhizWgmsA@mail.gmail.com>
References: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
	<CAKYAXd9QyKtH7ZvCJs=X2DxhDn9_THXUooWVCWkxuEhizWgmsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 9 Aug 2012 20:57:14 +0900
Namjae Jeon <linkinjeon@gmail.com> wrote:

> Hi Jeff.
> 
> I still found ESTALE error although patching these patch-set.
> Is test method correct that I try to run estale_test on each nfs
> server and client at the same time ?
> 
> ./estale_test
> chmod: Stale NFS[  281.720000] ##### send signal from USER, SIG : 2,
> estale_test(107)->estale_test(102) sys_kill
> [  281.728000] ##### send signal from USER, SIG : 15,
> estale_test(102)->estale_test(103) sys_kill
> [  281.736000] ##### send signal from USER, SIG : 15,
> estale_test(102)->estale_test(104) sys_kill
> [  281.744000] ##### send signal from USER, SIG : 15,
> estale_test(102)->estale_test(105) sys_kill
> [  281.752000] ##### send signal from USER, SIG : 15,
> estale_test(102)->estale_test(106) sys_kill
> [  281.760000] ##### send signal from USER, SIG : 15,
> estale_test(102)->estale_test(107) sys_kill
> [  281.768000] ##### send signal from USER, SIG : 15,
> estale_test(102)->estale_test(108) sys_kill
> [  281.780000] ##### send signal from USER, SIG : 15,
> estale_test(102)->estale_test(109) sys_kill
> [  281.788000] ##### send signal from USER, SIG : 15,
> estale_test(102)->estale_test(110) sys_kill
> [  281.796000] ##### send signal from USER, SIG : 15,
> estale_test(102)->estale_test(111) sys_kill
> [  281.804000] ##### send signal from USER, SIG : 15,
> estale_test(102)->estale_test(112) sys_kill
> [  281.812000] ##### send signal from USER, SIG : 15,
> estale_test(102)->estale_test(113) sys_kill
> [  281.820000] ##### send signal from USER, SIG : 15,
> estale_test(102)->estale_test(114) sys_kill
> [  281.828000] ##### send signal from USER, SIG : 15,
> estale_test(102)->estale_test(115) sys_kill
> [  281.840000] ##### send signal from USER, SIG : 15,
> estale_test(102)->estale_test(116) sys_kill
> [  281.848000] ##### send signal from USER, SIG : 15,
> estale_test(102)->estale_test(117) sys_kill
> [  281.856000] ##### send signal from USER, SIG : 15,
> estale_test(102)->estale_test(118) sys_kill
> [  281.864000] ##### send signal from USER, SIG : 15,
> estale_test(102)->estale_test(119) sys_kill
>  file handle
> VDLinux#> chdir: Stale NFS[  282.664000] ##### send signal from USER,
> SIG : 2, estale_test(120)->???(102) sys_kill
>  file handle
> 
> Thanks.
> 

I guess you didn't read my response earlier? I'll re-post it here...

> It's a bit labor intensive, I'm afraid...
>
> Attached is a cleaned-up copy of the test program that Peter wrote to
> test his original patchset. The basic idea is to run this on both the
> client and server at the same time so they race against each other. He
> was able to run it overnight when testing with his patchset.
>
> With this patchset, that doesn't work since we're only retrying the
> lookup and call once. So, what I've been doing is modifying the program
> so that it just runs one test at a time, and sniffing traffic to see
> whether the lookups and calls are retried after an ESTALE return from
> the server. 


So, ESTALE errors are still expected when running that test. This
patchset only fixes a very specific set of circumstances where an entry
goes stale once between the lookup and the actual operation(s).
Anything outside of that, and it won't help.

That test is very aggressive, and can cause it to race multiple times.
You actually have to sniff traffic and look to see if the lookup and
call were reattempted after the ESTALE error.

-- 
Jeff Layton <jlayton@redhat.com>
