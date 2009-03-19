From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS4 ACL <-> Posix ACL
Date: Thu, 19 Mar 2009 15:35:14 -0400
Message-ID: <20090319193514.GE3072@fieldses.org>
References: <7f62dcb30903181042n42bae0bbk99f5c91fce6e9e82@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Alex Bremer <albremer@googlemail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:46078 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752958AbZCSTfS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Mar 2009 15:35:18 -0400
In-Reply-To: <7f62dcb30903181042n42bae0bbk99f5c91fce6e9e82-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 18, 2009 at 06:42:10PM +0100, Alex Bremer wrote:
> Hello,
> 
> I have a working NFS4 installation (kerberos + ldap) but some trouble
> understanding all these ACL mappings. On my server (ubuntu 8.04) the
> ext3 filesystems are mounted with the "acl" option and setting Posix
> ACLs works quite well.
> 
> On the client side (ubuntu 8.10) my libacl seems to lack NFSv4 ACL
> support and therefore I can't see the acl list. However I installed
> nfs4 acl tools and now I can see the ACL permissions of a
> file/directory.
> 
> Using Posix ACLs on the server I added a default mask so that newly
> created files/directories in the public area are group-writeable. This
> works quite well on the server and this used to work with NFS3 (which
> supports POSIX ACLs) on the client side, too. However on a client
> using NFS4, these Posix-ACLs don't seem to get mapped to NFS4-ACLs.

Actually, they do; what's happening (I believe--this is partly just
memory based on last time I looked at something like this) is more
subtle: the umask is being overridden by inheritance in the v2/v3 case,
and not in the v4 case.

Posix default acls are supposed to override the umask.  This is tricky
for NFS, since the umask isn't sent over the wire on file creation,
leaving the client and server no way to distinguish the create mode from
the umask.  The v2/v3 client currently works around this by doing the
whole inheritance calculation on the client (reading the directory's
acl, then explicitly setting the new child's acl based on it).  The v4
client doesn't do that.  So:

> Here are the ACLs:
> -----------------
> server> getfacl test/
> 
> user::rwx
> group::rwx
> other::---
> default:user::rwx
> default:group::rwx
> default:other::---
> 
> server> touch test/tmp
> server> ls -l test/tmp
> -rw-rw---- 1 albremer domusers 0 2009-03-18 18:32 test/tmp
> ---------------
> client> nfs4_getfacl test/
> 
> A::OWNER@:rwaDxtTcCy
> A::GROUP@:rwaDxtcy
> A::EVERYONE@:tcy
> A:fdi:OWNER@:rwaDxtTcCy
> A:fdi:GROUP@:rwaDxtcy
> A:fdi:EVERYONE@:tcy
> 
> client> touch test/tmp
> client> ls -l test/tmp
> -rw-r----- 1 albremer domusers 0 2009-03-18 18:32 test/tmp
> ---------------

If you do a getfacl on the server you'll probably see that it looks
like:

# file: test/tmp
# owner: root
# group: root
user::rw-
group::rwx                      #effective:r--
mask::r--
other::---

So note the "group" bits are set correctly, but the mask is limiting
permissions as a result of the open that created the file setting the
file to 644 (based on a 022 umask).

> Can anybody tell me what is wrong here? Is there any mapping between
> NFS4-ACLs and Posix-ACLs on the server side or are they handled
> seperately?

There are no nfsv4 acls on the filesystem at all, so everything is done
by mapping to and from the filesystem's posix acls.

> Another question: If I add the mount option "user_xattr" to the nfs4
> exported filesystems, on the client side all permissions are shown as
> "nobody:nogroup". Why is that?

That's bizarre.  Neither server nor client nor idmapd should be using
user extended attributes at all.  Are you sure you something else wasn't
changed at the same time?

--b.
