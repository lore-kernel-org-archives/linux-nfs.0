Return-Path: <nfbrown@novell.com>
From: NeilBrown <nfbrown@novell.com>
To: Benjamin Coddington <bcodding@redhat.com>
Date: Wed, 16 Mar 2016 12:35:30 +1100
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils] systemd: remove the nfs-config service
In-Reply-To: <alpine.OSX.2.19.9992.1603152015540.11199@planck>
References: <dfec4f0fe32d23aff0ed608b8f2931059060479a.1457784247.git.bcodding@redhat.com> <87h9g7h2ym.fsf@notabene.neil.brown.name> <alpine.OSX.2.19.9992.1603151706000.11199@planck> <87bn6fh0jh.fsf@notabene.neil.brown.name> <alpine.OSX.2.19.9992.1603152015540.11199@planck>
Message-ID: <87d1qvfbml.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Wed, Mar 16 2016, Benjamin Coddington wrote:

>> On Wed, Mar 16 2016, Benjamin Coddington wrote:
>>
>> > On Wed, 16 Mar 2016, NeilBrown wrote:
>> >
>> >> On Sat, Mar 12 2016, Benjamin Coddington wrote:
>> >>
>> >> > The nfs-config service exists to translate distro-specific startup
>> >> > configuration into the command line arguments used by systemd to start nfs
>> >> > utilities.  Unfortunately, it is not clear to most users that this service
>> >> > must be recycled every time startup configurations have been modified, as
>> >> > this requirement is a change for at least one distro.
>> >> >
>> >> > We can get rid of nfs-config by generating the startup arguments in an
>> >> > ExecStartPre option for each service that needs them.  We'll also have to
>> >> > break out the EnvironmentFile into a separate file for each service to
>> >> > avoid races overwriting this file.
>> >> >
>> >> > A distro taking this change should also modify their
>> >> > /usr/lib/systemd/scripts/nfs-utils_env.sh script to include the new
>> >> > EnvironmentFile location for each service.
>> >> >
>> >> > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>> >>
>> >> I can't say I really like this, but it does make sense and solves a real
>> >> problem.
>> >> Maybe: I would never have written it myself, but I'm kind-a glad you did
>> >> :-)
>> >
>> > Which bits are unlikeable?  I am guessing that all these little intermediate
>> > files are the issue; that is what I hate.  I admit that it is a least-effort
>> > approach to fixing the problem.  What does the ideal fix look like to you?
>>
>> I don't like having multiple intermediate config files that are all
>> identical, and I don't like having to run the config script every time
>> any daemon is (re)started.
>>
>> I'm not sure what "ideal" would be.
>>
>> One improvement would be if systemd could be given an executable in
>> place of an environment file with the implication that it would run the
>> executable and read environment variables from the stdout.
>> That would remove the multiple config files.
>> It would still mean the script is run every time, but I could be
>> convinced that isn't so bad.
>>
>> An alternate idea is that maybe systemd could have a directive so that
>> in any transaction were "this" unit is started, "that" unit will also be
>> started.  Then we could replace "Wants=nfs-config.server" with
>> "Prepare=nfs-config.service" so if systemd ever needed to start any
>> nfs-related service, it would make preparations by first running
>> nfs-config.service - only once per transaction.
>>
>> But unless you want to hack on systemd, I think what you have is good
>> enough.
>>
>>
>> .... hmmm.  I wonder what would happen if we just removed
>> "RemainAfterExit=y" from nfs-config.service.  Would it cause things to
>> fail, or would it cause nfs-config.service to be run every time.
>>
>> Hey, that looks like it works!  Can you double check for me?
>> i.e. revert your patch, remove "RemainAfterExit=y" from
>> nfs-config.service, and then see if nfs-config.service gets run any time
>> any nfs server is started.
>
> Yep.. that appears to work just fine.  Seems like a simpler solution than
> this change.  It appears to me ( from systemd.service(5) ) that systemd's
> state transitions for Type=Oneshot will avoid races that might overwrite the
> environment file.  Nice find!
>

Great.  Thanks for testing and thanks for prodding me to explain
myself.  Very happy with the outcome!

I've posted a patch to Steve.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW6LhiAAoJEDnsnt1WYoG5g6YP/1i/6TNmo0Jx4NpdyFXcV21A
XZgg07645VnwIaJ0X46+C5K17k6ssY+OCnxCcqXhINq4ro7+8TBRMuCP7uHV2DA0
faxZAITixjJ+L9L88/jrVtbVF1t6XIqN6mzzGCxEdaZ2bGpbosdJ75rZui5VDm+9
cnRjnZmQcgrnJ+iCayvuslKplRSTJwyCtlQjaPgVoq/xmIDN56DPK6uV5dNk1rMy
ysZApp3BSTCvhG+/II18mjTxb8aav9dO/9ax83unwBxqdbv/IiMoBDamz4EttXsP
6OkCRKJk2qJwO5XVqZ7WK2MAQr0+qFTbVeFb19agnfhHjDak0aHZqZ9tKQ6b9gM7
rRfWCpTIwz/MXchz1p6aXRvkcepznITvyupby8pA2MAs4GfoIkXnbxioUmHqxiLF
gJtkbiUXnu4wvcOYvMVVKnaMuCGT8S7exfsQjBT2YAodQOxgPDIGMpgeqtiMV6aP
ie+2Grexd418/6cYtVKbzfeLRm0Ske4baLyvpadVxcJIGkXMxtxnH97d9ldjPONY
iRUORKrYmCvlW9118559NPdOjJemvrniGCD0dQtbqXKJ9Zl12Z97mgVp8VKfvbqW
qgLb7L5VfN/vEgUaEyhZokC8U1kNjs0kWF88myfa4MlMd/jhGkFvcgic4QkSJI9+
cOO+0BU65JAYB5LNOeSj
=IIl8
-----END PGP SIGNATURE-----
--=-=-=--
