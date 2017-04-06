Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38702 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751593AbdDFVho (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Apr 2017 17:37:44 -0400
From: NeilBrown <neilb@suse.com>
To: Scott Mayhew <smayhew@redhat.com>
Date: Fri, 07 Apr 2017 07:37:02 +1000
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH v2 4/4] systemd: add a generator for the rpc_pipefs mountpoint
In-Reply-To: <20170406122931.am64xg5hs3juaqrt@tonberry.usersys.redhat.com>
References: <20170405211243.12282-1-smayhew@redhat.com> <20170405211243.12282-5-smayhew@redhat.com> <87d1cq14lr.fsf@notabene.neil.brown.name> <20170406122931.am64xg5hs3juaqrt@tonberry.usersys.redhat.com>
Message-ID: <874ly11am9.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 06 2017, Scott Mayhew wrote:

> On Thu, 06 Apr 2017, NeilBrown wrote:
>
>> On Wed, Apr 05 2017, Scott Mayhew wrote:
>>=20
>> > The nfs.conf has config options for the rpc_pipefs mountpoint.
>> > Currently, changing these from the default also requires manually
>> > overriding the systemd unit files that are hard-coded to mount the
>> > filesystem on /var/lib/nfs/rpc_pipefs.
>> >
>> > This patch adds a generator that creates a mount unit file for the
>> > rpc_pipefs when a non-default value is specified in /etc/nfs.conf, as
>> > well as a target unit file to override the dependencies for the systemd
>> > units using the rpc_pipefs.  The blkmapd, idmapd, and gssd service unit
>> > files have been modified to define their dependencies on the rpc_pipefs
>> > mountpoint indirectly via the rpc_pipefs target unit file.
>> >
>> > This patch also removes the dependency on the rpc_pipefs from the
>> > rpc-svcgssd.service unit file.  rpc.svcgssd uses the sunrpc cache
>> > mechanism to exchange data with the kernel, not the rpc_pipefs.
>> >
>> > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
>>=20
>> I was reading through this, which I really thought would be a good patch
>> that I would give an Ack to, and looking at some of the detail involved,
>> I started to wonder if we were really doing the right thing here.
>> You go to some trouble to make the name of the .mount unit file match
>> the name of the location of the mountpoint.  Is that really necessary?
>>=20
>> Unit files created by systemd-fstab-generator do follow that pattern,
>> but they don't have to.
>
>>=20
>> Maybe we should just:
>>=20
>> 1/ rename var-lib-nfs-rpc_pipefs.mount to rpc_pipefs.mount,
>>    and modify the dependencies accordingly.
>>=20
> The mount doesn't work when I change the name.
>
> [root@fedora25 ~]# systemctl status rpc_pipefs.mount
> =E2=97=8F rpc_pipefs.mount - RPC Pipe File System
>    Loaded: error (Reason: Invalid argument)
>    Active: inactive (dead)
>     Where: /var/lib/nfs/rpc_pipefs
>      What: sunrpc
>
> Apr 06 08:17:59 localhost.localdomain systemd[1]: rpc_pipefs.mount: Where=
=3D setting doesn't match unit name. Refusing.
>
>
> Looking back at systemd.mount(5), it looks like they do have to follow
> that pattern:
>
>        Mount units must be named after the mount point directories they c=
ontrol.
>        Example: the mount point /home/lennart must be configured in a uni=
t file
>        home-lennart.mount. For details about the escaping logic used to c=
onvert a
>        file system path to a unit name, see systemd.unit(5). Note that mo=
unt units
>        cannot be templated, nor is possible to add multiple names to a mo=
unt unit
>        by creating additional symlinks to it.
>

My turn not to read to the end of the man page I see...

That's a strange restriction that seem inconsistent with everything else
systemd does.  Maybe it it helpful for implementing "RequiresMountsFor"
but I cannot think of any other justification.
Anyway, I guess we have to live with it.

I bothered me that you needed to include this:
>> > +	fprintf(f, "DefaultDependencies=3Dno\n");
>> > +	fprintf(f, "After=3Dsystemd-tmpfiles-setup.service\n");
>> > +	fprintf(f, "Conflicts=3Dumount.target\n");

in the code, but I can't see anything we can do about that.

So:
 Reviewed-by: NeilBrown <neilb@suse.com>

for this patch.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljmtP4ACgkQOeye3VZi
gbmYng/8DYvC6ix+b0gszid3RvjV1ZF3E5+o/vmST2JFDQa4HyHJ6HtfE5arwiwh
6jLxp1QvylQupnrSBzCPlKXgYFxilS8MQIrfJu1H2eGk1Fn8b5w+zo0dQ+Ikz0lE
IjUPKUJh24C4QBroqy6R7/Ae2brJ9UM2Q4dofMKGI7UNgFOLpco5+64Zp0Hc6EHh
/W15UWPH3/YM7ZpJkJMmdhEQfqA0/YbZmsqCQUGsvLKj/6AJ6nHDCBhWqnQAi8LQ
g8e/XnOacMb89EJHL970UY8S387jfyYRaff1evg5wCPdAebaEWhdRJ64Q/u1MeX+
SND3Ei2bhJ/KnalTWHchqP3xndsVsgvzjK4ozFwzXY9XGcjrWq4Pa4yVYXgHP7sp
WpTfWgiWirD+f5onRGvanzUMoAO2YXVaJY7Sm4iEWkpnM6yhb1vIUmtjMrWEJ2Uy
d8sa4XO8CgBaT5iUmiK82C0agk8QvTS1Ro5zHrPyhOtwEhXyQLKLFr27Y11PFpFM
vq3FBL7ZYnnn9CykgW8u3KTCqi1JjwvUrwXRSNtsjCXAmDOZHuSItFulMozFgb0j
o0wXHSg2ofDhJq7jvY7kHgIR8BNyborNZSxUfncOvVg5Xum3dfGsSqGpfxnFCZ3e
roDAWD8LOHx23H5gPSbEYYiOPnfTKkpiMR+OAmX4D8TmE+qIo7A=
=sljA
-----END PGP SIGNATURE-----
--=-=-=--
