From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Thu, 27 Jul 2006 02:59:04 +0200
Message-ID: <200607270259.04405.agruen@suse.de>
References: <200607032310.15252.agruen@suse.de>
	<200607091822.44656.agruen@suse.de>
	<A15E619E-E88C-420C-AEC4-4E7409F187F3@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Cc: Sam Falkner <Sam.Falkner@sun.com>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@sun.com>,
	Brian Pawlowski <beepy@netapp.com>, nfsv4@ietf.org
Return-path: <nfsv4-bounces@ietf.org>
To: Lisa Week <Lisa.Week@sun.com>
In-Reply-To: <A15E619E-E88C-420C-AEC4-4E7409F187F3@Sun.COM>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

Lisa,

On Tuesday, 11. July 2006 08:50, Lisa Week wrote:
> POSIX defines Additional Access Control Mechanism as follows:
> "An implementation-defined mechanism that is layered upon the access
> control mechanisms defined here, but which do not grant permissions
> beyond those defined herein, although they may further restrict them."
>
> POSIX defines Alternate Access Control Mechanisms are as follows:
> "An implementation-defined mechanism that is independent of the
> access control mechanisms defined herein, and which if enabled on a
> file may either restrict or extend the permissions of a given user.
> IEEE Std 1003.1-2001 defines when such mechanisms can be enabled and
> when they are disabled."
>
> So, the question that comes to my mind when reading that text is:
> What does it mean when they say "access mechanisms defined herein" in
> both of those definitions?  Well, the access mechanisms defined in
> the POSIX spec are the "File Access Permissions", right?  So, can we
> agree that "access mechanisms defined herein" would be the "File
> Access Permissions"?

the "access mechanisms defined herein" refer to all file access control 
mechanisms that POSIX defines. This includes permissions always granted to 
the owner such as chmod, but also mechanisms such as the restricted deletion 
flag bit (S_ISVTX) for directories, etc.

Trust me, POSIX is very careful about wording, and if "access mechanisms 
defined herein" did indeed refer to the file access permissions, then POSIX 
would say exactly that.

> I give you this.  The wording about the classification of ACEs in
> draft-ietf-nfsv4-acls is not quite sufficient.  As I've said before,
> It makes some important assumptions, but isn't clear as to what those
> are. It doesn't map to what the algorithm specifies.  With that 
> said, it was not meant to be misleading in any way.

I never meant to imply bad intentions ;-)

> As documented in the algorithm definition in section 3.16.6.3 -
> "Applying a Mode to an Existing ACL" of the minor version doc, the
> following is a clarification of the classification:
>
> ALLOW ACEs with ACE4_READ_DATA/ACE4_LIST_DIRECTORY, ACE4_WRITE_DATA/
> ACE4_ADD_FILE, ACE4_APPEND_DATA/ACE4_ADD_SUBDIRECTORY, and
> ACE4_EXECUTE access mask bits are Alternate security mechanisms.
> These access mask bits will be disabled upon chmod.
>
> DENY ACEs with those access mask bits are Additional access control
> mechanisms.  These access mask bits will be left unchanged  after a
> chmod, unless, as described in 3.16.6.3 it is one of the special
> identifiers, OWNER@, GROUP@, EVERYONE@.

No, that's still messed up. We don't care about permissions that are not 
granted, so we *could* only look at ALLOW ACEs, but this distinction is not 
at all relevant.

What counts is which access mask flags are equivalent to the POSIX Read, 
Write, and Execute permissions, and which are not: those are the access mask 
flags which may (sometimes) be used as additional access control mechanisms.

The other issue is which POSIX file class each ACE maps to. Let's assume for 
now that we only know that OWNER@ maps to the File Owner Class to keep this 
example short.

Together with these two classifications, we can determine whether an ACE is 
within the bounds of an additional file access control mechanism. Let's look 
at the following ACE, and a file which has a file mode of 0740 (rwxr-----):

  OWNER@:READ_DATA/APPEND_DATA/EXECUTE::ALLOW

