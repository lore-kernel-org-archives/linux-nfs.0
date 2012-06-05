Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:11329 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752224Ab2FEUrF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jun 2012 16:47:05 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfsd: add fault injection for CB_PATH_DOWN
Date: Tue, 5 Jun 2012 20:47:03 +0000
Message-ID: <E2A350B8-2A19-460B-AA2F-67A75EECC4A9@netapp.com>
References: <1337888537-21754-1-git-send-email-dros@netapp.com>
 <20120605201909.GA27061@fieldses.org>
In-Reply-To: <20120605201909.GA27061@fieldses.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_6D262429-06D0-47B4-BD6C-A779F130856B";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_6D262429-06D0-47B4-BD6C-A779F130856B
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Jun 5, 2012, at 4:19 PM, J. Bruce Fields wrote:

> On Thu, May 24, 2012 at 03:42:16PM -0400, Weston Andros Adamson wrote:
>> This fault injection hook causes all SEQUENCE operation replies to =
have the
>> SEQ4_STATUS_CB_PATH_DOWN flag set until the client calls =
BIND_CONN_TO_SESSION
>> or creates a new session.
>=20
> I'm not necessarily opposed, but why do you need this?  In what
> "real-life" situation could a client see the CB_PATH_DOWN flag
> unexpectedly set?

We need this to test the client's handling of the =
SEQ4_STATUS_CB_PATH_DOWN flag :)

Real world scenarios are hard to come by at this point since the linux =
client always uses one TCP connection (for both fore and back channel), =
but handling this error condition should be useful for future work =
(session trunking, if the client ever uses a different connection for =
back channel).
Also, if nfsd's probe callback fails for whatever reason the =
CB_PATH_DOWN flag will be set.

Really, we want the client to be able to handle this error condition and =
this was the easiest way to test it.

-dros

>=20
> --b.
>=20
>>=20
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> fs/nfsd/fault_inject.c |    4 ++++
>> fs/nfsd/fault_inject.h |    2 ++
>> fs/nfsd/nfs4state.c    |   20 ++++++++++++++++++++
>> 3 files changed, 26 insertions(+), 0 deletions(-)
>>=20
>> diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
>> index e6c3815..ab81144 100644
>> --- a/fs/nfsd/fault_inject.c
>> +++ b/fs/nfsd/fault_inject.c
>> @@ -38,6 +38,10 @@ static struct nfsd_fault_inject_op inject_ops[] =3D =
{
>> 		.file   =3D "recall_delegations",
>> 		.func   =3D nfsd_recall_delegations,
>> 	},
>> +	{
>> +		.file   =3D "kill_backchannel",
>> +		.func   =3D nfsd_kill_backchannel,
>> +	},
>> };
>>=20
>> static long int NUM_INJECT_OPS =3D sizeof(inject_ops) / sizeof(struct =
nfsd_fault_inject_op);
>> diff --git a/fs/nfsd/fault_inject.h b/fs/nfsd/fault_inject.h
>> index 90bd057..b058e03 100644
>> --- a/fs/nfsd/fault_inject.h
>> +++ b/fs/nfsd/fault_inject.h
>> @@ -15,6 +15,7 @@ void nfsd_forget_locks(u64);
>> void nfsd_forget_openowners(u64);
>> void nfsd_forget_delegations(u64);
>> void nfsd_recall_delegations(u64);
>> +void nfsd_kill_backchannel(u64);
>> #else /* CONFIG_NFSD_FAULT_INJECTION */
>> static inline int nfsd_fault_inject_init(void) { return 0; }
>> static inline void nfsd_fault_inject_cleanup(void) {}
>> @@ -23,6 +24,7 @@ static inline void nfsd_forget_locks(u64 num) {}
>> static inline void nfsd_forget_openowners(u64 num) {}
>> static inline void nfsd_forget_delegations(u64 num) {}
>> static inline void nfsd_recall_delegations(u64 num) {}
>> +static inline void nfsd_kill_backchannel(u64 num) {}
>> #endif /* CONFIG_NFSD_FAULT_INJECTION */
>>=20
>> #endif /* LINUX_NFSD_FAULT_INJECT_H */
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 21266c7..9afc902 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -4737,6 +4737,26 @@ void nfsd_recall_delegations(u64 num)
>> 	printk(KERN_INFO "NFSD: Recalled %d delegations", count);
>> }
>>=20
>> +/*
>> + * Force SEQUENCE operations to have SEQ4_STATUS_CB_PATH_DOWN flag =
set
>> + * until backchannel is reestablished by BIND_CONN_TO_SESSION or
>> + * DESTROY_SESSION/CREATE_SESSION with SP4_NONE.
>> + *
>> + * The argument 'num' is ignored, any value will trigger the fault =
on
>> + * all clients.
>> + */
>> +void nfsd_kill_backchannel(u64 num)
>> +{
>> +	struct nfs4_client *clp, *next;
>> +
>> +	nfs4_lock_state();
>> +	list_for_each_entry_safe(clp, next, &client_lru, cl_lru) {
>> +		clp->cl_cb_state =3D NFSD4_CB_DOWN;
>> +	}
>> +	nfs4_unlock_state();
>> +
>> +	printk(KERN_INFO "NFSD: killed backchannel");
>> +}
>> #endif /* CONFIG_NFSD_FAULT_INJECTION */
>>=20
>> /* initialization to perform at module load time: */
>> --=20
>> 1.7.4.4
>>=20


--Apple-Mail=_6D262429-06D0-47B4-BD6C-A779F130856B
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA2MDUyMDQ3MDZaMCMGCSqGSIb3DQEJBDEWBBQY2T+TeBzN8x69
OEgbfbweTtSWYzANBgkqhkiG9w0BAQEFAASCAQBGYsQ8Kh0h1zRNOQJqhaigGxRr4kFR/fvv+Yvw
X0wdgyebrKx63LKiQgGYgWGMTA8whMkRnpWCk7LQ7LPhXg9YAYtjv+7z0dmt65dEYUvUZEyHddP6
g/HVPsaTAtYhy3NvyRXwN1Xqiwz6qPWUnhN8n7xg+Nc0Y04023p74FYCELNmxC1MJSpA0QIe1iLl
BFtWW1yYTV9Z92rTJ406GFwiUUPtZD4tBIJbMORwFbsh2akh3YynXMJ4QJmNicfR0oEBYafw1T7m
hqrz2sfvVkh7MHfvEDnZjlPz62SyJ+x7QFRPJk+n4zsQicmaQqNETzP/E4RdJa4OgDLHTUgyyh+j
AAAAAAAA

--Apple-Mail=_6D262429-06D0-47B4-BD6C-A779F130856B--
