Return-Path: linux-nfs-owner@vger.kernel.org
Received: from postout1.mail.lrz.de ([129.187.255.137]:34496 "EHLO
	postout1.mail.lrz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755491Ab3IMLca (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Sep 2013 07:32:30 -0400
Message-ID: <5232F7DF.5080204@tum.de>
Date: Fri, 13 Sep 2013 13:32:47 +0200
From: Joschi Brauchle <joschi.brauchle@tum.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfsd4: utime sometimes takes 40+ seconds to return (but on SLES11SP3
 with kernel 3.0.82)
References: <522F69A1.5090005@tum.de> <20130910203530.GA20296@fieldses.org> <038EA8B0-BD46-47F2-8F20-DEC8B6DA9087@tum.de> <20130910215534.GA21829@fieldses.org> <D10808DE-57A1-4C80-8000-2F9E27A423A3@tum.de> <20130910221146.GB21829@fieldses.org>
In-Reply-To: <20130910221146.GB21829@fieldses.org>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms090308000207030803030207"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms090308000207030803030207
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable


On 09/11/2013 12:11 AM, J. Bruce Fields wrote:
> On Tue, Sep 10, 2013 at 10:08:36PM +0000, Joschi Brauchle wrote:
>> Am 10.09.2013 um 23:55 schrieb "J. Bruce Fields" <bfields@fieldses.org=
>:
>>
>>> On Tue, Sep 10, 2013 at 09:48:12PM +0000, Joschi Brauchle wrote:
>>>> Am 10.09.2013 um 22:35 schrieb "J. Bruce Fields" <bfields@fieldses.o=
rg>:
>>>>
>>>>> On Tue, Sep 10, 2013 at 08:49:05PM +0200, Joschi Brauchle wrote:
>>>>>> Hello everyone,
>>>>>>
>>>>>> we are administrating an NFS high-availability cluster running on
>>>>>> SLES11SP1 with kernel 2.6.32.59. Just recently, one of the cluster=

>>>>>> machines was updated to SLES11SP3 with kernel 3.0.82.
>>>>>>
>>>>>>
>>>>>> We are now experiencing severe hangs on NFS clients when the
>>>>>> SLES11SP3 server is running the NFS services. An strace on the
>>>>>> hanging processes on the client side show that is is waiting up to=

>>>>>> 60+ seconds for a "utime()" call to complete.
>>>>>>
>>>>>>
>>>>>> The problem we see is matching the problem described in the thread=

>>>>>> "v3.5 nfsd4 regression; utime sometimes takes 40+ seconds to
>>>>>> return". If the NFS server is running on SLES11SP3, the little tes=
t
>>>>>> program provided in this tread hangs at the "utime()" call for 60+=

>>>>>> seconds. It hangs each time it is run! It finishes right away with=
 0
>>>>>> seconds delay is SLES11SP1 is providing NFS services, each time.
>>>>>>
>>>>>>
>>>>>> Now, in the serverside logfiles of SLES11SP3 we see these messages=

>>>>>> (not so on SP1):
>>>>>> --------------
>>>>>> kernel: [99381.184976] RPC: AUTH_GSS upcall timed out.
>>>>>> kernel: [99381.184978] Please check user daemon is running.
>>>>>> --------------
>>>>>>
>>>>>> We have always been running the NFS server without rpc.gssd on the=

>>>>>> server side, as the init script for the nfsserver also does not
>>>>>> start rpc.gssd.
>>>>>>
>>>>>>
>>>>>> Once we started rpc.gssd on the SLES11SP3 server, using the test
>>>>>> utility on the client shows that the first call to "utime()"
>>>>>> succeeds right away, the second call takes ~25s to complete. But
>>>>>> now, any consecutive runs of the utility finish with no more delay=
=2E
>>>>>>
>>>>>>
>>>>>> So can anyone confirm that with kernel 3.0+ the rpc.gssd daemon is=

>>>>>> also required on the server side for correct operation?
>>>>>>
>>>>>> Has there been a change between kernel 2.6.32.59 and 3.0.x?
>>>>>>
>>>>>> Thus, is the init script of the nfsserver in SLES11SP3 indeed
>>>>>> missing to start rpc.gssd?
>>>>>
>>>>> It should be starting rpc.gssd to allow callbacks, yes.
>>>>>
>>>>> --b.
>>>>
>>>> Ok, we will run rpc.gssd on the server. Thanks.
>>>>
>>>> Could you please comment on having the nfs clients hang on utime() c=
alls is to be expected when *not* running rpc.gssd? Or is this a problem =
that needs to be investigated?
>>>
>>> I think what happens is the utime call breaks a delegation, and the
>>> delay is because the lack of gssd prevents the server from calling ba=
ck
>>> to the client to tell it that its delegation is broken, so the
>>> delegation has to time out.
>>>
>>> That said, the server does a null callback to the client to test whet=
her
>>> callbacks are working before it gives out any delegations, so I'm
>>> surprised it wouldn't have noticed the broken callbacks then.
>>>
>>> --b.
>>
>> Is there any information I can provide to figure this out? At what tim=
e is the null callback sent to the client? Maybe I can tcpdump that seque=
nce...
>
> It happens when the client sends a SETCLIENTID, which I think will be
> the first time it opens a file.  Running "rpcdebug -m nfsd -s proc" on
> the server and then looking in the logs afterwards might also be
> enlightening.
>
> --b.
>

After three days of testing the NFS server *with* rpc.gssd running with=20
multiple NFS clients, we made the following observation:

The hangs on "utime()" calls have **not** disappeared by simply starting
rpc.gssd on the server. The problem persists!

I seems like
a) on machines that are already connected to the NFS server when=20
rpc.gssd is started, the hangs dissappear *mostly*. That is, running the =

utime-test-program causes about 1 spurious hang every 10 minutes.
b) on machines that connect to the NFS server at a later time (rpc.gssd=20
already running on the server), the hangs seem appear  every "utime()"=20
call.

