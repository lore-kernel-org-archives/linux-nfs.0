Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx4.science-computing.de ([193.197.16.30]:2974 "EHLO
	mx4.science-computing.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964984Ab2CNN66 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Mar 2012 09:58:58 -0400
Date: Wed, 14 Mar 2012 14:48:31 +0100
From: Michael Weiser <M.Weiser@science-computing.de>
To: Kevin Coffman <kwc@umich.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 post-1.2.2 nfs-utils client fails to mount from
 pre-1.2.3 nfs-utils server
Message-ID: <20120314134829.GA943@science-computing.de>
References: <20120312200221.GS29573@science-computing.de>
 <CAKnQG+dq4C+dw5W2Jgcgg7xk-Kj_-hxLnCbeR8879tZ7DMt3jA@mail.gmail.com>
 <5dad9f48aa83cc6af5f51fb3a5c076e0.squirrel@webmail.science-computing.de>
 <CAKnQG+f3cG0q8Zoan=cc85qD5MUqqiwgnxFeq1ygTmGip+Kp5w@mail.gmail.com>
 <20120313144214.GB16920@science-computing.de>
 <CAKnQG+ezssmHZCAogTuWC7+ubAn8YjUtOF1MJ0Fw4rr7Z_srhw@mail.gmail.com>
MIME-Version: 1.0
In-Reply-To: <CAKnQG+ezssmHZCAogTuWC7+ubAn8YjUtOF1MJ0Fw4rr7Z_srhw@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Kevin,

On Tue, Mar 13, 2012 at 02:53:46PM -0400, Kevin Coffman wrote:

> It sounds like you are saying that your RHEL5 NFS server has a keytab
> with more than a DES key.  If that is true, I think that is the issue.
>  Not with the clients.

Yes, this is what I've been talking about: I have only aes256-cts and
arcfour-hmac keys in the keytabs of client and server:

[root@rhel5s1 etc]# klist -ke
Keytab name: FILE:/etc/krb5.keytab
KVNO Principal
---- --------------------------------------------------------------------------
   2 nfs/rhel5s1.mydomain.example@MYDOMAIN.EXAMPLE (AES-256 CTS mode with 96-bit SHA-1 HMAC) 
   2 nfs/rhel5s1.mydomain.example@MYDOMAIN.EXAMPLE (ArcFour with HMAC/md5) 

and no configuration in /etc/krb5.conf whatsoever:

[root@rhel5s1 ~]# cat /etc/krb5.conf 
[libdefaults]
 default_realm = MYDOMAIN.EXAMPLE

With this configuration the mount works just fine (in this example the
server is its own client):

[root@rhel5s1 ~]# mount -t nfs4 -o sec=krb5 rhel5s1:/ /mnt/

gssd gets the following tickets (I had to disable a patch in RHEL5's
nfs-utils and recompile to get the ticket cache file in /tmp because
they've patched it to keep it in memory):

[root@rhel5s1 ~]# klist -e /tmp/krb5cc_machine_MYDOMAIN.EXAMPLE 
Ticket cache: FILE:/tmp/krb5cc_machine_MYDOMAIN.EXAMPLE
Default principal: nfs/rhel5s1.mydomain.example@MYDOMAIN.EXAMPLE

Valid starting     Expires            Service principal
03/14/12 13:53:32  03/14/12 23:53:32 krbtgt/MYDOMAIN.EXAMPLE@MYDOMAIN.EXAMPLE
        renew until 03/15/12 13:53:32,
	Etype (skey, tkt): AES-256 CTS mode with 96-bit SHA-1 HMAC, AES-256 CTS mode with 96-bit SHA-1 HMAC 
03/14/12 13:53:32  03/14/12 23:53:32  nfs/rhel5s1.mydomain.example@
        renew until 03/15/12 13:53:32,
	Etype (skey, tkt): DES cbc mode with CRC-32, ArcFour with HMAC/md5 

So the client's ticket for the server is encrypted using arcfour-hmac
but the session key contained therein is only des-cbc-crc.

When accessing the mount, gssd gets the following ticket for the user:

[root@rhel5s1 ~]# su - user01
-sh-3.2$ kinit
Password for user01@MYDOMAIN.EXAMPLE: 
-sh-3.2$ ls /mnt
blub  projects
-sh-3.2$ klist -e
Ticket cache: FILE:/tmp/krb5cc_10100
Default principal: user01@MYDOMAIN.EXAMPLE

Valid starting     Expires            Service principal
03/14/12 13:57:25  03/14/12 23:57:27 krbtgt/MYDOMAIN.EXAMPLE@MYDOMAIN.EXAMPLE
        renew until 03/15/12 13:57:25,
	Etype (skey, tkt): AES-256 CTS mode with 96-bit SHA-1 HMAC, AES-256 CTS mode with 96-bit SHA-1 HMAC 
03/14/12 13:57:34  03/14/12 23:57:27  nfs/rhel5s1.mydomain.example@
        renew until 03/15/12 13:57:25,
	Etype (skey, tkt): DES cbc mode with CRC-32, ArcFour with HMAC/md5 

This behaviour works so seamlessly, that I had assumed, it's intentional.
Are you telling me, that it is neither intended nor supported?

If so: Isn't this something we'd want to have? I accept that it's not
much use from an interoperability point of view but it sure simplifies
administration in a Linux-only environment. Doesn't this also have at
least some positive security impact? And as I've said, it greatly
simplifies Linux admins' life in an Active Directory 2008 R2+
environment where AD administrators will be very reluctant to change the
domain security policy for those obscure Linux boxes.

For completeness' sake: The RHEL6 client does not limit the session key
to Single DES and therefore the mount fails:

[root@rhel6 ~]# klist -e /tmp/krb5cc_machine_MYDOMAIN.EXAMPLE 
Ticket cache: FILE:/tmp/krb5cc_machine_MYDOMAIN.EXAMPLE
Default principal: nfs/rhel6.mydomain.example@MYDOMAIN.EXAMPLE

Valid starting     Expires            Service principal
03/14/12 14:00:19  03/15/12 00:00:20 krbtgt/MYDOMAIN.EXAMPLE@MYDOMAIN.EXAMPLE
        renew until 03/21/12 14:00:19,
	Etype (skey, tkt): aes256-cts-hmac-sha1-96, aes256-cts-hmac-sha1-96 
03/14/12 14:00:20  03/15/12 00:00:20 nfs/rhel5s1.mydomain.example@MYDOMAIN.EXAMPLE
        renew until 03/21/12 14:00:19,
	Etype (skey, tkt): arcfour-hmac, arcfour-hmac 

Limiting the service account to Single DES on the KDC, putting just a
des-cbc-crc key in the server's keytab and adding allow_weak_crypto =
true to /etc/krb5.conf makes the mount work and yields the following
machine ticket cache on the client:

[root@rhel6 ~]# klist -e /tmp/krb5cc_machine_MYDOMAIN.EXAMPLE 
Ticket cache: FILE:/tmp/krb5cc_machine_MYDOMAIN.EXAMPLE
Default principal: nfs/rhel6.mydomain.example@MYDOMAIN.EXAMPLE

Valid starting     Expires            Service principal
03/14/12 14:04:48  03/15/12 00:04:48 krbtgt/MYDOMAIN.EXAMPLE@MYDOMAIN.EXAMPLE
        renew until 03/21/12 14:04:48,
	Etype (skey, tkt): aes256-cts-hmac-sha1-96, aes256-cts-hmac-sha1-96 
03/14/12 14:04:48  03/15/12 00:04:48 nfs/rhel5s1.mydomain.example@MYDOMAIN.EXAMPLE
        renew until 03/21/12 14:04:48,
	Etype (skey, tkt): des-cbc-crc, des-cbc-md5 

For some funny reason, with my AD 2008R2 KDC, the ticket is encrypted
with des-cbc-md5 but accepted by the server anyway.

The user accessing the mount also gets just a des-cbc-crc/md5 ticket:

[user01@rhel6 ~]$ klist -e
Ticket cache: FILE:/tmp/krb5cc_500
Default principal: user01@MYDOMAIN.EXAMPLE

Valid starting     Expires            Service principal
03/14/12 14:08:48  03/15/12 00:08:50 krbtgt/MYDOMAIN.EXAMPLE@MYDOMAIN.EXAMPLE
        renew until 03/21/12 14:08:48,
	Etype (skey, tkt): aes256-cts-hmac-sha1-96, aes256-cts-hmac-sha1-96 
03/14/12 14:08:52  03/15/12 00:08:50 nfs/rhel5s1.mydomain.example@MYDOMAIN.EXAMPLE
        renew until 03/21/12 14:08:48,
	Etype (skey, tkt): des-cbc-crc, des-cbc-md5 

With my legacy behaviour patch, RHEL6's gssd behaves like RHEL5's and
gets arcfour-encrypted tickets with des-cbc-crc session keys inside:

1. put stronger keys back into krb5.keytab of RHEL5 server
2. allow stronger encryption types for servers service account on KDC

[root@rhel6 ~]# rpc.gssd -l -vvv
[root@rhel6 ~]# mount -o vers=4,sec=krb5 rhel5s1:/ /mnt
[root@rhel6 ~]# klist -e /tmp/krb5cc_machine_MYDOMAIN.EXAMPLE 
Ticket cache: FILE:/tmp/krb5cc_machine_MYDOMAIN.EXAMPLE
Default principal: nfs/rhel6.mydomain.example@MYDOMAIN.EXAMPLE

Valid starting     Expires            Service principal
03/14/12 14:17:28  03/15/12 00:17:28 krbtgt/MYDOMAIN.EXAMPLE@MYDOMAIN.EXAMPLE
        renew until 03/21/12 14:17:28,
	Etype (skey, tkt): aes256-cts-hmac-sha1-96, aes256-cts-hmac-sha1-96 
03/14/12 14:17:28  03/15/12 00:17:28 nfs/rhel5s1.mydomain.example@MYDOMAIN.EXAMPLE
        renew until 03/21/12 14:17:28,
	Etype (skey, tkt): des-cbc-crc, arcfour-hmac 

Same for a user:

[root@rhel6 ~]# su - user01
[user01@rhel6 ~]$ kinit
Password for user01@MYDOMAIN.EXAMPLE: 
[user01@rhel6 ~]$ ls /mnt
blub  projects
[user01@rhel6 ~]$ klist -e
Ticket cache: FILE:/tmp/krb5cc_500
Default principal: user01@MYDOMAIN.EXAMPLE

Valid starting     Expires            Service principal
03/14/12 14:18:52  03/15/12 00:18:53 krbtgt/MYDOMAIN.EXAMPLE@MYDOMAIN.EXAMPLE
        renew until 03/21/12 14:18:52,
	Etype (skey, tkt): aes256-cts-hmac-sha1-96, aes256-cts-hmac-sha1-96 
03/14/12 14:18:56  03/15/12 00:18:53 nfs/rhel5s1.mydomain.example@MYDOMAIN.EXAMPLE
        renew until 03/21/12 14:18:52,
	Etype (skey, tkt): des-cbc-crc, arcfour-hmac 

Thanks,
-- 
Michael Weiser                science + computing ag
Senior Systems Engineer       Geschaeftsstelle Duesseldorf
                              Martinstrasse 47-55, Haus A
phone: +49 211 302 708 32     D-40223 Duesseldorf
fax:   +49 211 302 708 50     www.science-computing.de
-- 
Vorstandsvorsitzender/Chairman of the board of management:
Gerd-Lothar Leonhart
Vorstand/Board of Management:
Dr. Bernd Finkbeiner, Michael Heinrichs, 
Dr. Arno Steitz, Dr. Ingrid Zech
Vorsitzender des Aufsichtsrats/
Chairman of the Supervisory Board:
Philippe Miltin
Sitz/Registered Office: Tuebingen
Registergericht/Registration Court: Stuttgart
Registernummer/Commercial Register No.: HRB 382196

