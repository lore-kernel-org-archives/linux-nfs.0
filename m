From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: NFS4 ACL <-> Posix ACL
Date: Tue, 24 Mar 2009 17:44:07 -0400
Message-ID: <1237931047.7516.15.camel@heimdal.trondhjem.org>
References: <7f62dcb30903181042n42bae0bbk99f5c91fce6e9e82@mail.gmail.com>
	 <20090319193514.GE3072@fieldses.org>
	 <7f62dcb30903230646u183c79e0i4366edebe32654d5@mail.gmail.com>
	 <20090323213304.GG1067@fieldses.org>
	 <7f62dcb30903231856h7a17cea5ud7a22796ddfb6383@mail.gmail.com>
	 <20090324201002.GF19389@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alex Bremer <albremer@googlemail.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22337 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755544AbZCXVou (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Mar 2009 17:44:50 -0400
In-Reply-To: <20090324201002.GF19389@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-03-24 at 16:10 -0400, J. Bruce Fields wrote:
> On Tue, Mar 24, 2009 at 02:56:25AM +0100, Alex Bremer wrote:
> > 2009/3/23, J. Bruce Fields <bfields@fieldses.org>:
> > >> So is there any way to make newly created files group writeable except
> > >> for setting the umask of each user to 002?
> > >
> > > I think that's the only option.
> > >
> > > And that looks hard to fix; if we were going to implement the same
> > > "inheritance overrides umask" exception as we do for posix acls, either:
> > >
> > > 	- The server would have to know about the umask; this would
> > > 	  require a protocol change.  (But it might not be that hard;
> > > 	  you could have a write-only "set the mode to this, but only in
> > > 	  the absence of inheritance" attribute.)
> > > 	- The client would have to do the inheritance itself, as it does
> > > 	  with posix acls.  This is perhaps not impossible, but it's
> > > 	  much more complicated with v4 acls.
> > >
> > > Hm.  Another odd option: do the open with the create mode + umask, as we
> > > currently do, then do a subsequent setattr to the create mode if the
> > > create mode is more generous and if the client detects inheritable acls
> > > on the parent directory.
> > 
> > Why so complicated? Of course these options would be the nicest way to
> > do it as it allows to set different permission inheritances on each
> > directory. However for many use cases it would be enough if one could
> > set the permissions on a share basis. A simple umask mount-option
> > would already help a lot. This way administrators could enforce a
> > umask on a share.
> 
> I don't know what to think of a umask mount option.  That's a question
> for Trond.

Ugh, no. We already have too many mount options, and this suggestion
doesn't even fix any problems.

The correct thing to do is to check for acl support on the server, and
then check directories for inheritance aces before we decide to create a
file.
The existing 'noacl' mount option could then turn off this type of check
in cases where the administrator doesn't care to follow inheritance
rules...

> > One of the problems with setting a global umask on a user basis is
> > that it can be override very easily. If a user doesn't like the fact
> > that all files are group writeable he can easily change it and then he
> > usually forgets to set write-permissions manually when writing public
> > files. As a consequence other users who want to write that file come
> > to me to have the permissions reset as they can not even tell who is
> > the owner of the file and ask him. :-)
> > 
> > >> Setting the umask to 002 is
> > >> not an option for us, but all files in the public area have to be
> > >> group writeable. Is there maybe a mount option to set the umask or a
> > >> server sided option which enforces the group writeable flag?
> > >>
> > >> I would expect that my use case is not that uncommon and that many
> > >> companys have the exact same problem. Would the inheritance work if we
> > >> used a fully NFS4-ACL compatible filesystem?
> > >
> > > No, and I suspect non-linux servers all have similar behavior in this
> > > respect.
> > 
> > Unix servery yes, but on windows using NTFS you can inherit permissions.
> > 
> > With PosixACLs Unix finally got permission inheritance too and this is
> > a blessing for administrators. The normal unix filesystem permissions
> > are good enough for many use cases but in a company with many users
> > and many different groups they do not fit. The simple case of allowing
> > users of two different groups access to a directory without giving
> > others rx access forces you to create a third group with all the users
> > of both groups. Adding new users gets a pain in the ass as you have to
> > add them to more and more groups just to get the permissions right.
> > 
> > So Posix ACLs are really great for admins. From an admin's point of
> > view I can't understand why the NFS4-ACLs - which are actually
> > supperior to PosixACLs - still depend on the user's umask. I
> > understand the problems you have from a programmers point of view but
> > if I set a d:group:mask on a directory I expect that these permissions
> > get inherited on the client side, too - like it was with NFS3+ACL.
> > 
> > Don't understand me wrong: I don't want to flame here - I appritiate
> > your work and I love NFS as it is damn fast. I just want to show you
> > what an admin's expectation is. People who use PosixACLs are used to
> > inheritance (if they set a default group or mask), windows people are
> > used to it anyway and nobody would expect that when using NFS4 it all
> > comes down to the user's umask settings. Especially as it was already
> > working with NFS3. I know that NFS3+ACL is a totally different topic
> > then NFS4+ACL but many user's won't care - especially as they do not
> > have any advantage from NFS4ACLs as they are mapped to PosixACLs
> > anyway.
> 
> I appreciate the problem--if nothing else this is a subtle change that
> other admins will also hit, and that will be hard for them to diagnose.
> 
> I just don't see a really good solution.
> 
> > I really hate the security risks I have to take for NFS3
>  
> Are you aware that rpcsec_gss/krb5 still works for v3?
> 
> There are a few holes left (sideband protocols, notably mount, still use
> auth_sys), but it might be enough for your purposes.
> 
> > but in my
> > case I guess I have to revert the public shares back to NFS3. It would
> > be really great if you could think about implementing a umask
> > mount-option to allow enforced share based umask settings.
> > 
> > 
> > >> How do other people share public files with NFS4? If there is no other
> > >> way than setting the users's umask to 002, this would practically
> > >> limit the use of NFS4 to private shares like home directories.
> > >
> > > I don't understand why--can't you use the user-private-group trick?:
> > 
> > - umask setting can be overriden easily - see above
> 
> I'm surprised people fool with their umasks that much, but OK.
> 
> > - we actually have directories where files should only be group readable.
> 
> I don't get it--why not set an inheritable acl on those directories that
> permits only read to the group?

That only works if the client actually respects the acl...

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
