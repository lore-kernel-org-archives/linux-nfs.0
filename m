Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35008 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754039AbcHSBdC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Aug 2016 21:33:02 -0400
From: NeilBrown <neilb@suse.com>
To: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 19 Aug 2016 11:31:16 +1000
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/8] mountd: remove 'dev_missing' checks
In-Reply-To: <8F225C0B-345E-483D-8769-6E1C13269689@oracle.com>
References: <20160714021310.5874.22953.stgit@noble> <20160714022643.5874.84409.stgit@noble> <20160718200121.GC12304@fieldses.org> <878twx9ra3.fsf@notabene.neil.brown.name> <20160721172452.GC27148@fieldses.org> <87wpjokofy.fsf@notabene.neil.brown.name> <20160816152148.GC30124@fieldses.org> <87bn0qj1yz.fsf@notabene.neil.brown.name> <8F225C0B-345E-483D-8769-6E1C13269689@oracle.com>
Message-ID: <87zio9h7dn.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 18 2016, Chuck Lever wrote:

>> On Aug 17, 2016, at 9:32 PM, NeilBrown <neilb@suse.com> wrote:
>>=20
>> On Wed, Aug 17 2016, J. Bruce Fields wrote:
>>>>=20
>>>>=20
>>>> There is another issue related to this that I've been meaning to
>>>> mention.  It related to the start-up ordering rather than shut down.
>>>>=20
>>>> When you try to mount an NFS filesystem and the server isn't respondin=
g,
>>>> mount.nfs retries for a little while and then - if "bg" is given - it
>>>> forks and retries a bit longer.
>>>> While it keeps gets failures that appear temporary, like ECONNREFUSED =
or
>>>> ETIMEDOUT (see nfs_is_permanent_error()) it keeps retrying.
>>>>=20
>>>> There is typically a window between when rpcbind starts responding to
>>>> queries, and when nfsd has registered with it.  If mount.nfs sends an
>>>> rpcbind query in this window. It gets RPC_PROGNOTREGISTERED which
>>>> nfs_rewrite_pmap_mount_options maps to EOPNOTSUPP, and
>>>> nfs_is_permanent_error() thinks that is a permanent error.
>>>=20
>>> Looking at rpcbind(8)....  Shouldn't "-w" prevent this by loading some
>>> registrations before it starts responding to requests?
>>=20
>> "-w" (which isn't listed in the SYNOPSIS!) only applies to a warm-start
>> where the daemons which previously registered are still running.
>> The problem case is that the daemons haven't registered yet (so we don't
>> necessarily know what port number they will get).
>>=20
>> To address the issue in rpcbind, we would need a flag to say "don't
>> respond to lookup requests, just accept registrations", then when all
>> registrations are complete, send some message to rpcbind to say "OK,
>> respond to lookups now".  That could even be done by killing and
>> restarting with "-w", though that it a bit ugly.
>
> An alternative would be to create a temporary firewall rule that
> blocked port 111 to remote connections. Once local RPC services
> had registered, the rule is removed.
>
> Just a thought.

Interesting ..... probably the sort of thing that I would resort to if I
really needed to fix this and didn't have any source code.
But fiddling with fire-wall rules is not one of my favourite things so I
think I stick with a more focussed solution.
Thanks!

NeilBrown


>
>
>> I'm leaning towards having mount retry after RPC_PROGNOTREGISTERED for
>> fg like it does with bg.
>
> It probably should do that. If rpcbind is up, then the other
> services are probably on their way.
>
>
> --
> Chuck Lever

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXtmFkAAoJEDnsnt1WYoG5mN4QAMCmwEMrF7hQtVKM/ATMoznp
lu0UFBiJgZidIehLlUR2wZXenmf33z63hz/5WJBin0YNsIys4FrbHs4pQDCDixsk
Yw99T86Kr5joGSBI8VM3Sp+hyApRObB3WfCBkF+X9nW7t1wpBfKQ7Q3Gcnu6ihnw
yfLu/HK3URAtp2vJp/1h35oVZv84Xl9/Fo0nzm8m1Zz3PFnFRymcLDACFh6WA0pN
DFwYWOV4eoALgIVin2eJxnLBqSdW4UBcwmpj0t5WVCdWifz7XXA5SGBLj81bXypc
9RK8jaSw+Zn2zUUFvqvt3GM8R9pIZjEIivbzpQXQ5ciiG2MDS+VT67d/TFyCVeH5
y1NX0dFAkWc4a0SHoUGaHVgL3XAyTcb9Ce7MWNs3mfgPVSBEM9rQTL+Qopxl00MH
AhGX8shOxrXrDOvGd6KWiroDvZEpobZpOkepOamVYgpXYNgOhHpqcaqZkb6uZqXl
Ln+UrwKkwEuMPU6VdnFuWKM7MagBoBdb11EUckB6LuzFfIkuBR6zdu7ZWug64cap
W+NffTLH6ArpPF83xrYXogVANYvE6Q1HAO4DXzxDKE8/ZLuzfuoyYmVQR6RIrWPv
WHskB2ASY6iP6OyLzRHluMKi/59Y7p90va/TpLFqlRZEI3NGn4YkhCj4PPNPUGoy
Glj/uImuLdAS29CJHgLW
=lv82
-----END PGP SIGNATURE-----
--=-=-=--
