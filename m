Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:60064 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115Ab1G0PSJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 11:18:09 -0400
Received: by qwk3 with SMTP id 3so857336qwk.19
        for <linux-nfs@vger.kernel.org>; Wed, 27 Jul 2011 08:18:09 -0700 (PDT)
Message-ID: <4E302C2D.40600@marcanoonline.com>
Date: Wed, 27 Jul 2011 10:48:05 -0430
From: Robert Marcano <robert@marcanoonline.com>
To: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 / POSIX ACL mapping bug? (more tests)
References: <4E2ED2A0.4030401@marcanoonline.com> <D7BF98E9-394A-4364-8124-1E39BEBE85DC@netapp.com>
In-Reply-To: <D7BF98E9-394A-4364-8124-1E39BEBE85DC@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/26/2011 02:03 PM, Andy Adamson wrote:
> Hi
>
> Which client, which server (distro and uname -a output) did you use? Also, what commands (setfacl,getfacl? nfs4_setfacl, nfs4_getfacl ? plus version) and parameters did you use?
>

Now using nfs4 acl tools

nfs4_getfacl 0.3.3
nfs4_setfacl 0.3.3

======================================
NFS client (Fedora 15)
======================================

$ nfs4_getfacl directory/
A::OWNER@:rwaDxtTcCy
A::GROUP@:rxtcy
A::EVERYONE@:rxtcy

$ nfs4_setfacl -a A:gdf:sharedgroup@localdomain:rwaDxtcy directory/

$ nfs4_getfacl directory/
A::OWNER@:rwaDxtTcCy
A::GROUP@:rxtcy
A:g:sharedgroup@localdomain:rwaDxtcy
A::EVERYONE@:rxtcy
D:fdi:OWNER@:rwaDx
A:fdi:OWNER@:tTcCy
A:fdi:GROUP@:tcy
A:fdig:sharedgroup@localdomain:rwaDxtcy
A:fdi:EVERYONE@:tcy

$ touch directory/client

$ nfs4_getfacl directory/client
D::OWNER@:r
A::OWNER@:tTcCy
A::GROUP@:tcy
A:g:sharedgroup@localdomain:rtcy
A::EVERYONE@:tcy

Inheritance was added for the group sharedgroup to the directory, but 
the file does not gets w permission when the file is created, the NFS 
ACL <--> POSIX ACL Mapping on the file "client" on the server are

# getfacl directory
user::rwx
group::r-x
group:admision:rwx
mask::rwx
other::r-x
default:user::---
default:group::---
default:group:admision:rwx
default:mask::rwx
default:other::---

# getfacl directory/client
user::---
group::---
group:sharedgroup:rwx		#effective:r--
mask::r--
other::---

Why the client user umask (022) is being used for the inherited 
permissions for the group "sharedgroup"? is this by design or a bug?

Thanks in advance
