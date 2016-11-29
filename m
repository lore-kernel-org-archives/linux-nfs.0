Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46061 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751537AbcK2VgX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Nov 2016 16:36:23 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 30 Nov 2016 08:36:15 +1100
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Martin Pitt <martin.pitt@ubuntu.com>
Subject: Re: [PATCH 2/2] mount: RPC_PROGNOTREGISTERED should not be a permanent error
In-Reply-To: <214253e5-5ef2-ae9a-bc57-20ed1c2f7e3a@RedHat.com>
References: <147157095612.26568.14161646901346011334.stgit@noble> <147157115640.26568.2934329194247787636.stgit@noble> <2a0955df-2fcd-05f1-9e6f-d8a549321177@RedHat.com> <87bmx7cezt.fsf@notabene.neil.brown.name> <34768ca3-0aa1-eb00-01c9-922e3bbcb51f@RedHat.com> <87poll93s7.fsf@notabene.neil.brown.name> <214253e5-5ef2-ae9a-bc57-20ed1c2f7e3a@RedHat.com>
Message-ID: <87a8ci7yuo.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 29 2016, Steve Dickson wrote:

> My apologies for the delayed response... I just saw this...=20


Yeah, life happens.

>
> On 11/23/2016 06:26 PM, NeilBrown wrote:
>> On Thu, Nov 24 2016, Steve Dickson wrote:
>>>>
>>>> So I think the current behavior is correct.  You might be able to argue
>>>> that certain error codes should trigger a shorter timeout, but it would
>>>> need a strong argument.
>>> Going with the theory the window is very small, how about=20
>>> a retry with a timeout then a failure?=20
>>=20
>> I started looking at changing the timeout and it wouldn't be too hard
>> (if we can agree on a suitable delay), but I feel I must ask why this is
>> important.
> Over the last few Connectathon and bakeathons I've been
> floating the idea of dismantling the UDP support and
> nobody to objected... The main reason is to cut the testing=20
> matrix in half.

Dismantling?  As in: removing the code?  I wouldn't like that.
Certainly switch the default and even pop up a warning "UDP bad - use
TCP ok?".

>
> I keep getting these goofy UDP bugs from our QE guys that
> nobody is going to fix... and I have not seen a UDP bug
> from a customer in years.. I really don't think=20
> it being used so why continue to support it?

Completely happy for distros to choose not to support it.  But there are
more users of Linux than we distro people hear from.

>
>> In what situation are you likely to mount with the wrong protocol, that
>> you aren't able to just Ctrl-C when you realized what a dumb thing you
>> just did?
> I turned off the UDP support in rpc.nfsd and mounts started to hang.

Mounts that would otherwise fail - correct?
Exactly the same behavior as if you disabled NFS service on the server.

I have difficulty seeing this as being a serious problem.  It gets
notices, someone does "s/udp/tcp/" on /etc/fstab.  Problem gone.


>
>>=20
>> If rpcbind isn't running, which is arguably a very similar situation
>> (no protocols are register) we have always had a long timeout. Why is
>> "just one protocol not registered" any different?
> ECONNREFUSED can also me the server is not up so we=20
> need to wait.

If there servers in not up you get EHOSTUNREACHABLE (or however it is
spelled) or a timeout.
We need to wait on RPC_PROGNOTREGISTERED for exactly the same reason
that we need to wait for ECONNREFUSED: the server might still be coming
up and hasn't quite got everything registered properly yet.

>
>>=20
>>=20
>> Anyway, below is the patch I was working on.  I stopped when I wasn't
>> sure how to handle ECONNREFUSED.
> I've quick took and it does look a little messy or we
> revert the EOPNOTSUPP commit...

The EOPNOTSUPP commit fixed a real bug.  The bug would result in a mount
attempt failing when it should succeed.  Reverting that is not an
option.
Your symptom is not so much a bug and an inconvenience.  You issue a
command that will fail, and it takes a bit longer to fail than you would
like.  You still get the correct end result.

I don't think the patch is messy ... or at least, the resulting code
isn't.
I'll have another go and submit a proper patch.

Thanks,
NeilBrown

