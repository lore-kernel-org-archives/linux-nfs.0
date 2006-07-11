From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Tue, 11 Jul 2006 10:05:21 +0200
Message-ID: <200607111005.22200.agruen@suse.de>
References: <200607032310.15252.agruen@suse.de>
	<200607110215.53496.agruen@suse.de>
	<3E4B637E-57AC-4E2B-A2C8-EDCFF35A5D84@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Lisa Week <Lisa.Week@sun.com>, nfsv4@ietf.org,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@sun.com>,
	Brian Pawlowski <beepy@netapp.com>
Return-path: <nfsv4-bounces@ietf.org>
To: Sam Falkner <Sam.Falkner@sun.com>
In-Reply-To: <3E4B637E-57AC-4E2B-A2C8-EDCFF35A5D84@Sun.COM>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Tuesday, 11. July 2006 07:42, Sam Falkner wrote:
> >> I think having chmod be functional, i.e. chmod 770 gives write
> >> permission to the owning group, and an "ls -l" shows "rwxrwx---",
> >> would be best by far.
> >
> > It screws you when you want to give the owning group fewer permissions
> > than other users in the File Group Class. This can be worked around by
> > creating a dummy group with no members, or one group that only contains
> > a single user for each user, and changing the owning group of files, but
> > the owning group already has other defined uses in POSIX (think of SETG=
ID
> > for files and directories), and so it's not desirable and not always
> > possible to change the owning group to such a dummy group.
>
> No -- if you want owning group to have fewer permissions than other
> users, you're using an ACL.  You use tools that manipulate ACLs.

Sorry, but while this may look like a good idea at first, it doesn't work v=
ery=20
well. Let's look at an example:

	OWNER@:READ_DATA/WRITE_DATA::ALLOW
	GROUP@:READ_DATA/WRITE_DATA::ALLOW
	user@domain:READ_DATA/WRITE_DATA::ALLOW
	EVERYONE:READ_DATA::ALLOW

The mode is rw-rw-r--. Now we use ACL tools to change the ACL to give the=20
owning group fewer permissions than user@domain as you say:

	OWNER@:READ_DATA/WRITE_DATA::ALLOW
	GROUP@:READ_DATA::ALLOW
	user@domain:READ_DATA/WRITE_DATA::ALLOW
	EVERYONE:READ_DATA::ALLOW

The mode must still be rw-rw-r-- because otherwise, user@domain wouldn't ha=
ve=20
WRITE_DATA access. Now a nasty, evil POSIX application that doesn't know=20
anything about ACLs comes along and does a chmod(file, 0600), chmod(file,=20
0664). What should be the appropriate result? If changing the group file mo=
de=20
permission bits writes through to the GROUP@ entry as you say, then we woul=
d=20
end up with the following *effective* permissions:

	OWNER@:READ_DATA/WRITE_DATA::ALLOW
	GROUP@:READ_DATA/WRITE_DATA::ALLOW
	user@domain:READ_DATA/WRITE_DATA::ALLOW
	EVERYONE:READ_DATA::ALLOW

(The effective permissions are the same no matter how permissions are maske=
d=20
in the ACL, be it via DENY ACEs or via masks. In the case of DENY ACEs, the=
=20
ACL would contain DENY entries, but those wouldn't mask any permissions in=
=20
this case. The example is slightly more difficult to think through with DEN=
Y=20
ACEs because they contain some redudancy and potential for inconsistencies,=
=20
but the result is the same.)

=46rom the POSIX application's point of view, the file has the same permiss=
ions=20
before and after the chmod. The POSIX application cannot be held guilty;=20
after all it doesn't know about ACLs by definition. Yet the acl actually=20
grants more permissions after the chmods, and the change we did to give the=
=20
owning group fewer permissions with ACL tools is lost. This can be quite=20
serious.

We can play the same example with MAY_WRITE vs. MAY_APPEND: if the group fi=
le=20
mode permission bits write through to the owning group permissions, a POSIX=
=20
chmod may convert a MAY_APPEND owning group ACE into a MAY_WRITE owning gro=
up=20
ACE.

> Solaris' POSIX-draft ACLs have the property that chmod works (i.e.
> you can set group permissions), and you use setfacl if you want to
> change other entries. It's perfectly easy to have owning group have=20
> fewer permissions than supplimental users.

That's a bug, and draft 17 of POSIX 1003.1e (withdrawn) has this bug fixed.

> The bottom line is that chmod must set the mode, rather than "set the
> mode, unless there's some sort of ACL thingy, in which case the group
> bits aren't the group bits but are instead the mask bits".

We may be misunderstanding here: I agree that chmod must set the file mode=
=20
(permission bits as well as special bits). The point is that the group file=
=20
mode permission bits can no longer be the same as the owning group=20
permissions with ACLs, or else innocent POSIX applications may cause=20
unintended side effects as in the example.

Andreas

=2D-=20
Andreas Gruenbacher <agruen@suse.de>
Novell / SUSE Labs

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
