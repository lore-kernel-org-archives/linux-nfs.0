From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Tue, 1 Aug 2006 12:36:30 +0200
Message-ID: <200608011236.30477.agruen@suse.de>
References: <200607032310.15252.agruen@suse.de>
	<200607270259.04405.agruen@suse.de> <44C9AF9B.60807@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@ietf.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7rfZ-00015m-TN
	for nfs@lists.sourceforge.net; Tue, 01 Aug 2006 03:40:14 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G7rfY-0006NY-9Y
	for nfs@lists.sourceforge.net; Tue, 01 Aug 2006 03:40:14 -0700
To: Lisa Week <Lisa.Week@sun.com>
In-Reply-To: <44C9AF9B.60807@Sun.COM>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Friday 28 July 2006 08:32, Lisa Week wrote:
> >[...] We don't care about permissions that are not
> >granted, so we *could* only look at ALLOW ACEs, but this distinction is
> > not at all relevant.
>
> What?  I don't understand how you can say that "we don't care about
> permissions that are not granted".  We definitely care about permissions
> that are explicitly not granted.

What I mean is that when looking at which permissions go beyond additional 
file access control mechanisms, we don't need to consider DENY ACEs: DENY 
ACEs can only further restrict access, and so they are never alternate file 
access control mechanisms.

> Also, I believe it is relevant to make a distinction between ALLOW and
> DENY ACEs.  Here's why:
>
> The reasoning behind classifying those DENY ACEs as additional access
> control mechanisms are 1.) because they further restrict the permissions
> of users and groups (which is what additional does by definition) and
> 2.) we don't want them to have to be disabled upon chmod.  Try to think
> about it in a way that you have just set an explicit entry to deny
> certain permissions to a supplemental user or group.  It is important
> that those users or groups don't have their permissions elevated after
> chmod.

Yes.

> For example, if you have an ACL such as this:
>
> fred:READ_DATA/WRITE_DATA/APPEND_DATA/EXECUTE::DENY
> OWNER@:READ_DATA/WRITE_DATA/APPEND_DATA/EXECUTE::ALLOW
> GROUP@:READ_DATA/WRITE_DATA/APPEND_DATA/EXECUTE::ALLOW
> EVERYONE@:READ_DATA/WRITE_DATA/APPEND_DATA/EXECUTE::ALLOW
>
>
> The mode would be 777.  User fred is denied the ability to read, write
> and execute because of the explicit deny ACE.  After chmod, fred should
> still not be able to read, write and execute.  That is the goal that we
> were trying to meet.

Yes.

> I realize that the mapping that you describe in section 4.4 of
> http://www.suse.de/~agruen/nfs4acl/mapping-nfsv4-acls-to-posix-00.html
> would also give us the capabilities that  I have described above.

Yes.

---

> With that said, I will go on to describe the capabilities that I feel
> the mapping in section 4.4 lacks.  The capabilities that it lacks is
> where the relevance of having those ALLOW ACEs that I described before
> be considered Alternate access control mechanisms comes in.
>
> The mapping in section 4.4 makes it impossible to do the following by
> *only* modifying the ACL.
>
> The mode of the file is 644 and you want to give fred the ability to
> read, write and execute.
>
> fred:READ_DATA/WRITE_DATA/APPEND_DATA/EXECUTE::ALLOW
> OWNER@:READ_DATA/WRITE_DATA/APPEND_DATA::ALLOW
> OWNER@:EXECUTE::DENY
> GROUP@:READ_DATA::ALLOW
> GROUP@:WRITE_DATA/APPEND_DATA/EXECUTE::DENY
> EVERYONE@:READ_DATA::ALLOW
> EVERYONE@:WRITE_DATA/APPEND_DATA/EXECUTE::DENY
>
> With the classification in 4.4, you can set that ACL, but it won't take
> effect until you also explicitly modify the file group class permissions
> (via a mask or whatever).

In Section 4.6. "Setting File Permissions, File Masks, and ACLs", 
http://www.suse.de/~agruen/nfs4acl/mapping-nfsv4-acls-to-posix-00.html reads:

[] When an ACL is set, the file masks may or may not be set in the same
[] operation. If they are not set in the same operation, each file mask shall
[] implicitly be set to the union of the mask bits of all ACEs that are in
[] the corresponding file class according to Table 1.
[]
[] When a file mask is set, either explicitly or implicitly by setting an ACL,
[] all permissions that active file mask bits correspond to in Table 2 shall
[] be set, and all other permissions shall be cleared.

So setting only the ACL will implicitly modify the file mode permission bits 
as needed. It is important to keep the masks in sync with the ACL, and to 
keep the file permission bits in sync with the masks. Without this behavior, 
setting permissions with ACLs would indeed be painful.

