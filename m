From: Peter Staubach <staubach@redhat.com>
Subject: Re: inode caching
Date: Tue, 27 May 2008 14:09:37 -0400
Message-ID: <483C4E61.7020102@redhat.com>
References: <1211835499.3904.231.camel@hurina>  <483C031B.80601@redhat.com> <1211902848.3904.279.camel@hurina>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Timo Sirainen <tss@iki.fi>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50931 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756031AbYE0SJo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 May 2008 14:09:44 -0400
In-Reply-To: <1211902848.3904.279.camel@hurina>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Timo Sirainen wrote:
> On Tue, 2008-05-27 at 08:48 -0400, Peter Staubach wrote:
>   
>> Timo Sirainen wrote:
>>     
>>> NFS server: Linux 2.6.25
>>> NFS client: Linux debian 2.6.25-2 (or 2.6.23.1)
>>>
>>> If I do:
>>>
>>> NFS client: fd1 = creat("foo"); write(fd1, "xx", 2); fsync(fd1);
>>> NFS server: unlink("foo"); creat("foo");
>>> NFS client: fd2 = open("foo"); fstat(fd1, &st1); fstat(fd2, &st2);
>>> fstat(fd1, &st3);
>>>
>>> The result is usually that the fstat(fd1) fails with ESTALE. But
>>> sometimes the result is st1.st_ino == st2.st_ino == st3.st_ino and
>>> st1.st_size == 2 but st2.st_size == 0. So I see two different files
>>> using the same inode number. I'd really want to avoid seeing that
>>> condition.
>>>
>>>   
>>>       
>> This is really up the file system on the server. It is the one
>> that selects the inode number when creating a new file.
>>     
>
> I don't mind that the inode gets reused, I mind that I can't reliably
> detect that situation.
>
>   

Outside of shortening up the attribute cache timeout values,
with the current implementation, I don't think that you are
going to be able to reliably detect when the file on the server
has been removed and recreated.

>>> So what I'd want to know is:
>>>
>>> a) Why does this happen only sometimes? I can't really figure out from
>>> the code what invalidates the fd1 inode. Apparently the second open()
>>> somehow, but since it uses the new "foo" file with a different struct
>>> inode, where does the old struct inode get invalidated?
>>>
>>>   
>>>       
>> This will happen always, but you may see occasional successful
>> fstat() calls on the client due to attribute caching and/or
>> dentry caching.
>>     
>
> I would understand if it always failed or always succeeded, but it seems
> to be somewhat random now. And it's not "occational successful fstat()",
> but it's "occational failed fstat()". The difference shouldn't be
> because of attribute caching, because I specify it explicitly to two
> seconds and run the test within that 2 second. So the test should always
> hit the attribute cache, and according to you that should always cause
> it to succeed (but it rarely does). I think dentry caching also more or
> less depends on attribute cache timeout?
>
>   

How did you specify the attribute cache to be 2 seconds?

The dentry based caching is also subject to timeout based
verification, but typically on much longer time scales.


>>> b) Can this be fixed? Or is it just luck that it works as well as it
>>> does now?
>>>
>>>   
>>>       
>> This can be fixed, somewhat. I have some changes to address the
>> ESTALE situation in system calls that take filename as arguments,
>> but I need to work with some more people to get them included.
>> The system calls which do not take file names as arguments can not
>> be recovered from because the file they are referring is really
>> gone or at least not accessible anymore.
>>
>> The reuse of the inode number is just a fact of life and that way
>> that file systems work. I would suggest rethinking your application
>> in order to reduce or eliminate any dependence that it might have.
>>     
>
> The problem I have is that I need to reliably find out if a file has
> been replaced with a new file. So I first flush the dentry cache
> (chowning parent directory), stat() the file and fstat() the opened
> file. If fstat() fails with ESTALE or if the inodes don't match, I know
> that the file has been replaced and I need to re-open and re-read it.
> This seems to work nearly always.
>   

This would seem to be quite implementation specific and also has
some timing dependencies built-in.  These would seem to me to be
dangerous assumptions and heuristics to be depending upon.

Have you considered making the contents of the file itself versioned
in some fashion and thus, removing dependencies on how the NFS client
works and/or the file system on the NFS server?

    Thanx...

       ps
