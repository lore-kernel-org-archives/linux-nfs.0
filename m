From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [PATCH] Add `no_acl' nfs export option
Date: 21 Jul 2003 18:33:03 +0200
Sender: linux-fsdevel-owner@vger.kernel.org
Message-ID: <1058805183.22199.78.camel@chaos.suse.de>
References: <200307081655.17510.agruen@suse.de>
	 <200307141309.44623.agruen@suse.de>
	 <16147.14612.324419.294401@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org,
	Steve Dickson <SteveD@redhat.com>,
	=?ISO-8859-1?Q?R=FCdiger?= Oertl <ro@suse.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16147.14612.324419.294401@gargle.gargle.HOWL>
List-ID: <nfs.lists.sourceforge.net>

Hello Neil,

(After switching mail clients I typed the wrong key and sent off the message
 accidentally before -- sorry.)

On Tue, 2003-07-15 at 01:13, Neil Brown wrote:
> On Monday July 14, agruen@suse.de wrote:
> > Hello,
> > 
> > I noticed that the bit I wanted is already reserved in nfs-utils-1.0.4. Here 
> > is an updated nfs-utils patch. I am also attaching a patch against 
> > linux-2.6.0-test1.
> > 
> > Could someone please reserve the bit? Thanks.
> 
> I'll definately reserve the bit, but I'm not very comfortable about
> this concept.
> My problem is that it doesn't seem clear how a sysadmin would decide
> how to set this bit.  It is not clear, at least from the manpage
> entry, exactly what the costs/benefits are of each setting, or how to
> find out whether given clients need a particular setting.

You are right, this setting isn't particularly clear. The underlying
problem is the following (parts quoted from
http://acl.bestbits.at/problems.html):

With POSIX ACLs, the group class file mode permission bits (i.e., the three
middle file mode permission bits) change their meaning. They no longer stand
for the owning group permissions, but for the mask ACL entry. The mask entry
defines the maximum permissions any user or group other than the owner or
others will have. The owning group may have fewer permissions than those that
are in the mask entry.

[] Version 2 of the NFS protocol (NFSv2) does not implement the ACCESS remote
[] procedure call, and instead performs some access control decisions at the
[] client machine based on the file mode permission bits. It grants the user
[] access to cached files if it thinks access is granted be the file mode
[] permission bits. This logic is no longer correct if access control lists
[] are in effect; both false positives and denials might result.

More precisely, NFSv2 clients and NFSv3 clients that don't use the ACCESS RPC
will wrongly grant access to file contents if all of the following is true:

 * The file contents are cached locally. (If they are not, the client will try
   to fetch them from the server, and will be denied access).
 * The user accessing the file is not the file owner, but is a member in the
   owning group.
 * The file has an extended ACL (i.e., its ACL differs from the base POSIX
   permissions).
 * The mask entry contains the requested permissions, but the owning group ACL
   entry does not contain all of those permissions.


False negatives will occur if all of this is true:

 * The file contents are cached locally.
 * The user accessing the file is not the file owner, and is not member in
   the owning group, but is a member in an additional ACL named user or
   named group ACL entry that would allow the access.
 * The other class file permission bits deny the access.


An even more bizarre case of fals epositives is this:

 * The file contents are cached locally.
 * The user accessing the file is not the file owner, and is not member in
   the owning group, but is a member in an additional ACL named user or
   named group ACL entry that would deny the access.
 * The other class file permission bits allow the access.


All those cases are sufficiently unlikely that they don't usually occur.
People who want to use ACLs are expected to upgrade their clients
as well. People who don't enable ACLs on their servers are unaffected.

Clients that are only used by a single user are unaffected: They will never cache
data to which this single user has no access.

[] Write access is not affected, as all writes are authenticated on the
[] server in all cases. As a workaround to this problem the ACL patch
[] adds [the `no_acl' export option] to the kernel nfs daemon. If
[] [`no_acl' is not specified] (the default setting), file mode
[] permission bits are sent to clients unchanged. If [`no_acl is specified],
[]  mode permission bits are modified so that clients
[] are never granted read access to files to which they do not have
[] access on the server.


> Also, the manpage entry says in part:
> 
> >    The
> > +.I no_acl
> > +option should be used for nfs exports with acl support that are exported
> > +to NFSv2 clients, or to NFSv3 clients that don't use the ACCESS RPC.
> 
> Surely the nfs server can detect itself if a filesystem supports ACLs,
> and if a given request is arriving via NFSv2 or not, so it should be
> able to assume "no_acl" in that case.
> 
> However this is actually a bit simplistic.  I think some NFSv2
> clients, solaris in particular, does not depend on the mode but
> performs zero-byte read and write requests to perform an equivalent
> function to ACCESS.

Correct.

> Can you tell me concisely but precisely, possibly in the form of a
> manpage entry,
>   What is the cost of always using no_acl?

The no_acl option is implemented by retrieving and scanning the ACL of a file,
and by masking all permissions that could lead to false positives. This is done
for all NFS RPCs that return a file mode, so enabling this option is rather
expensive.

Apart from that, ACL aware clients ought to receive the file mode permission
bits unchanged instead of masked. For them, the masked permissions are actually
incorrect.

>   What is the cost of never using no_acl?

Without `no_acl', the above pathological situations can occur.

>   How do I determine which cost is greater in a given situation?


> It would really like it if the option could be avoided altogether.
> e.g. default to assume "no_acl" but switch to "acl" for a given client
> for v3 access if an ACCESS request is seen, and for v2 access if a
> zero byte READ or WRITE is seen.  Would that even come close to
> working?

It probably would, but strange effects would occur until the server learns who
is who. A list of known clients would have to be cached. Unless that list is
made persistent, the learning phase would reoccur after server crashes. While
the server doesn't know a client yet, the client would receive the wrong
permissions, which it might cache for several seconds. The client cache would
have to be secured against denial-of-service attacks (cache size).
All in all, auto-detection doesn't seem like a very good idea to me.


I will think about a better man page entry, and send you an improved version
tomorrow.


Cheers,
Andreas.


