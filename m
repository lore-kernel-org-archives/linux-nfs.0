From: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
Subject: RE: nfs permissions / access problem
Date: Tue, 13 Aug 2002 12:42:51 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B9160C76A8@poexmb3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nl@lippman.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail2.conoco.com ([12.31.208.227])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17efh2-0002o3-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 10:42:56 -0700
To: <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>




> Message: 4
> From: Neal Lippman <nl@lippman.org>
> Reply-To: nl@lippman.org
> To: nfs@lists.sourceforge.net
> Date: Tue, 13 Aug 2002 10:38:08 -0400
> Subject: [NFS] nfs permissions / access problem
>=20
> I am hoping someone can provide some advice. The situation is that I =
want to=20
> have available on my nfs server a share that is accessible to a group =
of=20
> people connecting from their workstations, but am having trouble doing =
so.
>=20
> Following what I would have done for a local directory, I created the=20
> directory: /shared and set its ownship to root, with =
group=3Dsharedgroup, and=20
> then gave group permissions of rwx. I made sure each user who needs to =
use=20
> the shared directory is in the sharedgroup on the server, and for good =

> measure also did so on each workstation (and yes, the gid's are the =
same on=20
> each machine). Unfortunately, the directory remains inaccessible via =
nfs with=20
> this scheme.
>=20
	Comment #1: The uid/gid on the server does not matter, it is not =
necessary for
	a user to even exist on the server, the gid/uid must exist on the =
client as
	this is all that actually matters, and the permissions to the given =
directory
	must allow said user to put a file in the directory in question.  In =
NFS the server
	basically trusts that the user on the client is who they say they are.

	You were able to mount the disk on the clients correct?   And you did =
have
	the users (on the clients) logout after adding a new group to their =
username on
	the workstation?=20
	=20
	You will only get the groups that you had during your initial login, =
new groups=20
	added later are not going to be used until a logout/login.    The =
groups=20
	command will report that you are a member of the new group, but without =
a=20
	logout/login it is wrong.  Groups does not check to see what gid's the =
user
	has, it checks to see what groups you would have if you currently =
logged in.
	From alot of what you have said, I think you have a unclear =
understanding of=20
	exactly how NFS works (and most other network file systems).

	I would also suggest since you are going to all of the trouble of =
maintaining
	separate password/group files that you investigate NIS or something =
similar,
	as this simplifies things, and makes everything at lot less work.

> I suspect the problem here is that nfs receives from the client the =
uid and=20
> gid that the client process is currently executing under, but does not =

> received the extended group list, and also does not look up that =
user's=20
> extended group list on the server but rather just does permission =
checking=20
> with the single active uid and gid it received from the client, and so =
cannot=20
> access via extended group information.
>=20
	No lookup is ever done on the server for gid/uid on any implementation =
of=20
	NFS I know of, the listed uid/gid is compared to the permissions on the =

	directory.

> That doesn't strike me as the best way for nfs to operate, although I =
am am=20
> sure there was sound design decision involved (maybe overhead of =
looking up=20
> the groups on each access, which the os does not have locally as that =
info is=20
> already in the process's state information, placed there at login).
>=20
	This is because you don't understand exactly how nfs is used, it works
	exactly like the normal unix file permission setup, doing anything else =

	would make it inconsistant with the way unix file permissions work.

> In any case, it means that I cannot easily export a shared directory =
in this=20
> fashion.
>=20
	As you describe things it should work, if everything is done correctly.

> So my question is: How do I make an exported folder accessible to a =
group of=20
> users?
>=20
> Thanks.
> nl
>=20


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
