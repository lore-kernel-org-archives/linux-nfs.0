From: Sam Falkner <Sam.Falkner@Sun.COM>
Subject: Re: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Mon, 10 Jul 2006 07:29:56 -0600
Message-ID: <B0F5507F-A317-44F7-B6A3-A5005542A631@Sun.COM>
References: <200607032310.15252.agruen@suse.de>
	<200607071355.30624.agruen@suse.de>
	<B2F139E8-41BB-4657-B6FD-6738331C57E1@Sun.COM>
	<200607091822.44656.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; delsp=yes; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, Spencer Shepler <spencer.shepler@Sun.COM>,
	Brian Pawlowski <beepy@netapp.com>, Lisa Week <Lisa.Week@Sun.COM>
Return-path: <nfsv4-bounces@ietf.org>
In-reply-to: <200607091822.44656.agruen@suse.de>
To: nfsv4@ietf.org
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Jul 9, 2006, at 10:22 AM, Andreas Gruenbacher wrote:

> On Saturday, 8. July 2006 05:45, Sam Falkner wrote:
>> On Jul 7, 2006, at 5:55 AM, Andreas Gruenbacher wrote:
>>> On Monday, 3. July 2006 23:10, Andreas Gruenbacher wrote:
>>>> Hello,
>>>>
>>>> I have been thinking about the problems of interaction between
>>>> NFSv4 ACLs and POSIX, and particularly about the issue of masking
>>>> permissions through chmod and after creating files or directories.
>>>
>>> Here is a follow-up after some personal feedback from Sam. I
>>> believe that draft-ietf-nfsv4-acls-00 is not ready to become part  
>>> of the
>>> NFSv4 Minor Version 1 RFC: some assumptions are not correct from  
>>> a POSIX
>>> point of view, and the way how chmod and file create modes are  
>>> applied to
>>> NFSv4 ACLs is weak and not guaranteed to be correct.
>>
>> I disagree -- see below.
>
> Here are some facts to back my points: Let's assume that a file  
> inherits the
> following ACL when being created (I am using ^(...) here with the  
> meaning of
> "all bitflags except ..."):
>
> 	OWNER@:READ_DATA/WRITE_DATA::ALLOW
> 	OWNER@:^(READ_DATA/WRITE_DATA)::DENY
> 	GROUP@:READ_DATA::ALLOW
> 	user@domain:READ_DATA/WRITE_DATA::ALLOW
> 	GROUP@:^READ_DATA::DENY
> 	user@domain:^(READ_DATA/WRITE_DATA)::DENY
> 	EVERYONE@:READ_DATA::ALLOW
>
> This acl is "well structured" in the POSIX sense: OWNER@ will only  
> get the
> owner permissions and none of the other permissions, user@domain  
> and GROUP@
> will only get the permissions intended for them, and only others  
> (neither
> OWNER@ nor user@domain nor GROUP@) will get EVERYONE@ permissions;  
> in other
> words, the acl is even correct for non-monotonic permissions.
>
> According to section 5.1 of draft-ietf-nfsv4-acls [1], the  
> resulting file mode
> permission bits for this acl shall be rw-r--r--.

Your proposal would give this mode: rw-rw-r--.  I think we should  
consider this more carefully.

> After a chmod or a file
> create, alternate file access control mechanisms must be disabled  
> and only
> additional file access control mechanisms may remain active.  
> According to
> POSIX, additional file access control mechanisms require that no  
> user may be
> granted more permissions than the respective file classes permit.  
> In this
> case, user@domain clearly is not in the File Owner Class.  
> (According to
> POSIX, user@domain must be in the File Group Class.) The  
> user@domain user is
> granted WRITE_DATA though, which is *incorrect* from a POSIX point  
> of view.

No, it is not granted WRITE_DATA after a chmod().  After a chmod 644,  
there will be a "user@domain:WRITE_DATA::DENY" prepended.  This is  
well defined in the current minorversion1.  So it is not "incorrect  
from a POSIX point of view."

If your problem is with the computation of the mode, then we can  
discuss this some more.  But following create or chmod, user@domain  
is not granted WRITE_DATA.

> Next, let's assume than an ACL contains the following pair of user- 
> provided
> entries:
>
> 	GROUP@:WRITE_DATA::DENY
> 	GROUP@:READ_DATA::ALLOW
>
> Clearly the user's intention is to deny WRITE_DATA access to GROUP@.

Yes, that *was* the user's intention, at the time the user set the ACL.

> The
> algorithm to apply a mode to an existing ACL will remove the  
> WRITE_DATA bit
> from the GROUP@:WRITE_DATA::DENY entry when a chmod(..., 0770) is done
> though. This is counter to the user's intention, so I would call  
> that *wrong*
> as well.

You would call it wrong that a chmod 770 would allow WRITE_DATA to  
members of the file's owning group?!  The  user did a chmod -- the  
user changed the permissions on the file!

This is not a POSIX flaw, and this is not a design flaw of any kind.   
"chmod 770" grants the owning group permission to write the file,  
period.

> It also violates the principle of least surprise.

Are you kidding?  Consider a directory with this ACE in its ACL:

GROUP@:READ_DATA/WRITE_DATA:FILE_INHERIT:DENY

With your proposal, open("foo", O_CREAT | O_RDWR, 0666) in this  
directory creates a file that the owning group is denied read and  
write permission.  Then:

% chmod 664 foo

Oops, owning group *still* cannot read or write the file!  Linux/*NIX  
has a long history of files having a mode attribute, and users using  
chmod to set permissions -- but not much history with NFSv4 ACLs.   
Your proposal more or less requires that Linux/*NIX users immediately  
start using ACLs, or face the "chmod doesn't fix my file" problem.

I've spent quite some time over the last few days looking for flaws  
in your proposal, but I'll admit that I missed this one, and it's a  
big one.

> There really is no
> safe way to tell user-provided ACL entries from artificially made  
> up ACL
> entries.

The semantics in draft-ietf-nfsv4-acls are well defined, predictable,  
consistent, and reasonable.

> draft-ietf-nfsv4-acls is missing a clear classification of ACL  
> entries into
> the File Owner, File Group, and File Other classes. Every ACL entry  
> must be
> in one of the three classes in order to compute appropriate file mode
> permission bits when setting an ACL, and after inheriting  
> permissions. This
> classification also determines which effect chmod will have on an ACL.

I assume you mean "every ACE", not "every ACL".  As I mentioned  
above, I'm not sure whether or not this is a requirement, but it can  
be discussed further.  However, if it turns out that draft-ietf-nfsv4- 
acls is wrong in this regard, then the only consequence is a minor  
change to 5.1.

> So draft-ietf-nfsv4-acls is *incorrect* and *wrong* from a POSIX  
> point of
> view, while my alternative proposal is correct, apart from being  
> simpler to
> implement. I hope that my emails and some background reading (like  
> the file
> access related parts of the POSIX definitions volume [5], a paper that
> explains POSIX ACLs and how they are implemented on Linux [6], and  
> perhaps
> 1003.1e draft 17) will convince you about that.

I am absolutely not convinced.

This email is getting *way* too long, so I will stop at this point,  
and perhaps will reply to other pieces in the future.

- Sam

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