> The capability to set the type of ACL that is above was the goal when
> classifying ALLOW ACEs as Alternate security access control mechanisms.
> We can do this because as Alternate is defined, it can extend the
> permissions of a user.  Therefore, setting the ACL attribute is all that
> is needed for this to take effect.

I agree with you that setting an ACL is an explicit user action, and that this 
action may enable an alternate file access control mechanism. Whether the new 
ACL actually is an alternate file access control mechanism depends on which 
permissions the ACL allows: if it only allows permissions that map to Read, 
Write, and Execute and the file classes include those permissions, then the 
ACL does not actually go beyond additional file access control mechanisms. 
Otherwise, the ACL is an alternate file access control mechanism, and the 
alternate parts of it must be disabled upon chmod.

> ---
>
> I am trying to figure out why there has been such a disagreement here
> and perhaps this is another thing that needs to be cleared up.  What
> does the disabling of an alternate access control mechanism mean?
> Certainly it is not that we have to get rid of everything that is in an
> ALLOW ACE every time a chmod is done.

Indeed, we only have to disable what goes beyond an additional file access 
control mechanism.

> If you had the following ACL:
>
> fred:READ_DATA/WRITE_DATA/APPEND_DATA/EXECUTE::ALLOW
> OWNER@:READ_DATA/WRITE_DATA/APPEND_DATA/EXECUTE::ALLOW
> GROUP@:READ_DATA/WRITE_DATA/APPEND_DATA/EXECUTE::ALLOW
> EVERYONE@:READ_DATA/WRITE_DATA/APPEND_DATA/EXECUTE::ALLOW
>
> The mode would be 777.  Disabling can be meant that after the chmod, the
> user "fred" should not have more permissions that his respective class.
> So, after a chmod to 770, fred should still be allowed the ability to
> read, write and execute.  This is in how the permissions for fred are
> disabled.  They are being masked down to what the permissions of the
> file group class are.

Yes, exactly.

> >What counts is which access mask flags are equivalent to the POSIX Read,
> >Write, and Execute permissions, and which are not: those are the access
> > mask flags which may (sometimes) be used as additional access control
> > mechanisms.
>
> What do you mean by sometimes.

Consider your example ACL from above, and a chmod to 0750. In that case, we 
need to disable WRITE_DATA and APPEND_DATA for Fred and GROUP@, and 
READ_DATA, WRITE_DATA, APPEND_DATA, and EXECUTE for EVERYONE@. So when the 
File Group Class contains the Write permission, WRITE_DATA and APPEND_DATA 
are perfectly fine as an additional file access control mechanism. Removing 
Write from the File Group Class causes WRITE_DATA and APPEND_DATA to become 
Alternate, and we must make sure to disable them.

In mapping-nfsv4-acls-to-posix-00, I said the same thing like this:

[] Flags classified as additional are equivalent to or a subset of the
[] designated POSIX permission. If the file class of an ACE (see Section 4.1)
[] includes this permission, the ACE may grant this permission as part of an
[] additional file access control mechanism.

> >The other issue is which POSIX file class each ACE maps to. Let's assume
> > for now that we only know that OWNER@ maps to the File Owner Class to
> > keep this example short.
> >
> >Together with these two classifications, we can determine whether an ACE
> > is within the bounds of an additional file access control mechanism.
> > Let's look at the following ACE, and a file which has a file mode of 0740
> > (rwxr-----):
> >
> >  OWNER@:READ_DATA/APPEND_DATA/EXECUTE::ALLOW
> >
> >
> >The OWNER@ ACE maps to the File Owner Class. This means that as an
> > additional access control mechanism, the ACE may not grant more than
> > Read, Write, and Execute. The READ_DATA access mask flag is equivalent to
> > POSIX Read, the APPEND_DATA access mask flag is a subset of POSIX Write,
> > and the EXECUTE access mask flag is equivalent to POSIX Execute, so we
> > are fine.
> >
> >Now, let's assume that the user does a chmod to mode 0640 (rw-r-----). The
> >permissions of the File Owner Class now no longer cover the EXECUTE
> >permission. There are two options to fix this problem:
> >
> > 1. either accept that the ACE cannot be part of an additional file
> >    access control mechanism, or
> >
> > 2. disable the EXECUTE access mask flag, either temporarily or
> >    permanently, which gets us back into the bounds of additional file
> >    access control mechanisms.
> >
> >In case 1, the only choice that remains is that the ACE must be part of an
> >alternate file access control mechanism (see more on that below). POSIX
> >states that we must disable alternate file access control mechanisms upon
> >chmod and for new files, and they must only be re-enabled per explicit
> > user action. So the EXECUTE permission would be just gone until the user
> > explicitly re-enables it (with something other than a chmod). This would
> > render ACLs practically useless under POSIX.
>
> Why wouldn't the EXECUTE permission be able to be re-enabled with
> chmod?  Of course, it can.

