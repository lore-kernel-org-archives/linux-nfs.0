Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:47553 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444Ab0KQO0Z convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 09:26:25 -0500
Received: by yxf34 with SMTP id 34so1082934yxf.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 06:26:25 -0800 (PST)
In-Reply-To: <4CE3B3B9.8040208@openoffice.nl>
References: <4CE294DD.6010508@blub.net>
	<4CE3B3B9.8040208@openoffice.nl>
Date: Wed, 17 Nov 2010 09:26:24 -0500
Message-ID: <AANLkTi=Vhz+BSeGtYOUavf9Lq0ms2hLjTUyuvGt0gMxj@mail.gmail.com>
Subject: Re: no_root_squash (and valid KRB root-ticket)
From: Kevin Coffman <kwc@citi.umich.edu>
To: Valentijn Sessink <v.sessink@openoffice.nl>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Nov 17, 2010 at 5:51 AM, Valentijn Sessink
<v.sessink@openoffice.nl> wrote:
> Valentijn Sessink schreef:
>> http://www.unix-info.org/nfsV4_howto_.txt that says that there is "no
>> proper mapping between root and the GSSAuthName";
>
> The gssd man page says:
>
> ``By default, rpc.gssd treats accesses by the user with UID 0 specially,
>  and uses "machine credentials" for all accesses by that
> user which require Kerberos authentication.  With the -n option,
> "machine  credentials"  will  not be used for accesses by UID 0.
> Instead, credentials must be obtained manually  like  all  other users.
>  Use  of  this  option  means  that "root" must manually obtain
> Kerberos credentials before attempting to  mount  an  nfs filesystem
> requiring Kerberos authentication.''
>
> That - sort of - answers the question: I'm being held for a machine.
>
> A bit odd is, that I can be root on the share by using root's
> credentials from within another UID (because technically, your Kerberos
> login is just a way to map your local user ID to the server's user ID):
>
> root@host32:~# su - adam
> No directory, logging in with HOME=/
> adam@host32:/$ kinit root
> root@KERBEROS.DOMAIN's Password:
> adam@host32:/$ cd /home/
> adam@host32:/home$ touch file
> adam@host32:/home$ ls -al file
> -rw-rw-r--  1 root root    0 2010-11-17 11:28 file
>
> On the server, "file" is also owned by root:root. So you can be root,
> but not as root. (And if "adam" logs in to host32 shortly after our
> excercise, he will be pleasantly surprised to see that he owns
> everything on /home - although this will turn out to be a sort of King
> Midas' touch, because on next login, the cached UID mapping will long be
> forgotten and he won't be able to access all those documents owned by
> root...)
>
> Final question: having seen the gssd page, I don't think there's a way
> for "root" on the local machine to have root rights on the server, or is
> there? (Having to get manual kerberos credentials to mount /home, with
> the "-n" switch, is not an option).

Did you see my message about "static" mapping for libnfsidmap?

On your server, you can map "host/client.machine@REALM" to root.  (Or
"nfs/client.machine@REALM" or "root/client.machine@REALM", depending
on what key you have on the client.)

K.C.
