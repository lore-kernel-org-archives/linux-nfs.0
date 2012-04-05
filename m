Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:60385 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753686Ab2DEIpL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Apr 2012 04:45:11 -0400
Received: by wejx9 with SMTP id x9so699776wej.19
        for <linux-nfs@vger.kernel.org>; Thu, 05 Apr 2012 01:45:10 -0700 (PDT)
Message-ID: <4F7D5B92.5090203@tonian.com>
Date: Thu, 05 Apr 2012 11:45:06 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: Boaz Harrosh <bharrosh@panasas.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Matt W. Benjamin" <matt@linuxbox.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: unlink within an open directory stream
References: <275611967.8.1332608027370.JavaMail.root@thunderbeast.private.linuxbox.com> <1332609149.25346.12.camel@lade.trondhjem.org> <4F70B2AE.4000504@panasas.com> <20120404113539.2dc9b1dc@corrin.poochiereds.net>
In-Reply-To: <20120404113539.2dc9b1dc@corrin.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-04-04 18:35, Jeff Layton wrote:
> On Mon, 26 Mar 2012 11:17:18 -0700
> Boaz Harrosh <bharrosh@panasas.com> wrote:
> 
>> On 03/24/2012 10:12 AM, Myklebust, Trond wrote:
>>
>>> On Sat, 2012-03-24 at 12:53 -0400, Matt W. Benjamin wrote:
>>>> Hi,
>>>>
>>>> I don't think anything is.  Or, people originally reported the behavior against knfsd.
>>>>
>>>> Matt
>>>
>>> There is a known issue with ext2/3/4 generating non-unique readdir
>>> cookies. It rarely hits you when you are creating small directories, but
>>> it frequently hits you with larger ones. A fix is underway that should
>>> significantly reduce the frequency of cookie collisions.
>>>
>>> Recent NFS clients will actually detect the presence of those cookie
>>> loops, and log them in the kernel syslog. That would therefore be the
>>> first thing that I'd check if confronted with this kind of problem.
>>>
>>> Cheers
>>>   Trond
>>>
>>
>>
>> Trond please look on the bug report links below. It's not the "cookie collisions" case.
>>
>> It's the new (post RHEL 6.0 Kernel) NFS need for opendir after an unlink.
>> Now the POSIX man page *does* say that applications must re-opendir after
>> unlink, but there are some applications who did not read the manual, and since
>> it works with local filesystems and old nfs, (What Kernel RHEL 6.0 is based on?)
>> they never noticed the bug and never fixed it.
>>
> 
> 	^^^^^
> Can you tell me which manpage says this? I'd like to be able to point
> application developers at it if possible...
> 

Hmm, http://pubs.opengroup.org/onlinepubs/9699919799/functions/readdir.html says:

files may be removed from a directory or added to a directory asynchronously to the operation of readdir().

...

If a file is removed from or added to the directory after the most recent call to opendir() or rewinddir(), whether a subsequent call to readdir() returns an entry for that file is unspecified.

...

If a file is removed from or added to the directory after the most recent call to opendir() or rewinddir(), whether a subsequent call to readdir_r() returns an entry for that file is unspecified.

Benny

>> Could we easily support the broken application by being bug compatible to
>> old NFS versions?
>> .i.e Don't require re-opendir after unlink of a file.
>>
>> There are more examples in the bug reports below but basically bonnie++
>> does the following:
>> 	DIR *d = opendir(".");
>> 	dirent *file_ent;
>> 	while((file_ent = readdir(d)) != NULL) {
>> 		unlink( file_ent->d_name))
>> 	}
>> 	closedir(d);
>>
>> where it actually needs to do:
>>
>> 	DIR *d = opendir(".");
>> 	dirent *file_ent;
>> 	while((file_ent = readdir(d)) != NULL) {
>> 		unlink( file_ent->d_name))
>>
>> 		closedir(d);
>> 		d = opendir(".");
>> 	}
>> 	closedir(d);
>>
>> But again case one used to work with old NFS. And it looks like
>> it is not Server dependent. We saw this both with Ganesha as well
>> as knfsd
>>
>> <snip>
>>
> 
> Again, my suspicion is that the change that triggered this is the
> switch to use READDIRPLUS on larger directories. Before that, we'd use
> READDIR on larger ones and wouldn't need to make as many RPCs to fetch
> directory contents. More continuation READDIRPLUS calls means that you
> have more opportunity to hit problems with cookies.
> 
> What might be an interesting test is to see whether this is still
> reproducible on newer clients when you mount with '-o nordirplus'.
> 
> Cheers,
