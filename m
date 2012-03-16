Return-Path: linux-nfs-owner@vger.kernel.org
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:51699 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801Ab2CPKyS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2012 06:54:18 -0400
Message-ID: <4F631BA0.7010300@pb.jp.nec.com>
Date: Fri, 16 Mar 2012 19:53:20 +0900
From: Ichiko Sakamoto <i-sakamoto@pb.jp.nec.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
CC: frankvm@frankvm.com, Trond.Myklebust@netapp.com, bfields@fieldses.org
Subject: Re: [NLM] fcntl(F_SETLKW) yields -ENOLCK when grace period expires.
References: <20110804103018.GA11727@janus> <20110804163452.GE12445@fieldses.org> <20110804164313.GA17572@janus> <20110804164913.GG12445@fieldses.org> <1312477820.8919.5.camel@lade.trondhjem.org> <20110804172710.GB18087@janus> <1312481855.8919.20.camel@lade.trondhjem.org> <20110805132823.GA32305@janus>
In-Reply-To: <20110805132823.GA32305@janus>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms020500040402090603010500"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms020500040402090603010500
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

(2011/08/05 22:28), Frank van Maarseveen wrote:

> On Thu, Aug 04, 2011 at 02:17:35PM -0400, Trond Myklebust wrote:
>> On Thu, 2011-08-04 at 19:27 +0200, Frank van Maarseveen wrote:=20
>> > On Thu, Aug 04, 2011 at 01:10:20PM -0400, Trond Myklebust wrote:
>> > > On Thu, 2011-08-04 at 12:49 -0400, J. Bruce Fields wrote:=20
>> > > > On Thu, Aug 04, 2011 at 06:43:13PM +0200, Frank van Maarseveen w=
rote:
>> > > > > On Thu, Aug 04, 2011 at 12:34:52PM -0400, J. Bruce Fields wrot=
e:
>> > > > > > On Thu, Aug 04, 2011 at 12:30:19PM +0200, Frank van Maarseve=
en wrote:
>> > > > > > > Both client- and server run 2.6.39.3, NFSv3 over UDP (with=
out the
>> > > > > > > relock_filesystem patch proposed earlier).
>> > > > > > >=20
>> > > > > > > A second client has an exclusive lock on a file on the ser=
ver. The
>> > > > > > > client under test calls fcntl(F_SETLKW) to wait for the sa=
me exclusive
>> > > > > > > lock. Wireshark sees NLM V4 LOCK calls resulting in NLM_BL=
OCKED.
>> > > > > > >=20
>> > > > > > > Next the server is rebooted. The second client recovers th=
e lock
>> > > > > > > correctly. The client under test now receives NLM_DENIED_G=
RACE_PERIOD for
>> > > > > > > every NLM V4 LOCK request resulting from the waiting fcntl=
(F_SETLKW). When
>> > > > > > > this changes to NLM_BLOCKED after grace period expiration =
the fcntl
>> > > > > > > returns -ENOLCK ("No locks available.") instead of continu=
ing to wait.
>> > > > > >=20
>> > > > > > So that sounds like a client bug, and correct behavior from =
the server
>> > > > > > (assuming the second client was still holding the lock throu=
ghout).
>> > > > >=20
>> > > > > yes.
>> > >=20
>> > > Is the client actually asking for a blocking lock after the grace =
period
>> > > expires?
>> >=20
>> > yes, according to my interpretation of that of wireshark, see reply =
to Bruce.
>> >=20
>>=20
>> OK... Does the following patch help?
>>=20
>> Cheers
>>   Trond
>> ---=20
>> diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
>> index 8392cb8..40c0d88 100644
>> --- a/fs/lockd/clntproc.c
>> +++ b/fs/lockd/clntproc.c
>> @@ -270,6 +270,9 @@ nlmclnt_call(struct rpc_cred *cred, struct nlm_rqs=
t *req, u32 proc)
>>  			return -ENOLCK;
>>  		msg.rpc_proc =3D &clnt->cl_procinfo[proc];
>> =20
>> +		/* Reset the reply status */
>> +		if (argp->block)
>> +			resp->status =3D nlm_lck_blocked;
>>  		/* Perform the RPC call. If an error occurs, try again */
>>  		if ((status =3D rpc_call_sync(clnt, &msg, 0)) < 0) {
>>  			dprintk("lockd: rpc_call returned error %d\n", -status);
>>=20
>=20
> Negative. I've tried it on the client under test and I'm seeing three
> types of behavior, one good, two bad. In all cases the secondary
> client (unmodified) correctly regains the lock after the server has
> rebooted. Client under test behavior depends on whether it had queued
> the conflicting lock before of after the server reboot. Afterwards it
> seems to work with the above modification (don't know if that was the
> case before though).
>=20
> When the client under test tries to lock before the server reboot then
> the fcntl(F_SETLKW) returns either right after the NSM NOTIFY with
> -ENOLCK without any NLM trafic or it returns with -ENOLCK when the
> NLM_DENIED_GRACE_PERIOD changes into NLM_BLOCKED (the original report).=

>=20




Hi all

Was this fixed?
I have same issue in 3.2.9-2.fc16.

When the client recieves NSM NOTIFY, reclaimer() thread updates
block->b_status to nlm_lck_denied_grace_period.

fs/lockd/clntlock.c
      265        /* Now, wake up all processes that sleep on a blocked lo=
ck */
      266        spin_lock(&nlm_blocked_lock);
      267        list_for_each_entry(block, &nlm_blocked, b_list) {
      268                if (block->b_host =3D=3D host) {
   *  269                        block->b_status =3D nlm_lck_denied_grace=
_period;
      270                        wake_up(&block->b_wait);
      271                }
      272        }
      273        spin_unlock(&nlm_blocked_lock);

Blocked process loops inside nlmclnt_call() during grace period,
and recieves NLM_BLOCKED again.
Then nlmclnt_block() copies block->b_status(=3D=3D nlm_lck_denied_grace_p=
eriod)
to req->a_res.status.

fs/lockd/clntlock.c
      139        ret =3D wait_event_interruptible_timeout(block->b_wait,
      140                        block->b_status !=3D nlm_lck_blocked,
      141                        timeout);
      142        if (ret < 0)
      143                return -ERESTARTSYS;
   *  144        req->a_res.status =3D block->b_status;
      145        return 0;

=2E. and nlmclnt_lock() breaks retry loop and returns -ENOLCK.

fs/lockd/clntproc.c
      550                /* Wait on an NLM blocking lock */
      551                status =3D nlmclnt_block(block, req, NLMCLNT_POL=
L_TIMEOUT);
      552                if (status < 0)
      553                        break;
   *  554                if (resp->status !=3D nlm_lck_blocked)
   *  555                        break;
      556        }
      ...
      590        if (resp->status =3D=3D nlm_lck_denied && (fl_flags & FL=
_SLEEP))
      591                status =3D -ENOLCK;
      592        else
   *  593                status =3D nlm_stat_to_errno(resp->status);
      594out_unblock:
      595        nlmclnt_finish_block(block);
      596out:
      597        nlmclnt_release_call(req);
   *  598        return status;



