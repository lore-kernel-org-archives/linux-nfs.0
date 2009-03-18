From: Alex Bremer <albremer@googlemail.com>
Subject: NFS4 ACL <-> Posix ACL
Date: Wed, 18 Mar 2009 18:42:10 +0100
Message-ID: <7f62dcb30903181042n42bae0bbk99f5c91fce6e9e82@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:42356 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752421AbZCRRmN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 13:42:13 -0400
Received: by ey-out-2122.google.com with SMTP id 4so34557eyf.37
        for <linux-nfs@vger.kernel.org>; Wed, 18 Mar 2009 10:42:10 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I have a working NFS4 installation (kerberos + ldap) but some trouble
understanding all these ACL mappings. On my server (ubuntu 8.04) the
ext3 filesystems are mounted with the "acl" option and setting Posix
ACLs works quite well.

On the client side (ubuntu 8.10) my libacl seems to lack NFSv4 ACL
support and therefore I can't see the acl list. However I installed
nfs4 acl tools and now I can see the ACL permissions of a
file/directory.

Using Posix ACLs on the server I added a default mask so that newly
created files/directories in the public area are group-writeable. This
works quite well on the server and this used to work with NFS3 (which
supports POSIX ACLs) on the client side, too. However on a client
using NFS4, these Posix-ACLs don't seem to get mapped to NFS4-ACLs.

Here are the ACLs:
-----------------
server> getfacl test/

user::rwx
group::rwx
other::---
default:user::rwx
default:group::rwx
default:other::---

server> touch test/tmp
server> ls -l test/tmp
-rw-rw---- 1 albremer domusers 0 2009-03-18 18:32 test/tmp
---------------
client> nfs4_getfacl test/

A::OWNER@:rwaDxtTcCy
A::GROUP@:rwaDxtcy
A::EVERYONE@:tcy
A:fdi:OWNER@:rwaDxtTcCy
A:fdi:GROUP@:rwaDxtcy
A:fdi:EVERYONE@:tcy

client> touch test/tmp
client> ls -l test/tmp
-rw-r----- 1 albremer domusers 0 2009-03-18 18:32 test/tmp
---------------

Can anybody tell me what is wrong here? Is there any mapping between
NFS4-ACLs and Posix-ACLs on the server side or are they handled
seperately?

Another question: If I add the mount option "user_xattr" to the nfs4
exported filesystems, on the client side all permissions are shown as
"nobody:nogroup". Why is that?

Alex
