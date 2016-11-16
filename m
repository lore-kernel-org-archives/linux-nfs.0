Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43634 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752028AbcKPBer (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 Nov 2016 20:34:47 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 16 Nov 2016 12:34:37 +1100
Cc: Mike Frysinger <vapier@gentoo.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
Subject: Re: [Libtirpc-devel] [PATCH rpcbind v2] Move default state-dir to a subdirectory of /tmp
In-Reply-To: <ed1f4f4c-fda6-6909-baab-5fbde2a5bc6c@RedHat.com>
References: <877f8almcf.fsf@notabene.neil.brown.name> <20161111210034.GM21655@vapier.lan> <87polzj7sx.fsf@notabene.neil.brown.name> <87vavqilre.fsf@notabene.neil.brown.name> <ed1f4f4c-fda6-6909-baab-5fbde2a5bc6c@RedHat.com>
Message-ID: <8760noi4wi.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Wed, Nov 16 2016, Steve Dickson wrote:

> On 11/14/2016 02:05 AM, NeilBrown wrote:
>> rpcbind can save state in a file to allow restart without forgetting
>> about running services.
>>
>> The default location is currently "/tmp" which is
>> not ideal for system files.  It is particularly unpleasant
>> to put simple files there rather than creating a directory
>> to contain them.
>>
>> On a modern Linux system it is preferable to use /run, and there it is
>> even more consistent with practice to use a subdirectory.
>>
>> This directory needs to be create one each boot, and while there are
>> tools (e.g. systemd-tmpfiles) which can do that it is cleaner to keep
>> rpcbind self-contained and have it create the directory.
>>
>> So change the default location to /tmp/rpcbind, and create that
>> directory.  If a different user-id is used, we need to create
>> and chown the directory before dropping privileges.  We do this
>> with care so avoid chowning the wrong thing by mistake.
>>
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>
>> hi,
>>  I realized that I hadn't allowed for the fact that rpcbind changes
>>  it's uid, and we need to mkdir and chown before that.
>>  I've also reverted the move to /run, but moved to /tmp/rpcbind
>>  instead.  A subdirectory is a good idea, even in /tmp.
> I'm beginning to think put these files into a directory call /tmp/rpcbind
> is not a good idea...  Because if something in /tmp is called rpcbind (like a
> debugging binary ;-) ) the mkdirs will silently fail which is not good.
>
> Here is what I would like to do.
>
> Move the directory into /run then create the /run/rpcbind when it
> does not exist... I think that should play nicely in both the
> systemd worlds and non-systemd worlds
>
> Thoughts?

/var/run rather than /run seems to be a safer universal default.
Linux distros can run ./configure --with-statedir=/run/rcpbind

Otherwise, I think we are in agreement.

You want I should respin with /tmp/rpcbind -> /var/run/rpcbind ??

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYK7etAAoJEDnsnt1WYoG5S7cQAKbh4SkExkOA2cS8cjoBOLai
EzuLB4KvUcLZVpTI1llHc+u8n6h4E1s4JmQ7Id9se60bjnlJgGVRigPEoCTmXges
65fK7eyEVK82EMNdL3Jt/b8KCdgZe+7Z7+MNqH8KRWY5TO5GHt9M3MKriuXf6euJ
VxcIBKYXHPp5KFQKQki61XnAubHR1JHFy86rx+SsE8PP3dAfJqZo08moNw6jgI6i
BvsxegUoyFmgTFIgiTdo9E5VIqFLmWKhOISWF99JSkZaJC3PznB7r6QmhZNd80//
r8tp0H2e1zMcHx9CcUolJjOS28p4EgSOxbTA0zcrmOH71p7bv7GuQCt0sIrz2z23
0XvSejZt28gcLTE0/oAU6qav3Oq8RkQGKkTzohf237mssFog27LdbEYimC5YfUl2
kRkHWpZh41e0vmt62Xg3PVoAQHmonetSRTR2jpRE3cWVIntjZhbbfpi1oW37zF5+
TVcLOYwz7JFFWr907fYeMPn5iwMJk8c/meIeK/X8NLUzUttNoF/TfB+g9cUW+jdc
pJI2M9uhDqSiTM+Xb9gchU4YUG2PLz7aNOBUA7MBIAbjA8PHtfqdL1zVPPcWg4TN
+d/hbrGppVGOr2Ko5Ul0/J5LKLQ8ac2P1TfjaOZOZleZSOWkCM3mzflk8Ve+ZZ6f
FRynRGltz9cusyNq2nJS
=nTt9
-----END PGP SIGNATURE-----
--=-=-=--
