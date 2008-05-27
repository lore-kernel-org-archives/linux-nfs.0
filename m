From: Timo Sirainen <tss@iki.fi>
Subject: Re: inode caching
Date: Tue, 27 May 2008 22:13:37 +0300
Message-ID: <0BF144BC-6CBB-49FA-8F49-D765FB58AF5E@iki.fi>
References: <1211835499.3904.231.camel@hurina>  <483C031B.80601@redhat.com> <1211902848.3904.279.camel@hurina> <483C4E61.7020102@redhat.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=pgp-sha1; boundary="Apple-Mail-3--467300067"
Cc: linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dovecot.org ([82.118.211.50]:37924 "EHLO dovecot.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755894AbYE0TNr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 May 2008 15:13:47 -0400
In-Reply-To: <483C4E61.7020102@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-3--467300067
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit

On May 27, 2008, at 9:09 PM, Peter Staubach wrote:

>>>> So what I'd want to know is:
>>>>
>>>> a) Why does this happen only sometimes? I can't really figure out  
>>>> from
>>>> the code what invalidates the fd1 inode. Apparently the second  
>>>> open()
>>>> somehow, but since it uses the new "foo" file with a different  
>>>> struct
>>>> inode, where does the old struct inode get invalidated?
>>>>
>>>>
>>> This will happen always, but you may see occasional successful
>>> fstat() calls on the client due to attribute caching and/or
>>> dentry caching.
>>>
>>
>> I would understand if it always failed or always succeeded, but it  
>> seems
>> to be somewhat random now. And it's not "occational successful  
>> fstat()",
>> but it's "occational failed fstat()". The difference shouldn't be
>> because of attribute caching, because I specify it explicitly to two
>> seconds and run the test within that 2 second. So the test should  
>> always
>> hit the attribute cache, and according to you that should always  
>> cause
>> it to succeed (but it rarely does). I think dentry caching also  
>> more or
>> less depends on attribute cache timeout?
>>
>>
>
> How did you specify the attribute cache to be 2 seconds?

mount -o actimeo=2

>>>> b) Can this be fixed? Or is it just luck that it works as well as  
>>>> it
>>>> does now?
>>>>
>>>>
>>> This can be fixed, somewhat. I have some changes to address the
>>> ESTALE situation in system calls that take filename as arguments,
>>> but I need to work with some more people to get them included.
>>> The system calls which do not take file names as arguments can not
>>> be recovered from because the file they are referring is really
>>> gone or at least not accessible anymore.
>>>
>>> The reuse of the inode number is just a fact of life and that way
>>> that file systems work. I would suggest rethinking your application
>>> in order to reduce or eliminate any dependence that it might have.
>>>
>>
>> The problem I have is that I need to reliably find out if a file has
>> been replaced with a new file. So I first flush the dentry cache
>> (chowning parent directory), stat() the file and fstat() the opened
>> file. If fstat() fails with ESTALE or if the inodes don't match, I  
>> know
>> that the file has been replaced and I need to re-open and re-read it.
>> This seems to work nearly always.
>>
>
> This would seem to be quite implementation specific and also has
> some timing dependencies built-in.  These would seem to me to be
> dangerous assumptions and heuristics to be depending upon.
>
> Have you considered making the contents of the file itself versioned
> in some fashion and thus, removing dependencies on how the NFS client
> works and/or the file system on the NFS server?

I guess one possibility would be to link() the file elsewhere for "a  
while", so that the inode wouldn't get reused until everyone's  
attribute caches have become flushed. That feels a bit dirty solution  
too though. (This is about handling Dovecot IMAP/POP3's metadata files.)

I'd still like to understand why exactly this happens though. Maybe  
there's a chance that this is just a bug in the current NFS  
implementation so I could keep using my current code (which is  
actually very difficult to break even with stress testing, so if this  
doesn't get fixed on kernel side I'll probably just leave my code as  
it is). I guess I'll start debugging the NFS code to find out what's  
really going on.

--Apple-Mail-3--467300067
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: This is a digitally signed message part
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.8 (Darwin)

iEYEARECAAYFAkg8XWEACgkQyUhSUUBVism4EACfUgDrZYAfl1q51DIrP8sCEp3G
Rw4AniteuUpFC0pZyoNgsNUowVTZoGt2
=SGkX
-----END PGP SIGNATURE-----

--Apple-Mail-3--467300067--
