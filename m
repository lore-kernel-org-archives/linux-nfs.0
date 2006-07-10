From: Sam Falkner <Sam.Falkner@Sun.COM>
Subject: Re: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Mon, 10 Jul 2006 09:32:28 -0600
Message-ID: <1A2FAFA9-0B94-48FA-8B0B-2A8AC0BE0331@Sun.COM>
References: <200607032310.15252.agruen@suse.de>
	<200607071355.30624.agruen@suse.de>
	<B2F139E8-41BB-4657-B6FD-6738331C57E1@Sun.COM>
	<200607091822.44656.agruen@suse.de>
	<B0F5507F-A317-44F7-B6A3-A5005542A631@Sun.COM>
	<20060710141541.GA978@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; delsp=yes; charset=US-ASCII
Cc: Brian Pawlowski <beepy@netapp.com>,
	Spencer Shepler <spencer.shepler@Sun.COM>,
	nfs@lists.sourceforge.net, nfsv4@ietf.org, Lisa Week <Lisa.Week@Sun.COM>
Return-path: <nfsv4-bounces@ietf.org>
In-reply-to: <20060710141541.GA978@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>


On Jul 10, 2006, at 8:15 AM, J. Bruce Fields wrote:

> On Mon, Jul 10, 2006 at 07:29:56AM -0600, Sam Falkner wrote:
>> On Jul 9, 2006, at 10:22 AM, Andreas Gruenbacher wrote:
>>> According to section 5.1 of draft-ietf-nfsv4-acls [1], the
>>> resulting file mode
>>> permission bits for this acl shall be rw-r--r--.
>>
>> Your proposal would give this mode: rw-rw-r--.  I think we should
>> consider this more carefully.
>
> As Andreas says, this is what the posix draft would have you do.  It's
> also what Linux (and, I assume, Solaris) do in the case of posix ACLs.

Not on Solaris.  With POSIX-draft ACLs, adding user:friend:rw- to a  
mode rw-r--r-- file still gives you rw-r--r--.  (And as you point out  
later, these ACLs ain't POSIX.)

> If the goals was compatibility with that posix draft, RFC3530 should
> have specified that owner, other, and group bits be kept in sync with
> (respectively) OWNER@, EVERYONE@, and the *maximum* of permissions  
> given
> to any other entity, rather than with OWNER@, EVERYONE@, and GROUP@.
>
>> You would call it wrong that a chmod 770 would allow WRITE_DATA to
>> members of the file's owning group?!  The  user did a chmod -- the
>> user changed the permissions on the file!
>
> That is how posix acl's work; again, the group mode bit really
> corresponds to the mask, not to the group acl entry:
>
> 	bfields@pickle:~$ getfacl foo
> 	# file: foo
> 	# owner: bfields
> 	# group: bfields
> 	user::rw-
> 	user:bfields:r--
> 	group::r--
> 	mask::r--
> 	other::---
>
> 	bfields@pickle:~$ chmod 770 foo
> 	bfields@pickle:~$ getfacl foo
> 	# file: foo
> 	# owner: bfields
> 	# group: bfields
> 	user::rwx
> 	user:bfields:r--
> 	group::r--
> 	mask::rwx
> 	other::---

Again, not so on Solaris.  I wasn't aware that it was on Linux.  Sigh.

> Of course, "posix" acls aren't really posix, and we could do something
> else if seems simpler.  Neither behavior seems intuitive to me in all
> situations.

I think having chmod be functional, i.e. chmod 770 gives write  
permission to the owning group, and an "ls -l" shows "rwxrwx---",  
would be best by far.

- Sam

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