Chmod must disable alternate file access control mechanisms as per the POSIX 
definitions, and so if we classified EXECUTE as alternate, a chmod could not 
re-enable it.

> If you are setting a mode of 740, that says that the owner can execute.

Yes. More precisely, it says the owner may be allowed to execute; additional 
file access control mechanisms may further restrict access, and deny the 
owner that permission.

> That is an explicit action and EXECUTE permission should be granted to the
> owner.

Ouch. Setting the mode to 740 is a chmod, right? Chmod is the one explicit 
action for which POSIX defines that it must disable alternate file access 
control mechanisms. The other explicit action that POSIX mentions is file 
creation, for which alternate file access control mechanisms must also be 
disabled. So please let's not mix things up here, and let's refrain from 
calling chmod an explicit action in this context.

> >In case 2, the ACE still remains within the bounds of additional file
> > access control mechanisms. If we disable EXECUTE only temporarily, then a
> > future chmod back to mode 0740 can simply re-enable EXECUTE, and we will
> > not have lost anything. (Remember, chmod does not disable additional file
> > access control mechanisms.)
> >
> >There are several possibilities how we can disable access mode flags
> >temporarily:
> >
> > 1. we could add an explicit DENY ACE before the ALLOW ACE that has
> >    the affected access mask flags disabled (this is the
> >    draft-ietf-nfsv4-acls-00 approach),
> >
> > 2. we could declare that all access mask flags which go beyond
> >    the corresponding File Class are automatically disabled, or
> >
> > 3. we could introduce file masks as I am proposing.
> >
> >The file masks have the advantage that the user can easily manually enable
> >more access mask flags in them. This would construe an explicit user
> > action as per POSIX. So depending on which flags the user enables, that
> > may amount to an additional or alternate file access control mechanism.
> > POSIX is perfectly fine with that, even for enabling flags such as
> > WRITE_OWNER. The only thing we must ensure is that alternate flags are
> > disabled upon chmod as well as for new files.
> >
> >>All other access mask bits listed below are outside of the access
> >>control mechanisms specified by POSIX and are therefore unclassified
> >>and unrestricted:
> >>ACE4_READ_NAMED_ATTRS
> >>ACE4_WRITE_NAMED_ATTRS
> >>ACE4_DELETE_CHILD
> >>ACE4_READ_ATTRIBUTES
> >>ACE4_WRITE_ATTRIBUTES
> >>ACE4_DELETE
> >>ACE4_READ_ACL
> >>ACE4_WRITE_ACL
> >>ACE4_WRITE_OWNER
> >>ACE4_SYNCHRONIZE
> >>
> >>This means that if an ACE defines one of those access mask bits, the
> >>access granted or denied will remain unchanged after a chmod.
> >
> >I am afraid this is impossible: there is no such thing as being outside
> > the file access control mechanisms defined by POSIX. The reason is
> > simple: POSIX applications absolutely *must* be able to rely on POSIX
> > semantics in order to be able to keep the system secure.
> >
> >Let's assume that ACE4_WRITE_OWNER was indeed outside of the access
> > control mechanisms defined by POSIX as a counter example. A POSIX
> > application does a chmod to mode 0600 (rw-------) in order to restrict
> > access to the file owner. After that, the application can perfectly well
> > write information that is confidential to the owner into the file --
> > after all, only the owner will have access, right?
> >
> >
> >Well, not quite, because an ACL might still grant ACE4_WRITE_OWNER to some
> >other user on the system. That other user could simply take over ownership
> > of the file, and do whatever he wants with it. Here we have it, a perfect
> > security hole; all POSIX applications potentially broken!
>
> The owner of the file had taken *explicit* action to grant ACE4_WRITE_OWNER
> to another user on the system. 

The owner takes explicit action to grant ACE4_WRITE_OWNER to another user on 
the system, which is beyond what POSIX defines. Then a POSIX process on 
behalf of the owner (or an admin) does a chmod to 0600. From all the POSIX 
process knows, the file can now only be accessed by the owner; there is 
nothing that keeps POSIX processes from making this assumption. To the POSIX 
process, chmod is a mechanism to enforce restricted access. Now if we let 
ACE4_WRITE_OWNER survive the chmod, we break this basic assumption, and 
nothing will guarantee that the intentions of the file owner combined with 
the valid assumptions of POSIX processes will lead to a secure system.

> You say that it is a security hole if the user that was explicitly granted
> the ability to write owner is now able to do what they were told they could
> do?

If that permission was granted by explicit user action without intervening 
chmod, no. After chmod, yes. It is not enough to look at the intentions of 
the file owner alone. We must also look at interactions with other actors 
that may have incomplete knowledge and different assumptions.

Andreas

-- 
Andreas Gruenbacher <agruen@suse.de>
Novell / SUSE Labs

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
