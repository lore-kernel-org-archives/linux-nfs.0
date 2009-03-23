From: Alex Bremer <albremer@googlemail.com>
Subject: Re: NFS4 ACL <-> Posix ACL
Date: Mon, 23 Mar 2009 14:46:46 +0100
Message-ID: <7f62dcb30903230646u183c79e0i4366edebe32654d5@mail.gmail.com>
References: <7f62dcb30903181042n42bae0bbk99f5c91fce6e9e82@mail.gmail.com>
	 <20090319193514.GE3072@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f165.google.com ([209.85.219.165]:43385 "EHLO
	mail-ew0-f165.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815AbZCWNqu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Mar 2009 09:46:50 -0400
Received: by ewy9 with SMTP id 9so1625946ewy.37
        for <linux-nfs@vger.kernel.org>; Mon, 23 Mar 2009 06:46:46 -0700 (PDT)
In-Reply-To: <20090319193514.GE3072@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2009/3/19, J. Bruce Fields <bfields@fieldses.org>:
> On Wed, Mar 18, 2009 at 06:42:10PM +0100, Alex Bremer wrote:
>> However on a client
>> using NFS4, these Posix-ACLs don't seem to get mapped to NFS4-ACLs.
>
> Actually, they do; what's happening (I believe--this is partly just
> memory based on last time I looked at something like this) is more
> subtle: the umask is being overridden by inheritance in the v2/v3 case,
> and not in the v4 case.
>
> Posix default acls are supposed to override the umask.  This is tricky
> for NFS, since the umask isn't sent over the wire on file creation,
> leaving the client and server no way to distinguish the create mode from
> the umask.  The v2/v3 client currently works around this by doing the
> whole inheritance calculation on the client (reading the directory's
> acl, then explicitly setting the new child's acl based on it).  The v4
> client doesn't do that.  So:

So is there any way to make newly created files group writeable except
for setting the umask of each user to 002? Setting the umask to 002 is
not an option for us, but all files in the public area have to be
group writeable. Is there maybe a mount option to set the umask or a
server sided option which enforces the group writeable flag?

I would expect that my use case is not that uncommon and that many
companys have the exact same problem. Would the inheritance work if we
used a fully NFS4-ACL compatible filesystem? Is there any for Linux?
How do other people share public files with NFS4? If there is no other
way than setting the users's umask to 002, this would practically
limit the use of NFS4 to private shares like home directories. I can't
tell my users to change the permissions after creating a file. Some of
them do not even know what permissions are.

> There are no nfsv4 acls on the filesystem at all, so everything is done
> by mapping to and from the filesystem's posix acls.

So I guess there is no NFS4-ACL compliant filesystem for linux either? :-(

>> Another question: If I add the mount option "user_xattr" to the nfs4
>> exported filesystems, on the client side all permissions are shown as
>> "nobody:nogroup". Why is that?
>
> That's bizarre.  Neither server nor client nor idmapd should be using
> user extended attributes at all.  Are you sure you something else wasn't
> changed at the same time?

Oh, you are right. I just gave it another try and now it works. Don't
know what happened. Last time I tried it, the only thing I changed was
the user_xattr mount option and I got all owner:group entries as
nobody:nogroup. I changed the flag back and it worked again. Now it
even works with user_xattr on.

Alex
