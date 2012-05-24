Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:24136 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754487Ab2EXVHQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 May 2012 17:07:16 -0400
Received: from vmwexceht03-prd.hq.netapp.com (vmwexceht03-prd.hq.netapp.com [10.106.76.241])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q4OL7FRv007977
	for <linux-nfs@vger.kernel.org>; Thu, 24 May 2012 14:07:15 -0700 (PDT)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfs41: Use BIND_CONN_TO_SESSION for CB_PATH_DOWN*
Date: Thu, 24 May 2012 21:07:14 +0000
Message-ID: <B06BB5BD-6FD5-4D24-BCFB-F2FAF3B2FB40@netapp.com>
References: <1337876797-17706-1-git-send-email-dros@netapp.com>
 <1337876797-17706-2-git-send-email-dros@netapp.com>
 <1337891951.3054.31.camel@lade.trondhjem.org>
 <2D8FF192-F8CB-4E12-8DB6-383DDEC76567@netapp.com>
In-Reply-To: <2D8FF192-F8CB-4E12-8DB6-383DDEC76567@netapp.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_D4F894A4-6AD8-476B-9CB1-B7C94AE55948";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_D4F894A4-6AD8-476B-9CB1-B7C94AE55948
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On May 24, 2012, at 5:00 PM, Adamson, Dros wrote:

>=20
> On May 24, 2012, at 4:39 PM, Myklebust, Trond wrote:
>=20
>> On Thu, 2012-05-24 at 12:26 -0400, Weston Andros Adamson wrote:
>>> The state manager can handle SEQ4_STATUS_CB_PATH_DOWN* flags with a
>>> BIND_CONN_TO_SESSION instead of destroying the session and creating =
a new one.
>>>=20
>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>> ---
>>> fs/nfs/nfs4_fs.h   |    1 +
>>> fs/nfs/nfs4state.c |   26 +++++++++++++++++++++-----
>>> 2 files changed, 22 insertions(+), 5 deletions(-)
>>>=20
>>> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
>>> index ad90bc7..9feff0f 100644
>>> --- a/fs/nfs/nfs4_fs.h
>>> +++ b/fs/nfs/nfs4_fs.h
>>> @@ -24,6 +24,7 @@ enum nfs4_client_state {
>>> 	NFS4CLNT_RECALL_SLOT,
>>> 	NFS4CLNT_LEASE_CONFIRM,
>>> 	NFS4CLNT_SERVER_SCOPE_MISMATCH,
>>> +	NFS4CLNT_BIND_CONN_TO_SESSION,
>>> };
>>>=20
>>> enum nfs4_session_state {
>>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>>> index 7f0fcfc..40558ca 100644
>>> --- a/fs/nfs/nfs4state.c
>>> +++ b/fs/nfs/nfs4state.c
>>> @@ -1639,13 +1639,20 @@ static void =
nfs41_handle_recallable_state_revoked(struct nfs_client *clp)
>>> 	nfs_expire_all_delegations(clp);
>>> }
>>>=20
>>> -static void nfs41_handle_cb_path_down(struct nfs_client *clp)
>>> +static void nfs41_handle_backchannel_fault(struct nfs_client *clp)
>>> {
>>> 	nfs_expire_all_delegations(clp);
>>> 	if (test_and_set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state) =3D=3D=
 0)