The OWNER@ ACE maps to the File Owner Class. This means that as an additional 
access control mechanism, the ACE may not grant more than Read, Write, and 
Execute. The READ_DATA access mask flag is equivalent to POSIX Read, the 
APPEND_DATA access mask flag is a subset of POSIX Write, and the EXECUTE 
access mask flag is equivalent to POSIX Execute, so we are fine.

Now, let's assume that the user does a chmod to mode 0640 (rw-r-----). The 
permissions of the File Owner Class now no longer cover the EXECUTE 
permission. There are two options to fix this problem:

 1. either accept that the ACE cannot be part of an additional file
    access control mechanism, or

 2. disable the EXECUTE access mask flag, either temporarily or
    permanently, which gets us back into the bounds of additional file
    access control mechanisms.

In case 1, the only choice that remains is that the ACE must be part of an 
alternate file access control mechanism (see more on that below). POSIX 
states that we must disable alternate file access control mechanisms upon 
chmod and for new files, and they must only be re-enabled per explicit user 
action. So the EXECUTE permission would be just gone until the user 
explicitly re-enables it (with something other than a chmod). This would 
render ACLs practically useless under POSIX.

In case 2, the ACE still remains within the bounds of additional file access 
control mechanisms. If we disable EXECUTE only temporarily, then a future 
chmod back to mode 0740 can simply re-enable EXECUTE, and we will not have 
lost anything. (Remember, chmod does not disable additional file access 
control mechanisms.) 

There are several possibilities how we can disable access mode flags 
temporarily:

 1. we could add an explicit DENY ACE before the ALLOW ACE that has
    the affected access mask flags disabled (this is the
    draft-ietf-nfsv4-acls-00 approach),

 2. we could declare that all access mask flags which go beyond
    the corresponding File Class are automatically disabled, or

 3. we could introduce file masks as I am proposing.

The file masks have the advantage that the user can easily manually enable 
more access mask flags in them. This would construe an explicit user action 
as per POSIX. So depending on which flags the user enables, that may amount 
to an additional or alternate file access control mechanism. POSIX is 
perfectly fine with that, even for enabling flags such as WRITE_OWNER. The 
only thing we must ensure is that alternate flags are disabled upon chmod as 
well as for new files.

> All other access mask bits listed below are outside of the access
> control mechanisms specified by POSIX and are therefore unclassified
> and unrestricted:
> ACE4_READ_NAMED_ATTRS
> ACE4_WRITE_NAMED_ATTRS
> ACE4_DELETE_CHILD
> ACE4_READ_ATTRIBUTES
> ACE4_WRITE_ATTRIBUTES
> ACE4_DELETE
> ACE4_READ_ACL
> ACE4_WRITE_ACL
> ACE4_WRITE_OWNER
> ACE4_SYNCHRONIZE
>
> This means that if an ACE defines one of those access mask bits, the
> access granted or denied will remain unchanged after a chmod.

I am afraid this is impossible: there is no such thing as being outside the 
file access control mechanisms defined by POSIX. The reason is simple: POSIX 
applications absolutely *must* be able to rely on POSIX semantics in order to 
be able to keep the system secure.

Let's assume that ACE4_WRITE_OWNER was indeed outside of the access control 
mechanisms defined by POSIX as a counter example. A POSIX application does a 
chmod to mode 0600 (rw-------) in order to restrict access to the file owner. 
After that, the application can perfectly well write information that is 
confidential to the owner into the file -- after all, only the owner will 
have access, right?

Well, not quite, because an ACL might still grant ACE4_WRITE_OWNER to some 
other user on the system. That other user could simply take over ownership of 
the file, and do whatever he wants with it. Here we have it, a perfect 
security hole; all POSIX applications potentially broken!

Therefore, there cannot be any file access control mechanisms which are 
neither defined by POSIX, nor additional or alternate.

By definition, pure POSIX applications have no idea which additional or 
alternate file access control mechanisms a particular POSIX implementation 
may define, so they cannot know about such sideband mechanisms, and they also 
have no way of disabling them.

Andreas

-- 
Andreas Gruenbacher <agruen@suse.de>
Novell / SUSE Labs

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
