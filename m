Return-Path: <nfbrown@novell.com>
From: NeilBrown <nfbrown@novell.com>
To: Benjamin Coddington <bcodding@redhat.com>
Date: Wed, 16 Mar 2016 08:52:02 +1100
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils] systemd: remove the nfs-config service
In-Reply-To: <alpine.OSX.2.19.9992.1603151706000.11199@planck>
References: <dfec4f0fe32d23aff0ed608b8f2931059060479a.1457784247.git.bcodding@redhat.com> <87h9g7h2ym.fsf@notabene.neil.brown.name> <alpine.OSX.2.19.9992.1603151706000.11199@planck>
Message-ID: <87bn6fh0jh.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Wed, Mar 16 2016, Benjamin Coddington wrote:

> On Wed, 16 Mar 2016, NeilBrown wrote:
>
>> On Sat, Mar 12 2016, Benjamin Coddington wrote:
>>
>> > The nfs-config service exists to translate distro-specific startup
>> > configuration into the command line arguments used by systemd to start nfs
>> > utilities.  Unfortunately, it is not clear to most users that this service
>> > must be recycled every time startup configurations have been modified, as
>> > this requirement is a change for at least one distro.
>> >
>> > We can get rid of nfs-config by generating the startup arguments in an
>> > ExecStartPre option for each service that needs them.  We'll also have to
>> > break out the EnvironmentFile into a separate file for each service to
>> > avoid races overwriting this file.
>> >
>> > A distro taking this change should also modify their
>> > /usr/lib/systemd/scripts/nfs-utils_env.sh script to include the new
>> > EnvironmentFile location for each service.
>> >
>> > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>>
>> I can't say I really like this, but it does make sense and solves a real
>> problem.
>> Maybe: I would never have written it myself, but I'm kind-a glad you did
>> :-)
>
> Which bits are unlikeable?  I am guessing that all these little intermediate
> files are the issue; that is what I hate.  I admit that it is a least-effort
> approach to fixing the problem.  What does the ideal fix look like to you?

I don't like having multiple intermediate config files that are all
identical, and I don't like having to run the config script every time
any daemon is (re)started.

I'm not sure what "ideal" would be.

One improvement would be if systemd could be given an executable in
place of an environment file with the implication that it would run the
executable and read environment variables from the stdout.
That would remove the multiple config files.
It would still mean the script is run every time, but I could be
convinced that isn't so bad.

An alternate idea is that maybe systemd could have a directive so that
in any transaction were "this" unit is started, "that" unit will also be
started.  Then we could replace "Wants=nfs-config.server" with
"Prepare=nfs-config.service" so if systemd ever needed to start any
nfs-related service, it would make preparations by first running
nfs-config.service - only once per transaction.

But unless you want to hack on systemd, I think what you have is good
enough.


.... hmmm.  I wonder what would happen if we just removed
"RemainAfterExit=y" from nfs-config.service.  Would it cause things to
fail, or would it cause nfs-config.service to be run every time.

Hey, that looks like it works!  Can you double check for me?
i.e. revert your patch, remove "RemainAfterExit=y" from
nfs-config.service, and then see if nfs-config.service gets run any time
any nfs server is started.

Thanks,
NeilBrown


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW6IQCAAoJEDnsnt1WYoG5kloP/iJRGRV7RNxSbiB6Zl1EDHJC
bhaq5OY3h5mps9NacysS6MJArVlMeFYns77jsNAtzwyxOGiCr/Wh0jBwoMW0v9W8
kz3JokHhdtwDOKCPskVYlHRLImBpZWl4f5qhf+L+gZDELSlWKI6GgUG0r7fEsc4f
1jhXmTCc+d/OAbIFtyv53wzgMeOkzDQyoJkWYcO7Dl4MtSo5ew0EQJ3oO9jUux5+
pgTjn7QMpC3pehRoRDjGXyg+QX4XzlH8ocFW9NUYZTDMMTOAkpJVLFBSYIMilFQS
OBDjhNZXYORXVPG75+fFX5NFb0KqHhg3ocw62wlsKBKTwgnrEq1eKHyUX5gOAfTu
1iXlD6YbEmszaFjKW49MuBJ7PGA4UokO7pzYwWZvtIJIPm92YKbGUxPF3xkW38X9
5SNAAT1K9dj6CZYPbcd4DqvmovwOANhfa6SKC7Ow02CGNOKXBToxVFdTqrQWsSdw
NkGU21JHFnqGKHJlG5NioxV3FbF65BbLs47gWqgL7KbSTU/cLBX5Ij6Qzf8I+s14
AODuoJk5OCF9ASCY255ZPnLYKS/EbQfvLGuI+as80fWEqAEZXN6StNiqQmdS0Vh+
pk/vPMGfBxaxdjLmiB/dAbcA0Lv9e0Sj5qI4dJWclEVwcXxPNhKaDItc3uxgX9Zs
K0DVfVp7caA1HgiG0f5Y
=ddB4
-----END PGP SIGNATURE-----
--=-=-=--
