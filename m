Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53981 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934921AbcKVWpa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 22 Nov 2016 17:45:30 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 23 Nov 2016 09:43:34 +1100
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Martin Pitt <martin.pitt@ubuntu.com>
Subject: Re: [PATCH 2/2] mount: RPC_PROGNOTREGISTERED should not be a permanent error
In-Reply-To: <2a0955df-2fcd-05f1-9e6f-d8a549321177@RedHat.com>
References: <147157095612.26568.14161646901346011334.stgit@noble> <147157115640.26568.2934329194247787636.stgit@noble> <2a0955df-2fcd-05f1-9e6f-d8a549321177@RedHat.com>
Message-ID: <87bmx7cezt.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Wed, Nov 23 2016, Steve Dickson wrote:

> [Resent due to mailman rejecting the HTML subpart]
(and the resend included HTML too ... how embarrassing :-)

>
> Hey Neil,
>
>
> On 08/18/2016 09:45 PM, NeilBrown wrote:
>> Commit: bf66c9facb8e ("mounts.nfs: v2 and v3 background mounts should retry when server is down.")
>>
>> changed the behaviour of "bg" mounts so that RPC_PROGNOTREGISTERED,
>> which maps to EOPNOTSUPP, is not a permanent error.
>> This useful because when an NFS server starts up there is a small window between
>> the moment that rpcbind (or portmap) starts responding to lookup requests,
>> and the moment when nfsd registers with rpcbind.  During that window
>> rpcbind will reply with RPC_PROGNOTREGISTERED, but mount should not give up.
>>
>> This same reasoning applies to foreground mounts.  They don't wait for
>> as long, but could still hit the window and fail prematurely.
>>
>> So revert the above patch and instead add EOPNOTSUPP to the list of
>> temporary errors known to nfs_is_permanent_error.
>>
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  utils/mount/stropts.c |    7 +++----
>>  1 file changed, 3 insertions(+), 4 deletions(-)
>>
>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> index 9de6794c6177..d5dfb5e4a669 100644
>> --- a/utils/mount/stropts.c
>> +++ b/utils/mount/stropts.c
>> @@ -948,6 +948,7 @@ static int nfs_is_permanent_error(int error)
>>  	case ETIMEDOUT:
>>  	case ECONNREFUSED:
>>  	case EHOSTUNREACH:
>> +	case EOPNOTSUPP:	/* aka RPC_PROGNOTREGISTERED */
> I think this introduced a regression... When the server does not support
> a protocol, say UDP, this patch cause the mount to hang forever,
> which I don't think we want.


I think we do want it to wait a while so that the nfs server has a
chance to start up.  We have no guarantee that the NFS server will be
registered with rpcbind before rpcbind responds to requests.

I disagree with the "hang forever" description.  I just tested after
disabling UDP on an nfs server, and the delay was 2 minutes, 5 seconds
before a failure was reported.  It might be longer when trying TCP on a
server that only supports UDP.

So I think the current behavior is correct.  You might be able to argue
that certain error codes should trigger a shorter timeout, but it would
need a strong argument.

Or maybe you mean that a "bg" mount would "hang forever" in the
background?  I think that behavior is correct too.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYNMoXAAoJEDnsnt1WYoG5NaAQAIc4i8rd79s/GSzDVZtxuMlN
/7gXfGGs9LJf2SAKOMTARF4cvzPINMmtF8XnNzWDc3qa+P7/C06rW+SFXC1iSgSN
qrVrWAImdyuCHuLpi8pH6JUAVyV8cCYFjLsUmaWIhvT890g02Ja4rkKcXo39I9FX
iIZ8nowsSJTfSfblh0q9LmxH63z5ocDLTISEUHfTordoPd7g8Y342DVXKyDu3F/H
g+1YVQQOp8yyNK0+2fev8mxOZ1ekqhxccEgKHi9Uqeg1qHYjsSGD6IYlrcc2WxR+
q13MHCnYaPLNWfO5Rb21EqT0i/Yp6ThqtlRqwp1WEp4kRvw1QEMqTsZXtdguaRMF
+S6piP6+7ydehdHQuvc2UpF7+dLRwVZIMln1quhmQWJ2n2iHj6fUmBw2dkuBGGsP
qURrkK2a6RUh857BReNNzIgAtE/X2NW/1DWbvkEF0OwD5xT0MuXBx/4KSZNpCcCA
Nj691+N/LWHAfwYT0EkRNJZ3V16utxKkLs1s4R8PQqMI03O7s/hR5Qen1wewZUeo
VDzUMSZSOaKwqRsfBlFRg2qHwLsibld4mLgucGsgES6Vd5eLc93uW8j2H3oe9Zji
9R8dUVU8JzIz7oyfpXfWGNRCWyzSS1PtkR51zSTA75/UzNhEDt6v6Z7pls0yq2Mu
+0IT+Q4treYXyWLLJoKn
=I8df
-----END PGP SIGNATURE-----
--=-=-=--