>
> But at least you know my motivation.
>
> steved.=20
>>=20
>> NeilBrown
>>=20
>>=20
>>=20
>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> index d5dfb5e4a669..084776115b9>>> I disagree with the "hang forever" de=
scription.  I just tested after
>>>> disabling UDP on an nfs server, and the delay was 2 minutes, 5 seconds
>>>> before a failure was reported.  It might be longer when trying TCP on a
>>>> server that only supports UDP.
>>> Yeah I did not wait that long... You are much more of a patient man tha=
n I ;-)=20
>>> I do think this is a regression. Going an from an instant failure to one
>>> that takes over 2min is not a good thing... IMHO.
>>>f 100644
>> --- a/utils/mount/stropts.c
>> +++ b/utils/mount/stropts.c
>> @@ -935,24 +935,30 @@ static int nfs_try_mount(struct nfsmount_info *mi)
>>   * failed so far, but fail immediately if there is a local
>>   * error (like a bad mount option).
>>   *
>> - * ESTALE is also a temporary error because some servers
>> - * return ESTALE when a share is temporarily offline.
>> + * If there is a remote error, like ESTALE or RPC_PROGNOTREGISTERED
>> + * then it is probably permanent, but there is a small chance
>> + * the it is temporary can we caught the server at an awkward
>> + * time during start-up.  A shorter timeout is best for such
>> + * circumstances, so return a distinct status.
>>   *
>> - * Returns 1 if we should fail immediately, or 0 if we
>> - * should retry.
>> + * Returns PERMANENT if we should fail immediately,
>> + * TEMPORARY if we should retry normally, or
>> + * REMOTE if we should retry with shorter timeout.
>>   */
>> -static int nfs_is_permanent_error(int error)
>> +enum error_type { PERMANENT, TEMPORARY, REMOTE };
>> +static enum error_type nfs_error_type(int error)
>>  {
>>  	switch (error) {
>>  	case ESTALE:
>> +	case EOPNOTSUPP:	/* aka RPC_PROGNOTREGISTERED */
>> +		return REMOTE;
>>  	case ETIMEDOUT:
>>  	case ECONNREFUSED:
>>  	case EHOSTUNREACH:
>> -	case EOPNOTSUPP:	/* aka RPC_PROGNOTREGISTERED */
>>  	case EAGAIN:
>> -		return 0;	/* temporary */
>> +		return TEMPORARY;
>>  	default:
>> -		return 1;	/* permanent */
>> +		return PERMANENT;
>>  	}
>>  }
>>=20=20
>> @@ -967,6 +973,7 @@ static int nfsmount_fg(struct nfsmount_info *mi)
>>  {
>>  	unsigned int secs =3D 1;
>>  	time_t timeout;
>> +	int last_errno =3D 0;
>>=20=20
>>  	timeout =3D nfs_parse_retry_option(mi->options,
>>  					 NFS_DEF_FG_TIMEOUT_MINUTES);
>> @@ -987,13 +994,22 @@ static int nfsmount_fg(struct nfsmount_info *mi)
>>  			 */
>>  			return EX_SUCCESS;
>>=20=20
>> -		if (nfs_is_permanent_error(errno))
>> +		switch(nfs_error_type(errno)) {
>> +		case PERMANENT:
>> +			timeout =3D 0;
>>  			break;
>> -
>> -		if (time(NULL) > timeout) {
>> +		case REMOTE:
>> +			if (errno =3D=3D last_errno)
>> +				timeout =3D 0;
>> +			break;
>> +		case TEMPORARY:
>>  			errno =3D ETIMEDOUT;
>>  			break;
>>  		}
>> +		last_errno =3D errno;
>> +
>> +		if (time(NULL) > timeout)
>> +			break;
>>=20=20
>>  		if (errno !=3D ETIMEDOUT) {
>>  			if (sleep(secs))
>> @@ -1020,7 +1036,7 @@ static int nfsmount_parent(struct nfsmount_info *m=
i)
>>  	if (nfs_try_mount(mi))
>>  		return EX_SUCCESS;
>>=20=20
>> -	if (nfs_is_permanent_error(errno)) {
>> +	if (nfs_error_type(errno) =3D=3D PERMANENT) {
>>  		mount_error(mi->spec, mi->node, errno);
>>  		return EX_FAIL;
>>  	}
>> @@ -1055,8 +1071,14 @@ static int nfsmount_child(struct nfsmount_info *m=
i)
>>  		if (nfs_try_mount(mi))
>>  			return EX_SUCCESS;
>>=20=20
>> -		if (nfs_is_permanent_error(errno))
>> +		switch (nfs_error_type(errno)) {
>> +		case REMOTE: /* Doesn't hurt to keep trying remote errors
>> +			      * when in the background
>> +			      */
>> +		case PERMANENT:
>> +			timeout =3D 0;
>>  			break;
>> +		}
>>=20=20
>>  		if (time(NULL) > timeout)
>>  			break;
>>=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlg99M8ACgkQOeye3VZi
gbnv9A/6AnO2yHy89CEJyEQjdttLkwTBmycYDkD2wBY1Y1hg9KzStz3Q9CNboLb0
TQ0dqp4hq4Z0fdxHHvrbLwgnqWwsmp8LJ4tXXSqyqYxTMU4jSn7g1uDnqnatzjVe
EKrFm6YnT86f+TJK558zma2jCtljk8nCDhOBcC5oVLmHB+OtK+1rrq2jXUzK27lx
RNQChI6T46KeH4/cPm8B+jyozVtH9DE74W5WK7ytk7xGuBDOdTPIkoa/wgabMZQr
fMXAXKMxf0PxXws8L9mym/C/tCz/DdZc53b6Vja8k8UCqEQXLxP8A+J12QQOBCFr
jP3WJ/Bsk0veQfrYyaCzXPUUYvVtqfZ6c0SWh626RSABo7f9h92VS/n5so8DhXdA
wnqSH5i/OXTXVkW2IXd+8fHdEtpZNSbiJigrXwdgupNfPpN5BKI/076zzei/bdfD
GaStifsmqZ3CR3MDIUim2nYczaWSDEJijUqB3aTv/PKs/+EpDUwAboemA9lGC82M
u1MTPcXvLO0yImlt/2uFhgt4EQcMj5cFh5ZXtO4yO+dMe7LFwNS2+E2hsiWVMuGj
6WvlhrkgIBszZzGE4iJvsFgx1f07jK8ZTwxAcdvfpdPVqHaDx4UiXNHRqfw6BhGO
do6D9o3Ns4nwMhSlbdQKAMz8IoM+2aFdUI2+ZkZV4fZHD6EGG9Y=
=9B1p
-----END PGP SIGNATURE-----
--=-=-=--
