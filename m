From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [PATCH] Add `no_acl' nfs export option
Date: 21 Jul 2003 17:38:30 +0200
Sender: linux-fsdevel-owner@vger.kernel.org
Message-ID: <1058801910.22199.20.camel@chaos.suse.de>
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
problem is the following (quoted from
http://acl.bestbits.at/problems.html).


> Version 2 of the NFS protocol (NFSv2) does not implement the ACCESS remote procedure call, and instead performs some access control decisions at the client machine based on the file mode permission bits. It grants the user access to cached files if it thinks access is granted be the file mode permission bits. This logic is no longer correct if access control lists are in effect; both false positives and denials might result.
> 
> Write access is not affected, as all writes are authenticated on the
> server in all cases. As a workaround to this problem the ACL patch
> adds the nfs_permission_mode parameter to the kernel NFS daemon. If
> nfs_permission_mode is set to 0 (the default setting), file mode
> permission bits are sent to clients unchanged. If nfs_permission_mode
> is set to 1, file mode permission bits are modified so that clients
> are never granted read access to files to which they do not have
> access on the server. See the acl(5) manual page for details.


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
> 
> Can you tell me concisely but precisely, possibly in the form of a
> manpage entry,
>   What is the cost of always using no_acl?
>   What is the cost of never using no_acl?
>   How do I determine which cost is greater in a given situation?
> 
> It would really like it if the option could be avoided altogether.
> e.g. default to assume "no_acl" but switch to "acl" for a given client
> for v3 access if an ACCESS request is seen, and for v2 access if a
> zero byte READ or WRITE is seen.  Would that even come close to
> working?
> 
> NeilBrown
> 

