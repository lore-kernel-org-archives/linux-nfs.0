Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:48196 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932830Ab2CZSRu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Mar 2012 14:17:50 -0400
Message-ID: <4F70B2AE.4000504@panasas.com>
Date: Mon, 26 Mar 2012 11:17:18 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Matt W. Benjamin" <matt@linuxbox.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: unlink within an open directory stream
References: <275611967.8.1332608027370.JavaMail.root@thunderbeast.private.linuxbox.com> <1332609149.25346.12.camel@lade.trondhjem.org>
In-Reply-To: <1332609149.25346.12.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/24/2012 10:12 AM, Myklebust, Trond wrote:

> On Sat, 2012-03-24 at 12:53 -0400, Matt W. Benjamin wrote:
>> Hi,
>>
>> I don't think anything is.  Or, people originally reported the behavior against knfsd.
>>
>> Matt
> 
> There is a known issue with ext2/3/4 generating non-unique readdir
> cookies. It rarely hits you when you are creating small directories, but
> it frequently hits you with larger ones. A fix is underway that should
> significantly reduce the frequency of cookie collisions.
> 
> Recent NFS clients will actually detect the presence of those cookie
> loops, and log them in the kernel syslog. That would therefore be the
> first thing that I'd check if confronted with this kind of problem.
> 
> Cheers
>   Trond
> 


Trond please look on the bug report links below. It's not the "cookie collisions" case.

It's the new (post RHEL 6.0 Kernel) NFS need for opendir after an unlink.
Now the POSIX man page *does* say that applications must re-opendir after
unlink, but there are some applications who did not read the manual, and since
it works with local filesystems and old nfs, (What Kernel RHEL 6.0 is based on?)
they never noticed the bug and never fixed it.

Could we easily support the broken application by being bug compatible to
old NFS versions?
.i.e Don't require re-opendir after unlink of a file.

There are more examples in the bug reports below but basically bonnie++
does the following:
	DIR *d = opendir(".");
	dirent *file_ent;
	while((file_ent = readdir(d)) != NULL) {
		unlink( file_ent->d_name))
	}
	closedir(d);

where it actually needs to do:

	DIR *d = opendir(".");
	dirent *file_ent;
	while((file_ent = readdir(d)) != NULL) {
		unlink( file_ent->d_name))

		closedir(d);
		d = opendir(".");
	}
	closedir(d);

But again case one used to work with old NFS. And it looks like
it is not Server dependent. We saw this both with Ganesha as well
as knfsd

<snip>

>> http://bugs.centos.org/view.php?id=5496
>> https://bugzilla.redhat.com/show_bug.cgi?id=789452

Thanks
Boaz
