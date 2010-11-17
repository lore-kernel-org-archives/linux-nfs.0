Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from filter.openoffice.nl ([217.170.2.175]:44070 "EHLO
	filter.openoffice.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753432Ab0KQKvn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 05:51:43 -0500
Received: from localhost (localhost [127.0.0.1])
	by filter.openoffice.nl (Postfix) with ESMTP id 680B224400F
	for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 11:51:42 +0100 (CET)
Received: from filter.openoffice.nl ([127.0.0.1])
	by localhost (post-it.openoffice.nl [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id uPPuAruMcWvD for <linux-nfs@vger.kernel.org>;
	Wed, 17 Nov 2010 11:51:37 +0100 (CET)
Received: from blub.net (mail.blub.net [95.97.76.243])
	by filter.openoffice.nl (Postfix) with ESMTP id 5973924400C
	for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 11:51:37 +0100 (CET)
Received: from stout.kantoor.openoffice.nl (unknown [IPv6:2001:7b8:1529::1234:5678])
	by blub.net (Postfix) with ESMTP id 39BB930052D
	for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 11:51:37 +0100 (CET)
Message-ID: <4CE3B3B9.8040208@openoffice.nl>
Date: Wed, 17 Nov 2010 11:51:37 +0100
From: Valentijn Sessink <v.sessink@openoffice.nl>
To: linux-nfs@vger.kernel.org
Subject: Re: no_root_squash (and valid KRB root-ticket)
References: <4CE294DD.6010508@blub.net>
In-Reply-To: <4CE294DD.6010508@blub.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Valentijn Sessink schreef:
> http://www.unix-info.org/nfsV4_howto_.txt that says that there is "no
> proper mapping between root and the GSSAuthName";

The gssd man page says:

``By default, rpc.gssd treats accesses by the user with UID 0 specially,
 and uses "machine credentials" for all accesses by that
user which require Kerberos authentication.  With the -n option,
"machine  credentials"  will  not be used for accesses by UID 0.
Instead, credentials must be obtained manually  like  all  other users.
  Use  of  this  option  means  that "root" must manually obtain
Kerberos credentials before attempting to  mount  an  nfs filesystem
requiring Kerberos authentication.''

That - sort of - answers the question: I'm being held for a machine.

A bit odd is, that I can be root on the share by using root's
credentials from within another UID (because technically, your Kerberos
login is just a way to map your local user ID to the server's user ID):

root@host32:~# su - adam
No directory, logging in with HOME=/
adam@host32:/$ kinit root
root@KERBEROS.DOMAIN's Password:
adam@host32:/$ cd /home/
adam@host32:/home$ touch file
adam@host32:/home$ ls -al file
-rw-rw-r--  1 root root    0 2010-11-17 11:28 file

On the server, "file" is also owned by root:root. So you can be root,
but not as root. (And if "adam" logs in to host32 shortly after our
excercise, he will be pleasantly surprised to see that he owns
everything on /home - although this will turn out to be a sort of King
Midas' touch, because on next login, the cached UID mapping will long be
forgotten and he won't be able to access all those documents owned by
root...)

Final question: having seen the gssd page, I don't think there's a way
for "root" on the local machine to have root rights on the server, or is
there? (Having to get manual kerberos credentials to mount /home, with
the "-n" switch, is not an option).

Valentijn
-- 
http://www.openoffice.nl/   Open Office - Linux Office Solutions
Valentijn Sessink  v.sessink@openoffice.nl  +31(0)20-4214059