>>> 		nfs4_schedule_state_manager(clp);
>>> }
>>>=20
>>> +static void nfs41_handle_cb_path_down(struct nfs_client *clp)
>>> +{
>>> +	if (test_and_set_bit(NFS4CLNT_BIND_CONN_TO_SESSION,
>>> +		&clp->cl_state) =3D=3D 0)
>>> +		nfs4_schedule_state_manager(clp);
>>> +}
>>> +
>>> void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 =
flags)
>>> {
>>> 	if (!flags)
>>> @@ -1659,9 +1666,10 @@ void nfs41_handle_sequence_flag_errors(struct =
nfs_client *clp, u32 flags)
>>> 		nfs41_handle_state_revoked(clp);
>>> 	if (flags & SEQ4_STATUS_RECALLABLE_STATE_REVOKED)
>>> 		nfs41_handle_recallable_state_revoked(clp);
>>> -	if (flags & (SEQ4_STATUS_CB_PATH_DOWN |
>>> -			    SEQ4_STATUS_BACKCHANNEL_FAULT |
>>> -			    SEQ4_STATUS_CB_PATH_DOWN_SESSION))
>>> +	if (flags & SEQ4_STATUS_BACKCHANNEL_FAULT)
>>> +		nfs41_handle_backchannel_fault(clp);
>>> +	else if (flags & (SEQ4_STATUS_CB_PATH_DOWN |
>>> +				SEQ4_STATUS_CB_PATH_DOWN_SESSION))
>>> 		nfs41_handle_cb_path_down(clp);
>>> }
>>>=20
>>> @@ -1721,7 +1729,6 @@ static int nfs4_recall_slot(struct nfs_client =
*clp)
>>> 	nfs4_end_drain_session(clp);
>>> 	return 0;
>>> }
>>> -
>>> #else /* CONFIG_NFS_V4_1 */
>>> static int nfs4_reset_session(struct nfs_client *clp) { return 0; }
>>> static int nfs4_end_drain_session(struct nfs_client *clp) { return =
0; }
>>> @@ -1803,6 +1810,15 @@ static void nfs4_state_manager(struct =
nfs_client *clp)
>>> 				goto out_error;
>>> 		}
>>>=20
>>> +		/* Send BIND_CONN_TO_SESSION */
>>> +		if (clp->cl_mvops->minor_version =3D=3D 1 &&
>>> +		    test_and_clear_bit(NFS4CLNT_BIND_CONN_TO_SESSION,
>>> +				&clp->cl_state) && =
nfs4_has_session(clp)) {
>>> +			status =3D nfs4_proc_bind_conn_to_session(clp);
>>> +			if (status < 0)
>>> +				goto out_error;
>>> +		}
>>> +
>>> 		/* First recover reboot state... */
>>> 		if (test_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)) {
>>> 			status =3D nfs4_do_reclaim(clp,
>>=20
>> Committed after fixing ifndef CONFIG_NFS_V4_1 issues and adding a
>=20
> Ah, I actually did test with CONFIG_NFS_V4_1 undefined - it compiles, =
but you're right, this should be #ifdef'd

Oops, actually that was an older patch with a wrapper around =
nfs4_proc_bind_conn_to_session - I'll add it back.

-dros

>=20
>> clear_bit() for NFS4CLNT_BIND_CONN_TO_SESSION in nfs4_reset_session.
>=20
> Good catch.
>=20
> Thanks!
> -dros
>=20


--Apple-Mail=_D4F894A4-6AD8-476B-9CB1-B7C94AE55948
Content-Disposition: attachment; filename="smime.p7s"
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIDTzCCA0sw
ggIzoAMCAQICAQEwCwYJKoZIhvcNAQEFMEYxFzAVBgNVBAMMDldlc3RvbiBBZGFtc29uMQswCQYD
VQQGEwJVUzEeMBwGCSqGSIb3DQEJARYPZHJvc0BuZXRhcHAuY29tMB4XDTExMDYwODIyMDc0NloX
DTEyMDYwNzIyMDc0NlowRjEXMBUGA1UEAwwOV2VzdG9uIEFkYW1zb24xCzAJBgNVBAYTAlVTMR4w
HAYJKoZIhvcNAQkBFg9kcm9zQG5ldGFwcC5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
AoIBAQC8/tJxtovJEXYRfSsrFOWKHxIZGY7/2mBee1DpWuoGDbVNapefCC7WXe+Nqxz609w2J/Mk
/k3trZ3Ge2NXK0tGnP9NzjkzpGA7rSpM3wUFsvbLMUEGfQpvV24/nYvcLHTvOOEUaDPpHduN94bD
dwvyowzDIRIpF2MeRnOzBNeHkrGHlZdzPmGjm8tkhrDRRkDYHhlxaiG4z30KCfAazxomuINiy1kj
vbndXooYMDoh9H63hgW4NkOedtLdflLa322DXQ3nFU7YbyOIjHVl1tgWJLDWf7WT3lsAB8KvuJZ5
zhsUB+fqxCKPJVRPDO1gjChvvtGiG1tGUUZz0H9Wx00zAgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIH
gDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDBDAaBgNVHREEEzARgQ9kcm9zQG5ldGFwcC5jb20wDQYJ
KoZIhvcNAQEFBQADggEBACv0niZSmW+psB1sJXULh3mecDbN2mj0bFpN1YNdjcV7BiOLJ1Rs1ibV
f13h73z8C7SBsPXTM5si8gmJtOnXM5jsgtlql44h/RrjUr8+mtK5DPCZls9J7iz3cGthzwOPvxUj
nMSv3BpRX5oJom5ESgCM9Nn4u/ECTlLMhEIOYnBFiN0eDxcxz+r1cpbHg3r0otIKyxLpeaCjP6AH
F93EHp4T8Rb63y3CcDgxrQGHlTdVi3QvxaMUexUXD81fiA+UqsB/MKmRxB1Hs4Vf3Q/+ejcm78K1
ROF8TNPmNWRlKg3Y7cSFjZGzLuzXsvSsCbw4HLn0oZe/OfgSbarTAxttL5IxggHRMIIBzQIBATBL
MEYxFzAVBgNVBAMMDldlc3RvbiBBZGFtc29uMQswCQYDVQQGEwJVUzEeMBwGCSqGSIb3DQEJARYP
ZHJvc0BuZXRhcHAuY29tAgEBMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcB
MBwGCSqGSIb3DQEJBTEPFw0xMjA1MjQyMTA3MTVaMCMGCSqGSIb3DQEJBDEWBBQtc4F0D4m4H6N/
0YsjS/cltJyK2jANBgkqhkiG9w0BAQEFAASCAQCqscYUCg7SuWOmmuFoUU79/m7BKQS/8JHbCol1
7pkJeftSroQhYBgjwkoabGjMXxNHKxO7seNEFOWG1OmzmQbvwk1/TnZ91Sqpr+e1s8EMNzgHPaif
GEOexzHgFJ+Dyd1foGBFlknlUDkILuImgKEbjHKqd4gMh38P5iUeTv5VDq2sMM58jQtpF1q06EEy
fvTkTCxcjHsx3fDGwiJqkNGZrHZHWpYFW6Ygps8VJnBNH0fBeiYgjoOkKVQ7rb2/3MTvJgj3bPCR
GHv8e6ylHsFaJhLXqEPl1ck4ZPN6Kv2qibBSlMQwhohDu9wqRWaJYkUbKoQtPlGU0YA8lJomnZ6p
AAAAAAAA

--Apple-Mail=_D4F894A4-6AD8-476B-9CB1-B7C94AE55948--