The server emits spurious "RPC: AUTH_GSS upcall timed out. Please check=20
user daemon is running." messages, although rpc.gssd is running. This=20
may or may not be related, as this message may also be caused by clients =

where the root user access NFS shared with a "host/<hostname>" credential=
=2E

The output of "rpcdebug -m nfsd -s proc" to pastebin.com. Get it with
pbget http://pastebin.com/N34r5kWE

The IP of the newly connected host is: 192.168.109.154 and its=20
SETCLIENTID call was logged. Unfortunately, this log was created while=20
*many* other NFS clients were connected, hence it may not be too useful.

I'd be very grateful for any help or instructions on debugging/fixing=20
this problem.


--------------ms090308000207030803030207
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIObzCC
BCEwggMJoAMCAQICAgDHMA0GCSqGSIb3DQEBBQUAMHExCzAJBgNVBAYTAkRFMRwwGgYDVQQK
ExNEZXV0c2NoZSBUZWxla29tIEFHMR8wHQYDVQQLExZULVRlbGVTZWMgVHJ1c3QgQ2VudGVy
MSMwIQYDVQQDExpEZXV0c2NoZSBUZWxla29tIFJvb3QgQ0EgMjAeFw0wNjEyMTkxMDI5MDBa
Fw0xOTA2MzAyMzU5MDBaMFoxCzAJBgNVBAYTAkRFMRMwEQYDVQQKEwpERk4tVmVyZWluMRAw
DgYDVQQLEwdERk4tUEtJMSQwIgYDVQQDExtERk4tVmVyZWluIFBDQSBHbG9iYWwgLSBHMDEw
ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDpm8NnhfkNrvWNVMOWUDU9YuluTO2U
1wBblSJ01CDrNI/W7MAxBAuZgeKmFNJSoCgjhIt0iQReW+DieMF4yxbLKDU5ey2QRdDtoAB6
fL9KDhsAw4bpXCsxEXsM84IkQ4wcOItqaACa7txPeKvSxhObdq3u3ibo7wGvdA/BCaL2a869
080UME/15eOkyGKbghoDJzANAmVgTe3RCSMqljVYJ9N2xnG2kB3E7f81hn1vM7PbD8URwoqD
oZRdQWvY0hD1TP3KUazZve+Sg7va64sWVlZDz+HVEz2mHycwzUlU28kTNJpxdcVs6qcLmPkh
nSevPqM5OUhqjK3JmfvDEvK9AgMBAAGjgdkwgdYwcAYDVR0fBGkwZzBloGOgYYZfaHR0cDov
L3BraS50ZWxlc2VjLmRlL2NnaS1iaW4vc2VydmljZS9hZl9Eb3dubG9hZEFSTC5jcmw/LWNy
bF9mb3JtYXQ9WF81MDkmLWlzc3Vlcj1EVF9ST09UX0NBXzIwHQYDVR0OBBYEFEm3xs/oPR9/
6kR7Eyn38QpwPt5kMB8GA1UdIwQYMBaAFDHDeRu69VPXF+CJei0XbAqzK50zMA4GA1UdDwEB
/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgECMA0GCSqGSIb3DQEBBQUAA4IBAQA74Vp3wEgX
3KkY7IGvWonwvSiSpspZGBJw7Cjy565/lizn8l0ZMfYTK3S9vYCyufdnyTmieTvhERHua3iR
M347XyYndVNljjNj7s9zw7CSI0khUHUjoR8Y4pSFPT8z6XcgjaK95qGFKUD2P3MyWA0Ja6ba
hWzAP7uNZmRWJE6uDT8yNQFb6YyC2XJZT7GGhfF0hVblw/hc843uR7NTBXDn5U2KaYMo4RMJ
hp5eyOpYHgwf+aTUWgRo/Sg+iwK2WLX2oSw3VwBnqyNojWOl75lrXP1LVvarQIc01BGSbOyH
xQoLBzNytG8MHVQs2FHHzL8w00Ny8TK/jM5JY6gA9/IcMIIEzDCCA7SgAwIBAgIECfEKYzAN
BgkqhkiG9w0BAQUFADBaMQswCQYDVQQGEwJERTETMBEGA1UEChMKREZOLVZlcmVpbjEQMA4G
A1UECxMHREZOLVBLSTEkMCIGA1UEAxMbREZOLVZlcmVpbiBQQ0EgR2xvYmFsIC0gRzAxMB4X
DTA3MDIxMzEwMDMwMVoXDTE5MDIxMjAwMDAwMFowYDELMAkGA1UEBhMCREUxKTAnBgNVBAoT
IFRlY2huaXNjaGUgVW5pdmVyc2l0YWV0IE11ZW5jaGVuMSYwJAYDVQQDEx1aZXJ0aWZpemll
cnVuZ3NzdGVsbGUgZGVyIFRVTTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKjv
6NPYBFzJ+ZELc6JfE/5aga/7K7LWMVBHZvohdJZGd31pN9QEfzQeph0kiqsm1X5kHraPtTc9
jMH8SLASBI45JppNSSYRfw6j6RjKA7PUStRfV0dq5cBPBl5FpxAY23lAzMzY+6EQEq3/hS8I
a3zG5Q5saJsc+9B2So8+gvaVwZhrWhe7NhyvVqYMiBpTE9fbViah3Ur5VdDpcGbsb/BqRDxR
rOCjQdNQ6TCQHfIUEDTQMW/czj1wbgLxrp8sB5XlwMPX7c2Do+yByWbcrkitdGEeagcWqC1g
c8pD/f8PJIoVeW4cy60PjHRIfYC0NBVvg9P0viuwFEyWM17brI8CAwEAAaOCAZIwggGOMA8G
A1UdEwEB/wQFMAMBAf8wCwYDVR0PBAQDAgEGMB0GA1UdDgQWBBSdnyPwGRt+xyNdJyrMpTY6
pmnliTAfBgNVHSMEGDAWgBRJt8bP6D0ff+pEexMp9/EKcD7eZDCBiAYDVR0fBIGAMH4wPaA7
oDmGN2h0dHA6Ly9jZHAxLnBjYS5kZm4uZGUvZ2xvYmFsLXJvb3QtY2EvcHViL2NybC9jYWNy
bC5jcmwwPaA7oDmGN2h0dHA6Ly9jZHAyLnBjYS5kZm4uZGUvZ2xvYmFsLXJvb3QtY2EvcHVi
L2NybC9jYWNybC5jcmwwgaIGCCsGAQUFBwEBBIGVMIGSMEcGCCsGAQUFBzAChjtodHRwOi8v
Y2RwMS5wY2EuZGZuLmRlL2dsb2JhbC1yb290LWNhL3B1Yi9jYWNlcnQvY2FjZXJ0LmNydDBH
BggrBgEFBQcwAoY7aHR0cDovL2NkcDIucGNhLmRmbi5kZS9nbG9iYWwtcm9vdC1jYS9wdWIv
Y2FjZXJ0L2NhY2VydC5jcnQwDQYJKoZIhvcNAQEFBQADggEBAINoNtnDCyUwcPDc68e/u5O/
ffcs+r4x4OeRxKtYXd3dRCyuCoxJAhhepSk2oQc89QhWFOOBxeT7KosoCsn+htLtgnZLj4R/
yNX8MemzYP170OZ/m4X9vmRhty+gh90kCSZlaQgT9MfV+7g1C6QgelUDV8N68Nd4Pl1IMBWk
AkZZLcT9/Hgol59FGhFDF1uFx7Su+vYBlO3g+tHnI18XJBDOs2abHRXI5PmYcvtGirsVMfWc
s0ooZOonYw5pvWI+N8dat9DNIvgRdoChTOKdvPURjtkY3kJkvdAfPKsf/ZCj3HhdEn0b6VZQ
qDj7VJRCvFOL0tqSc2wUrHLRw/9Mu2gwggV2MIIEXqADAgECAgQQ26t7MA0GCSqGSIb3DQEB
BQUAMGAxCzAJBgNVBAYTAkRFMSkwJwYDVQQKEyBUZWNobmlzY2hlIFVuaXZlcnNpdGFldCBN
dWVuY2hlbjEmMCQGA1UEAxMdWmVydGlmaXppZXJ1bmdzc3RlbGxlIGRlciBUVU0wHhcNMTAx
MDE4MTEyMjIwWhcNMTMxMDE3MTEyMjIwWjCB3TELMAkGA1UEBhMCREUxDzANBgNVBAgTBkJh
eWVybjERMA8GA1UEBxMITXVlbmNoZW4xKTAnBgNVBAoTIFRlY2huaXNjaGUgVW5pdmVyc2l0
YWV0IE11ZW5jaGVuMT4wPAYDVQQLEzVGYWt1bHRhZXQgZnVlciBFbGVrdHJvdGVjaG5payB1
bmQgSW5mb3JtYXRpb25zdGVjaG5pazEYMBYGA1UEAxMPSm9zY2hpIEJyYXVjaGxlMSUwIwYJ
KoZIhvcNAQkBFhZqb3NjaGkuYnJhdWNobGVAdHVtLmRlMIIBIjANBgkqhkiG9w0BAQEFAAOC
AQ8AMIIBCgKCAQEA2cF6tIlKUNmY12XEz8gAtWLnifpPKQ06VhsHNH3FRa3qqpScW96ypYRL
z3HTot2GdY7JSmEKSx7p5ehlOKbEcKsr57nbVzOkVW/0SmmWjroxzXe1e4KTw9QmpxXXQI5F
uUXRQoXZhgkPJWXa31uEzixbWIO4DHzM2TuEidFk3y2zcyA4j6g8flb8zMMSQjqAafTDA8Cf
A+j7cJZOCk30UZYNRuGLJi6tJi1nmaDy1ZMDAQA5P8nQJ3BpJGCxWwm5A0ppEBlKPFWjproJ
n8NErCRHRhWWcKkHwzwI48zB0bnrsKqMQVpkgSquGD94dbyDAIbht5M8HSE8eqmWj7Ug6QID
AQABo4IBuDCCAbQwCQYDVR0TBAIwADALBgNVHQ8EBAMCBeAwKQYDVR0lBCIwIAYIKwYBBQUH
AwIGCCsGAQUFBwMEBgorBgEEAYI3FAICMB0GA1UdDgQWBBSqoAQm9/5Acan0m0kcMmLzRDUu
FDAfBgNVHSMEGDAWgBSdnyPwGRt+xyNdJyrMpTY6pmnliTAhBgNVHREEGjAYgRZqb3NjaGku
YnJhdWNobGVAdHVtLmRlMHcGA1UdHwRwMG4wNaAzoDGGL2h0dHA6Ly9jZHAxLnBjYS5kZm4u
ZGUvdHVtLWNhL3B1Yi9jcmwvY2FjcmwuY3JsMDWgM6Axhi9odHRwOi8vY2RwMi5wY2EuZGZu
LmRlL3R1bS1jYS9wdWIvY3JsL2NhY3JsLmNybDCBkgYIKwYBBQUHAQEEgYUwgYIwPwYIKwYB
BQUHMAKGM2h0dHA6Ly9jZHAxLnBjYS5kZm4uZGUvdHVtLWNhL3B1Yi9jYWNlcnQvY2FjZXJ0
LmNydDA/BggrBgEFBQcwAoYzaHR0cDovL2NkcDIucGNhLmRmbi5kZS90dW0tY2EvcHViL2Nh
Y2VydC9jYWNlcnQuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCnQxDlwDKK5DSFIj5NaYxqCc3W
xO2X/VXL+MSw+3cgsp9W9pYsnWSUoYY32lHoOj45LNGJWZ4ikueDiG20j23n/ao+G8lwVh3D
+UPikmFPp2PWg3GlbRwQ33cbAxVIJ+XsOJupbQDfKh3U4AV91bdd/Eug3OAGOMbtB84HgD9G
sy1xEUDHuq4Ol24JUuZdimNPHUyMvk4bth+CECNcDjiUZ6kJ24m0AKE1GqkRbk7hyfqwhSCU
OP2riJ6JBQZf0U9sK91TjdNF0+he8SZpDJtJdMFZ75TO5Rwr7KLh6v6IefYYPo4f/IfdtMOX
LIVBpOWj/snSrDeGoO9X62zPufqGMYIDUjCCA04CAQEwaDBgMQswCQYDVQQGEwJERTEpMCcG
A1UEChMgVGVjaG5pc2NoZSBVbml2ZXJzaXRhZXQgTXVlbmNoZW4xJjAkBgNVBAMTHVplcnRp
Zml6aWVydW5nc3N0ZWxsZSBkZXIgVFVNAgQQ26t7MAkGBSsOAwIaBQCgggG/MBgGCSqGSIb3
DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTEzMDkxMzExMzI0N1owIwYJKoZI
hvcNAQkEMRYEFMVfcbi3Ld32xEWn1CAxVS3hYvrhMGwGCSqGSIb3DQEJDzFfMF0wCwYJYIZI
AWUDBAEqMAsGCWCGSAFlAwQBAjAKBggqhkiG9w0DBzAOBggqhkiG9w0DAgICAIAwDQYIKoZI
hvcNAwICAUAwBwYFKw4DAgcwDQYIKoZIhvcNAwICASgwdwYJKwYBBAGCNxAEMWowaDBgMQsw
CQYDVQQGEwJERTEpMCcGA1UEChMgVGVjaG5pc2NoZSBVbml2ZXJzaXRhZXQgTXVlbmNoZW4x
JjAkBgNVBAMTHVplcnRpZml6aWVydW5nc3N0ZWxsZSBkZXIgVFVNAgQQ26t7MHkGCyqGSIb3
DQEJEAILMWqgaDBgMQswCQYDVQQGEwJERTEpMCcGA1UEChMgVGVjaG5pc2NoZSBVbml2ZXJz
aXRhZXQgTXVlbmNoZW4xJjAkBgNVBAMTHVplcnRpZml6aWVydW5nc3N0ZWxsZSBkZXIgVFVN
AgQQ26t7MA0GCSqGSIb3DQEBAQUABIIBAGSkqh75nlQADSbYrzqoKjRFP6YBAoqNUX96eJfw
Mn69bVPtMVfZliqF86l8oWosyZf5ndpVwCBAECWvL8d+qGPGvTOskha/W2mkS51JyWBtNPoV
BsbIvUnUSTOagoHgRd143TKBUMCLNxVplsUlJFbr8Pk+2mazKCFi1bIxr4L3JsejjhRRwNYw
wiGk8Kuld9lRmGf0zhyim+bClJYf1CCgNoBfsih5sra9RROghDgwhrdPZobTaeCnNdG2JeZb
5wCiyVyWmYjxEP8vUQ+BEiNI+B7k+RmL+YqB+DB7TkZOUW+jvaUj9qJYyYWJt/FVn9n9dnYL
WWM+7TK8yksP+scAAAAAAAA=
--------------ms090308000207030803030207--
