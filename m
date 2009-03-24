From: Alex Bremer <albremer@googlemail.com>
Subject: Re: NFS4 ACL <-> Posix ACL
Date: Tue, 24 Mar 2009 02:56:25 +0100
Message-ID: <7f62dcb30903231856h7a17cea5ud7a22796ddfb6383@mail.gmail.com>
References: <7f62dcb30903181042n42bae0bbk99f5c91fce6e9e82@mail.gmail.com>
	 <20090319193514.GE3072@fieldses.org>
	 <7f62dcb30903230646u183c79e0i4366edebe32654d5@mail.gmail.com>
	 <20090323213304.GG1067@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f165.google.com ([209.85.219.165]:64968 "EHLO
	mail-ew0-f165.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753335AbZCXB42 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Mar 2009 21:56:28 -0400
Received: by ewy9 with SMTP id 9so1894161ewy.37
        for <linux-nfs@vger.kernel.org>; Mon, 23 Mar 2009 18:56:25 -0700 (PDT)
In-Reply-To: <20090323213304.GG1067@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2009/3/23, J. Bruce Fields <bfields@fieldses.org>:
>> So is there any way to make newly created files group writeable except
>> for setting the umask of each user to 002?
>
> I think that's the only option.
>
> And that looks hard to fix; if we were going to implement the same
> "inheritance overrides umask" exception as we do for posix acls, either:
>
> 	- The server would have to know about the umask; this would
> 	  require a protocol change.  (But it might not be that hard;
> 	  you could have a write-only "set the mode to this, but only in
> 	  the absence of inheritance" attribute.)
> 	- The client would have to do the inheritance itself, as it does
> 	  with posix acls.  This is perhaps not impossible, but it's
> 	  much more complicated with v4 acls.
>
> Hm.  Another odd option: do the open with the create mode + umask, as we
> currently do, then do a subsequent setattr to the create mode if the
> create mode is more generous and if the client detects inheritable acls
> on the parent directory.

Why so complicated? Of course these options would be the nicest way to
do it as it allows to set different permission inheritances on each
directory. However for many use cases it would be enough if one could
set the permissions on a share basis. A simple umask mount-option
would already help a lot. This way administrators could enforce a
umask on a share.

One of the problems with setting a global umask on a user basis is
that it can be override very easily. If a user doesn't like the fact
that all files are group writeable he can easily change it and then he
usually forgets to set write-permissions manually when writing public
files. As a consequence other users who want to write that file come
to me to have the permissions reset as they can not even tell who is
the owner of the file and ask him. :-)

>> Setting the umask to 002 is
>> not an option for us, but all files in the public area have to be
>> group writeable. Is there maybe a mount option to set the umask or a
>> server sided option which enforces the group writeable flag?
>>
>> I would expect that my use case is not that uncommon and that many
>> companys have the exact same problem. Would the inheritance work if we
>> used a fully NFS4-ACL compatible filesystem?
>
> No, and I suspect non-linux servers all have similar behavior in this
> respect.

Unix servery yes, but on windows using NTFS you can inherit permissions.

With PosixACLs Unix finally got permission inheritance too and this is
a blessing for administrators. The normal unix filesystem permissions
are good enough for many use cases but in a company with many users
and many different groups they do not fit. The simple case of allowing
users of two different groups access to a directory without giving
others rx access forces you to create a third group with all the users
of both groups. Adding new users gets a pain in the ass as you have to
add them to more and more groups just to get the permissions right.

So Posix ACLs are really great for admins. From an admin's point of
view I can't understand why the NFS4-ACLs - which are actually
supperior to PosixACLs - still depend on the user's umask. I
understand the problems you have from a programmers point of view but
if I set a d:group:mask on a directory I expect that these permissions
get inherited on the client side, too - like it was with NFS3+ACL.

Don't understand me wrong: I don't want to flame here - I appritiate
your work and I love NFS as it is damn fast. I just want to show you
what an admin's expectation is. People who use PosixACLs are used to
inheritance (if they set a default group or mask), windows people are
used to it anyway and nobody would expect that when using NFS4 it all
comes down to the user's umask settings. Especially as it was already
working with NFS3. I know that NFS3+ACL is a totally different topic
then NFS4+ACL but many user's won't care - especially as they do not
have any advantage from NFS4ACLs as they are mapped to PosixACLs
anyway.

I really hate the security risks I have to take for NFS3 but in my
case I guess I have to revert the public shares back to NFS3. It would
be really great if you could think about implementing a umask
mount-option to allow enforced share based umask settings.


>> How do other people share public files with NFS4? If there is no other
>> way than setting the users's umask to 002, this would practically
>> limit the use of NFS4 to private shares like home directories.
>
> I don't understand why--can't you use the user-private-group trick?:

- umask setting can be overriden easily - see above
- we actually have directories where files should only be group readable.

Alex