Following patch works fine in my fc16.

--- a/fs/lockd/clntlock.c	2012-01-04 23:55:44.000000000 +0000
+++ b/fs/lockd/clntlock.c	2012-03-16 08:08:03.793687409 +0000
@@ -121,6 +121,7 @@
 int nlmclnt_block(struct nlm_wait *block, struct nlm_rqst *req, long tim=
eout)
 {
 	long ret;
+	u32 nsmstate;

 	/* A borken server might ask us to block even if we didn't
 	 * request it. Just say no!
@@ -136,8 +137,10 @@
 	 * a 1 minute timeout would do. See the comment before
 	 * nlmclnt_lock for an explanation.
 	 */
+	nsmstate =3D block->b_host->h_nsmstate;
 	ret =3D wait_event_interruptible_timeout(block->b_wait,
-			block->b_status !=3D nlm_lck_blocked,
+			block->b_status !=3D nlm_lck_blocked ||
+			block->b_host->h_nsmstate !=3D nsmstate,
 			timeout);
 	if (ret < 0)
 		return -ERESTARTSYS;
@@ -266,7 +269,6 @@
 	spin_lock(&nlm_blocked_lock);
 	list_for_each_entry(block, &nlm_blocked, b_list) {
 		if (block->b_host =3D=3D host) {
-			block->b_status =3D nlm_lck_denied_grace_period;
 			wake_up(&block->b_wait);
 		}
 	}


Thanks,
Ichiko



--------------ms020500040402090603010500
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIQJjCC
BUAwggQooAMCAQICEB5xC5Tr2SLHRjdW/S0bOFkwDQYJKoZIhvcNAQEFBQAwdTELMAkGA1UE
BhMCSlAxHDAaBgNVBAoTE1ZlcmlTaWduIEphcGFuIEsuSy4xHzAdBgNVBAsTFlZlcmlTaWdu
IFRydXN0IE5ldHdvcmsxJzAlBgNVBAMTHlZlcmlTaWduIEphcGFuIENsYXNzIDIgQ0EgLSBH
MzAeFw0xMDA3MTMwMDAwMDBaFw0xNTA3MTIyMzU5NTlaMIHmMRgwFgYDVQQKEw9ORUMgQ29y
cG9yYXRpb24xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5ldHdvcmsxPTA7BgNVBAsTNFRl
cm1zIG9mIHVzZSBhdCBodHRwczovL3d3dy52ZXJpc2lnbi5jby5qcC9ycGEgKGMpMTAxNTAz
BgNVBAsTLENsYXNzIDIgTWFuYWdlZCBQS0kgSW5kaXZpZHVhbCBTdWJzY3JpYmVyIENBMTMw
MQYDVQQDEypORUMgR3JvdXAgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkgU01JTUUgRzMwggEi
MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDIAjcVU7wGh80MEYAniKavfxPldEJN+V2J
BIV/7v//uxfwdLxV8rB97NzksefWPsGt4otZ1yOJuiXqfQBpNweo38o7s9Oc9u5g50VKGoS7
BFZDz3bOiaMZyYj/JykFUJ4hNrS7uoLQS966xKtAHnpC1p00YG6GGQHLsHEH/D/jB/Fn2HGM
urrA53nTEmoGp0bPZ8kL8ylYbSAzSIQezyd1Ad9IpchJmevi+BnDuQcWVs1SaRWsyv6x7UFB
22Npu4/u31UkcVAUdkLfY6TZ6dgGcM/hKrA8Jv3mTg+8CcS7M4abwWXybwAEb1fCYWYFIpp6
KqZu0nweT+zPt+m4Un0RAgMBAAGjggFYMIIBVDASBgNVHRMBAf8ECDAGAQH/AgEAMHQGA1Ud
IARtMGswaQYLYIZIAYb4RQEHFwIwWjAqBggrBgEFBQcCARYeaHR0cHM6Ly93d3cudmVyaXNp
Z24uY28uanAvY3BzMCwGCCsGAQUFBwICMCAaHmh0dHBzOi8vd3d3LnZlcmlzaWduLmNvLmpw
L3JwYTA+BgNVHR8ENzA1MDOgMaAvhi1odHRwOi8vY3JsLnZlcmlzaWduLmNvLmpwL1ZTSl9D
MkNBX0czX0NSTC5jcmwwDgYDVR0PAQH/BAQDAgEGMBEGCWCGSAGG+EIBAQQEAwIBBjAlBgNV
HREEHjAcpBowGDEWMBQGA1UEAxMNQzFDMi0xLTIwNDgtNzAdBgNVHQ4EFgQUVUTm7xNUKXhJ
3nryFFuzXgRLRKUwHwYDVR0jBBgwFoAUqMqaBMESsm7NDzu6TvWTa0U3DUQwDQYJKoZIhvcN
AQEFBQADggEBAB45xavDpQE9Ci5K+HfwETKjlXmlo9YIEPIdYf91hOkLueruVUSkSh8jbvzO
5Zla9X1lcJxuItMwYuzBiIBMEYT0UwzqHiCoygqGyW9LYeseqynh3Ft1sI+k7n0hSuHo+JfI
+KQqFQQ8BtZ3Uoq3+RfBS/tvb8nTQ5oJ3dQtXgzYVbOweTBUvqNvKHhT23H+I3qsBlm/Z+96
qWywpBbOBzCujAH9q2ZI5RxyMuyHky10Ji49fNN5YL4Wy+4w7Z3jbxZtd49L2kBKJ4hGXeCf
VfEkBc3Y5iOn0RYYZ2DT7lp2tu60Q2z2+zqrG1+TB/f474DIFaO/7vx+gQmZYrB5Z7swggVc
MIIERKADAgECAhByFYwPA+3E5TkxFZazttI2MA0GCSqGSIb3DQEBBQUAMIHmMRgwFgYDVQQK
Ew9ORUMgQ29ycG9yYXRpb24xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5ldHdvcmsxPTA7
BgNVBAsTNFRlcm1zIG9mIHVzZSBhdCBodHRwczovL3d3dy52ZXJpc2lnbi5jby5qcC9ycGEg
KGMpMTAxNTAzBgNVBAsTLENsYXNzIDIgTWFuYWdlZCBQS0kgSW5kaXZpZHVhbCBTdWJzY3Jp
YmVyIENBMTMwMQYDVQQDEypORUMgR3JvdXAgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkgU01J
TUUgRzMwHhcNMTIwMjAxMDAwMDAwWhcNMTQwMTMxMjM1OTU5WjCB7DEYMBYGA1UEChQPTkVD
IENvcnBvcmF0aW9uMTMwMQYDVQQLFCpORUMgR3JvdXAgQ2VydGlmaWNhdGlvbiBBdXRob3Jp
dHkgU01JTUUgRzMxNTAzBgNVBAsTLFRlcm1zIG9mIHVzZSBhdCB3d3cudmVyaXNpZ24uY28u
anAvcnBhIChjKTEwMTswOQYDVQQDEzJJY2hpa291IFNha2Ftb3RvICgxMjAyMDIgaS1zYWth
bW90by5wYi5qcC5uZWMuY29tKTEnMCUGCSqGSIb3DQEJARYYaS1zYWthbW90b0BwYi5qcC5u
ZWMuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAt/9+IRJyPONae0FAqSEZ
5h26J+da4L+/1AO49Qrx2B3mSb5Sdzw6gT8TA+Hev1DC4DixxnmaBLduZ2AY25Pj63E1glOq
f5Ty5E0/4Ak84HHEamCshokFyqNAAZqIJWQ3a8yPIvZ+SMKqgL++BgjmqKBH+MeZ3bFVl0AO
/pqDz6ZfeHUbjki1tcFzFH59aAyu4FNqZBdEDnQAmmRjtRB4blMNeVb27rWztFgweV8vilZZ
JQImQsbN6Iu65Q7eig5IcTrs5QRpBRJQosXYn2LHrhTg0STWLiUnwU1FRNGF/CX0LQUJ/Hjv
QeZsC3EsZokLwC8BcJd/anmUlzb+ZN5AyQIDAQABo4H9MIH6MAkGA1UdEwQCMAAwCwYDVR0P
BAQDAgWgMHIGA1UdHwRrMGkwZ6BloGOGYWh0dHA6Ly9vbnNpdGVjcmwudmVyaXNpZ24uY28u
anAvTkVDQ29ycG9yYXRpb25ORUNHcm91cENlcnRpZmljYXRpb25BdXRob3JpdHlTTUlNRUcz
L0xhdGVzdENSTC5jcmwwRgYDVR0gBD8wPTA7BgtghkgBhvhFAQcXAjAsMCoGCCsGAQUFBwIB
Fh5odHRwczovL3d3dy52ZXJpc2lnbi5jby5qcC9ycGEwEQYJYIZIAYb4QgEBBAQDAgUgMBEG
CmCGSAGG+EUBBgkEAwEB/zANBgkqhkiG9w0BAQUFAAOCAQEAotyjbOUcVuecQRdVMoFGenYL
zR/clGv2O7+4LDK/cEaddNOVIiyB6WqXrN4131lgJJVQBTfAQiNG/ipk4tNEXaHmBPUnFApS
VLK+Bx+wbJ9mvDg2C3HxDQKx3WPMGBEbChYiJyhE77QnIyhj0Nr09z7Zs0evhUNKeWM0ZF1T
67jhO3UfU7P3IkPxkfY8ZZK1GAijAtnxo1V86NmiPG7OdBY0q1LCHMs60kVS0620nZ+sEtZN
zMY/l4ZRu8tCGv1uo41fBVvI9jOBx3nS5ltlCPlnZv2ze9DZHIjXej4Mx3mBVt9nZcvX/dDg
RA4Lg4a8XDFUI+ICfDsCtqySeybK3zCCBX4wggRmoAMCAQICEBpIcj/rc3NU4lelPuDrKncw
DQYJKoZIhvcNAQEFBQAwgcoxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5WZXJpU2lnbiwgSW5j
LjEfMB0GA1UECxMWVmVyaVNpZ24gVHJ1c3QgTmV0d29yazE6MDgGA1UECxMxKGMpIDE5OTkg
VmVyaVNpZ24sIEluYy4gLSBGb3IgYXV0aG9yaXplZCB1c2Ugb25seTFFMEMGA1UEAxM8VmVy
aVNpZ24gQ2xhc3MgMiBQdWJsaWMgUHJpbWFyeSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eSAt
IEczMB4XDTA5MDQyODAwMDAwMFoXDTE5MDQyNzIzNTk1OVowdTELMAkGA1UEBhMCSlAxHDAa
BgNVBAoTE1ZlcmlTaWduIEphcGFuIEsuSy4xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5l
dHdvcmsxJzAlBgNVBAMTHlZlcmlTaWduIEphcGFuIENsYXNzIDIgQ0EgLSBHMzCCASIwDQYJ
KoZIhvcNAQEBBQADggEPADCCAQoCggEBALcNV/RvqW7RBXB0Qt0YKyAJ/CIhvNu6Yb+rKUv1
JzOBMJ1qwoOVkJlXN8DZjgo5Yy1Pw7vIe2dJqnFsbBhCA6VQjFKtcdWTc1QdFvo00HVFjaBH
Mad1LphBpPTLDrevTvn9L/OJ530Mr/gWW5R3k2vvAUqNz1dSUwNAvdXsEIdRKeZm8C68Xjxe
Qj+3d87NBgftTst+DOijA7dGYnp4/yOxpcEdxp/NeSzK4viOmvodLLIF2M89GEH9fZqTN8B0
K3czNVA+TZGnu030bRmwxua1Fv7nHgsI9RnsDWS5LnODGz/PmvZNGkkAahC4Csup8PGWXq+y
JF82rfd7Al4qVQMCAwEAAaOCAbIwggGuMA8GA1UdEwEB/wQFMAMBAf8wGAYDVR0gBBEwDzAN
BgtghkgBhvhFAQcXAjA0BgNVHR8ELTArMCmgJ6AlhiNodHRwOi8vY3JsLnZlcmlzaWduLmNv
bS9wY2EyLWczLmNybDAOBgNVHQ8BAf8EBAMCAQYwKQYDVR0RBCIwIKQeMBwxGjAYBgNVBAMT
EUFmZlNDQzItMjA0OC0xLTQyMB0GA1UdDgQWBBSoypoEwRKybs0PO7pO9ZNrRTcNRDCB8AYD
VR0jBIHoMIHloYHQpIHNMIHKMQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIElu
Yy4xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5ldHdvcmsxOjA4BgNVBAsTMShjKSAxOTk5
IFZlcmlTaWduLCBJbmMuIC0gRm9yIGF1dGhvcml6ZWQgdXNlIG9ubHkxRTBDBgNVBAMTPFZl
cmlTaWduIENsYXNzIDIgUHVibGljIFByaW1hcnkgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkg
LSBHM4IQYXDLSYxfmEUp57Cm2VBbejANBgkqhkiG9w0BAQUFAAOCAQEAbKGMhOQJiwEF+ASm
ihe+tC6kQ8R7xQW4NyJ8up6yBEXBxHjScN60erAERiJH0uMohKT+do2+imCuS9BBoLM6geR5
2X+oPMgDN5LunQj1YB1jPmksastf5YJvjXlX+KFgLM0QJYwBnCo5mxd5qnCewZjUzZnMTVl2
9u7FDJM/ERt2P3o646lMzTHoz8+N75MAyT9cjC4151hMv8oehCemoN8xrfuopdY+xozTPGxT
QiiBPKLIFbpApxQ3pV2oSR93SD0IBnFIabwvW/b4CQeZgNYLF2mJqC+qi5KbLC2kQwHuok6K
dh9luLfDYGjQ9XzxaKb+M/kgokxErlIXHdKYRTGCBQcwggUDAgEBMIH7MIHmMRgwFgYDVQQK
Ew9ORUMgQ29ycG9yYXRpb24xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5ldHdvcmsxPTA7
BgNVBAsTNFRlcm1zIG9mIHVzZSBhdCBodHRwczovL3d3dy52ZXJpc2lnbi5jby5qcC9ycGEg
KGMpMTAxNTAzBgNVBAsTLENsYXNzIDIgTWFuYWdlZCBQS0kgSW5kaXZpZHVhbCBTdWJzY3Jp
YmVyIENBMTMwMQYDVQQDEypORUMgR3JvdXAgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkgU01J
TUUgRzMCEHIVjA8D7cTlOTEVlrO20jYwCQYFKw4DAhoFAKCCAuAwGAYJKoZIhvcNAQkDMQsG
CSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTIwMzE2MTA1MzIwWjAjBgkqhkiG9w0BCQQx
FgQUgblZ+8bZ5PYb4RozNC96MyBd7uAwXwYJKoZIhvcNAQkPMVIwUDALBglghkgBZQMEAQIw
CgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcGBSsOAwIHMA0G
CCqGSIb3DQMCAgEoMIIBDAYJKwYBBAGCNxAEMYH+MIH7MIHmMRgwFgYDVQQKEw9ORUMgQ29y
cG9yYXRpb24xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5ldHdvcmsxPTA7BgNVBAsTNFRl
cm1zIG9mIHVzZSBhdCBodHRwczovL3d3dy52ZXJpc2lnbi5jby5qcC9ycGEgKGMpMTAxNTAz
BgNVBAsTLENsYXNzIDIgTWFuYWdlZCBQS0kgSW5kaXZpZHVhbCBTdWJzY3JpYmVyIENBMTMw
MQYDVQQDEypORUMgR3JvdXAgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkgU01JTUUgRzMCEHIV
jA8D7cTlOTEVlrO20jYwggEOBgsqhkiG9w0BCRACCzGB/qCB+zCB5jEYMBYGA1UEChMPTkVD
IENvcnBvcmF0aW9uMR8wHQYDVQQLExZWZXJpU2lnbiBUcnVzdCBOZXR3b3JrMT0wOwYDVQQL
EzRUZXJtcyBvZiB1c2UgYXQgaHR0cHM6Ly93d3cudmVyaXNpZ24uY28uanAvcnBhIChjKTEw
MTUwMwYDVQQLEyxDbGFzcyAyIE1hbmFnZWQgUEtJIEluZGl2aWR1YWwgU3Vic2NyaWJlciBD
QTEzMDEGA1UEAxMqTkVDIEdyb3VwIENlcnRpZmljYXRpb24gQXV0aG9yaXR5IFNNSU1FIEcz
AhByFYwPA+3E5TkxFZazttI2MA0GCSqGSIb3DQEBAQUABIIBAE0DD+VBqgjw8+cM7eOQYp9V
wD9c7bhR7V1djRUrkHxjL/2pnTF6pN2snS6xhvl10SNlsoJRO9S6TTji79K+c95k0Sa44mwT
PPe923J5qWPtAun+JZ53g73c4ly/dwTtKyOV3WZJJQoBHjO5OwPx9zgSMFqTvjTYw1fcenUl
GVCDgq4uj5A+dBySu7JYLW6qbOpp/Xwx7k3czpS3/q9/fzvTsNjZIfHyg02AFduKi+wiqC95
EcPRUQMy55MZ8M30jEq+MQvENfHYd7lsCuUulycaF1fQrQACJ3a3ml1h7Wxlh8ZoklpY4kOu
eQ1dsJTENZopubCoXs4HfpECL4H8ZzgAAAAAAAA=
--------------ms020500040402090603010500--
