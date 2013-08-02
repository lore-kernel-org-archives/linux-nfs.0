Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx3.wp.pl ([212.77.101.7]:9400 "EHLO mx3.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752290Ab3HBOiB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Aug 2013 10:38:01 -0400
Message-ID: <51FBC445.4000006@xl.wp.pl>
Date: Fri, 02 Aug 2013 16:37:57 +0200
From: Dawid Stawiarski <neeo@xl.wp.pl>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: Performance/stability problems with nfs shares
References: <51fb4bf3a9bde1.52024761@wp.pl> <20130802091242.23b9c904@corrin.poochiereds.net>
In-Reply-To: <20130802091242.23b9c904@corrin.poochiereds.net>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms070201020905050100040206"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kryptograficznie podpisana wiadomoED w formacie MIME.

--------------ms070201020905050100040206
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable

W dniu 02.08.2013 15:12, Jeff Layton pisze:
> On Fri, 02 Aug 2013 08:04:35 +0200
> "Dawid Stawiarski" <neeo@xl.wp.pl> wrote:
>
>> Hi,
>>
>> we observe performance issues on Blade Linux NFS clients (Ubuntu 12.04=
 with kernel 3.8.0-23-generic).
>> Blade nodes are used in a shared hosting environment, and NFS is used =
to access client's data from Nexenta Storage (mostly small php files and/=
or images). Single node is running about 300-400 apache instances.
>> We use 10G on the whole path from nodes to storage with jumbo frames e=
nabled. We didn't see any drops on
>> network interfaces (on nodes nor switches).
>> Once in a while, apache processes accesing data on NFS share stuck on =
IO (D state - stack trace below).
>> We've already tried different combinations of mount options and tuning=
 sysctls and sunrpc module (we also tried NFSv4 and UDP transport - these=
 only made things worse; without the local locks we had also lots of prob=
lems).
>> Hangs seems to happen under haeavy concurent operations (in production=
 env); unfortunatelly we didn't manage
>> to reproduce it with benchmark utilities. When the number of nodes is =
decreased the problem happens more frequently (in this case we have about=
 600 apache instances per node). We didn't see any problems on the storag=
e itself when one of the shares hangs (the cpu usage and load look as usu=
al).
>>
>> 1. client mount options we've tested:
>> noatime,nodiratime,noacl,nodev,nosuid,rsize=3D8192,wsize=3D8192,intr,b=
g,timeo=3D20,nfsvers=3D3,nolock
>> noatime,nodiratime,noacl,nodev,nosuid,rsize=3D8192,wsize=3D8192,intr,b=
g,acregmin=3D6,timeo=3D20,nfsvers=3D3,nolock
>>
>> noatime,nodiratime,noacl,nodev,nosuid,rsize=3D1048576,wsize=3D1048576,=
intr,bg,acregmin=3D6,timeo=3D20,nfsvers=3D3,nolock
>> noatime,nodiratime,noacl,nodev,nosuid,rsize=3D1048576,wsize=3D1048576,=
intr,bg,acregmin=3D10,timeo=3D100,nfsvers=3D3,nolock
>> noatime,nodiratime,noacl,nodev,nosuid,rsize=3D1048576,wsize=3D1048576,=
intr,bg,acregmin=3D10,timeo=3D600,nfsvers=3D3,nolock
>>
>> noatime,nodiratime,noacl,nodev,nosuid,rsize=3D1048576,wsize=3D1048576,=
intr,bg,acregmin=3D10,timeo=3D20,nfsvers=3D4,nolock
>>
>> 2. linux sysctl:
>> net.ipv4.tcp_timestamps =3D 0
>> net.core.netdev_max_backlog =3D 30000
>> net.ipv4.tcp_mtu_probing =3D 1
>> net.ipv4.tcp_slow_start_after_idle =3D 0
>> net.ipv4.tcp_timestamps =3D 0
>>
>> 3. linux module option:
>> options sunrpc tcp_slot_table_entries=3D128
>>
>>
>> With nfs timeout=3D2s we observed a huge loadavg (1000 or more) and lo=
ts of processes in "D" state waiting in
>> function "rpc_bit_killable". Everything "worked" but insanely slow. Fo=
r example `find` on the mountpoint printed ~1 line per second. "avg RTT" =
and "avg exe" stats from nfsiostat increased to 500-800ms.
>>
>
> To be clear, you mean the "timeo=3D20" mounts? That's awfully low for a=

> TCP connection. With TCP, you typically don't want the client doing RPC=

> retransmits that frequently. You want to let the TCP layer handle it in=

> most cases.

Yes, we've tested timeo=3D20, 100 and 600 (the default). The sympoms=20
change (share completly hang or is terribly slow) - but the problem=20
exists with all the values.


>> At first, we had 8 mounts from a single storage server (so basicly onl=
y one TCP connection was used).
>> However, we've also tried to add 8 virtual IPs to the storage, and use=
 a separate IP to connect to
>> every share to distribute traffic among more TCP connections. At the s=
ame time we've
>> set nfs client timeout to 60s (the default). In this case we observed =
permanent hang
>> on random (single) mountpoint - and loadavg of about 150. Other mountp=
oints from the same storage worked correctly. There was no data traffic t=
o hung mountpoint IP; only couple retransmissions (every 60 secs). After =
TCP reset and reconnect (this happens after couple minutes) everything st=
arts to work correctly.
>>
>
> Are those RPC or TCP retransmissions?

I belive this were TCP retransmits (but RPC ones also happen - and can=20
be seen on mountstats).


>> Now we decreased timeout to 10s.
>>
>> /proc/PID/stack of a hung process (we have hundreds of these):
>> [<ffffffffa00eb019>] rpc_wait_bit_killable+0x39/0x90 [sunrpc]
>> [<ffffffffa00ec0fb>] __rpc_execute+0x15b/0x1b0 [sunrpc]
>> [<ffffffffa00ec87f>] rpc_execute+0x4f/0xb0 [sunrpc]
>> [<ffffffffa00e45a5>] rpc_run_task+0x75/0x90 [sunrpc]
>> [<ffffffffa00e46c3>] rpc_call_sync+0x43/0xa0 [sunrpc]
>> [<ffffffffa02595eb>] nfs3_rpc_wrapper.constprop.10+0x6b/0xb0 [nfsv3]
>> [<ffffffffa025a4ae>] nfs3_proc_getattr+0x3e/0x50 [nfsv3]
>> [<ffffffffa01452fd>] __nfs_revalidate_inode+0x8d/0x120 [nfs]
>> [<ffffffffa0141313>] nfs_lookup_revalidate+0x353/0x3a0 [nfs]
>> [<ffffffff811a79b3>] lookup_fast+0x173/0x230
>> [<ffffffff811a7cc6>] do_last+0x106/0x820
>> [<ffffffff811aa333>] path_openat+0xb3/0x4d0
>> [<ffffffff811ab152>] do_filp_open+0x42/0xa0
>> [<ffffffff8119adaa>] do_sys_open+0xfa/0x250
>> [<ffffffff811ed8cb>] compat_sys_open+0x1b/0x20
>> [<ffffffff816fc62c>] sysenter_dispatch+0x7/0x21
>> [<ffffffffffffffff>] 0xffffffffffffffff
>>
>> nfsiostat on a problematic "slow" share (other shares from the SAME st=
orage, but on separate TCP connection work correctly):
>> 10.254.38.115:/volumes/DATA1/10/5 mounted on /home/10/5:
>>
>>     op/s         rpc bklog
>>   420.50            0.00
>> read:             ops/s            kB/s           kB/op         retran=
s         avg RTT (ms)    avg exe (ms)
>>                    1.000          30.736          30.736        0 (0.0=
%)          13.500         867.700
>> write:            ops/s            kB/s           kB/op         retran=
s         avg RTT (ms)    avg exe (ms)
>>                    0.600           0.522           0.870        0 (0.0=
%)           0.667         872.333
>>
>> mount options used on node:
>> 10.254.38.115:/volumes/DATA1/10/5 /home/10/5 nfs rw,nosuid,nodev,noati=
me,nodiratime,vers=3D3,rsize=3D131072,wsize=3D131072,namlen=3D255,acregmi=
n=3D10,hard,nolock,noacl,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dsys,mo=
untaddr=3D10.254.38.115,mountvers=3D3,mountport=3D63856,mountproto=3Dudp,=
local_lock=3Dall,addr=3D10.254.38.115 0 0
>>
>>
>> netstat:
>> - very slow access:
>> tcp        0      0 10.254.39.72:692        10.254.38.115:2049      ES=
TABLISHED -                off (0.00/0/0)
>>
>> - completly not responding:
>> tcp        0 132902 10.254.39.74:719        10.254.38.115:2049      ES=
TABLISHED -                on (43.21/3/0)
>>
>> client software:
>> - util-linux 2.20.1-1ubuntu3
>> - nfs-common 1.2.5-3ubuntu3.1
>> - libevent 2.0.16-stable-1
>>
>> Can anyone help us to investigate the problem or has any sugestions wh=
at to try/check? Any help would be appreciated.
>>
>> cheers,
>> Dawid
>>
>>
>
> Typically, a stack trace like that indicates that the process is
> waiting for the server to respond. The first thing I would do would be
> to ascertain whether the server is actually responding to these
> requests.
>

The same share is accessible on other nodes, so the problem involves=20
only one of the nodes (completly random) at a time.


--------------ms070201020905050100040206
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: Kryptograficzna sygnatura S/MIME

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIMbDCC
BjAwggUYoAMCAQICAwa/eTANBgkqhkiG9w0BAQUFADCBjDELMAkGA1UEBhMCSUwxFjAUBgNV
BAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRl
IFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlh
dGUgQ2xpZW50IENBMB4XDTEzMDYwMzE4NTMwOVoXDTE0MDYwNDIxNTMxOFowUTEZMBcGA1UE
DRMQUHRwMFlsNDBrREV3ZjZaQjEWMBQGA1UEAwwNbmVlb0B4bC53cC5wbDEcMBoGCSqGSIb3
DQEJARYNbmVlb0B4bC53cC5wbDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANlh
cuj8w2ADTJR9gMknGcxPai1jIN5plafbCbOxQOqtwa+92nkuLWN5kuSpb3tfplx9oYxNNuvV
EivvDusj8c5/EHlylylRvr8lBW3Wj/BHSMo1b60hIx/mLovevzA7z7oFRYGNrCZ7MrW5x9Dp
dh82rcuseH1puiOn3/7u0/5ZueisWJj/JhZ4bJPJYVZ+Eqvjzk3YFraJkSA8GXVCYdBtYmDS
S3P5YDGZEQJYTTq0/S8WnUXDjqlgnQtMsgeYgfo6MMklMYi1zpGeb4jY3XpQder5/gFUS7Vk
AuxDiTwb7SOHThUF+Qqvriieg+IZtqU3GOBnttcStgXDtR1IDf8CAwEAAaOCAtMwggLPMAkG
A1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcDBDAd
BgNVHQ4EFgQUpRa3BRIf+bxFy2eCYX/cZofZiz8wHwYDVR0jBBgwFoAUU3Ltkpzg2ssBXHx+
ljVO8tS4UYIwGAYDVR0RBBEwD4ENbmVlb0B4bC53cC5wbDCCAUwGA1UdIASCAUMwggE/MIIB
OwYLKwYBBAGBtTcBAgMwggEqMC4GCCsGAQUFBwIBFiJodHRwOi8vd3d3LnN0YXJ0c3NsLmNv
bS9wb2xpY3kucGRmMIH3BggrBgEFBQcCAjCB6jAnFiBTdGFydENvbSBDZXJ0aWZpY2F0aW9u
IEF1dGhvcml0eTADAgEBGoG+VGhpcyBjZXJ0aWZpY2F0ZSB3YXMgaXNzdWVkIGFjY29yZGlu
ZyB0byB0aGUgQ2xhc3MgMSBWYWxpZGF0aW9uIHJlcXVpcmVtZW50cyBvZiB0aGUgU3RhcnRD
b20gQ0EgcG9saWN5LCByZWxpYW5jZSBvbmx5IGZvciB0aGUgaW50ZW5kZWQgcHVycG9zZSBp
biBjb21wbGlhbmNlIG9mIHRoZSByZWx5aW5nIHBhcnR5IG9ibGlnYXRpb25zLjA2BgNVHR8E
LzAtMCugKaAnhiVodHRwOi8vY3JsLnN0YXJ0c3NsLmNvbS9jcnR1MS1jcmwuY3JsMIGOBggr
BgEFBQcBAQSBgTB/MDkGCCsGAQUFBzABhi1odHRwOi8vb2NzcC5zdGFydHNzbC5jb20vc3Vi
L2NsYXNzMS9jbGllbnQvY2EwQgYIKwYBBQUHMAKGNmh0dHA6Ly9haWEuc3RhcnRzc2wuY29t
L2NlcnRzL3N1Yi5jbGFzczEuY2xpZW50LmNhLmNydDAjBgNVHRIEHDAahhhodHRwOi8vd3d3
LnN0YXJ0c3NsLmNvbS8wDQYJKoZIhvcNAQEFBQADggEBABrj5sKK9vcRX7FO2JJBF/0n5PUB
fLwD91IOElcR8aUbsmOikPzjbv3QbjJA4BQwfuwe89i+i6X9aBd89ykl9+zRMprBXHD1g3Zq
got0MRzYlK8Aqw6TBbLySmj9CFciGwmnDNcxMqfZVyGe+iVyyom8BMs3vPLF8AZwcnurBfRh
PL9lDJflMM3WztZqwsi1CFC0agMY5ym9ddsTzZCLSwezPER+QF8IjhUm97u1pBRKF9J/lPgl
JjBN/QbYNaedpuaoRTFfnqEal527kKSBZhcIbDeegZ0FRibJKBccCT1nv0huDr0OVc6CUCrD
yxV8mCDPaZYPixrZah2IhxVxgrQwggY0MIIEHKADAgECAgEeMA0GCSqGSIb3DQEBBQUAMH0x
CzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSswKQYDVQQLEyJTZWN1cmUg
RGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMSkwJwYDVQQDEyBTdGFydENvbSBDZXJ0aWZp
Y2F0aW9uIEF1dGhvcml0eTAeFw0wNzEwMjQyMTAxNTVaFw0xNzEwMjQyMTAxNTVaMIGMMQsw
CQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERp
Z2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQ
cmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
ggEKAoIBAQDHCYPMzi3YGrEppC4Tq5a+ijKDjKaIQZZVR63UbxIP6uq/I0fhCu+cQhoUfE6E
RKKnu8zPf1Jwuk0tsvVCk6U9b+0UjM0dLep3ZdE1gblK/1FwYT5Pipsu2yOMluLqwvsuz9/9
f1+1PKHG/FaR/wpbfuIqu54qzHDYeqiUfsYzoVflR80DAC7hmJ+SmZnNTWyUGHJbBpA8Q89l
GxahNvuryGaC/o2/ceD2uYDX9U8Eg5DpIpGQdcbQeGarV04WgAUjjXX5r/2dabmtxWMZwhZn
a//jdiSyrrSMTGKkDiXm6/3/4ebfeZuCYKzN2P8O2F/Xe2AC/Y7zeEsnR7FOp+uXAgMBAAGj
ggGtMIIBqTAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBBjAdBgNVHQ4EFgQUU3Lt
kpzg2ssBXHx+ljVO8tS4UYIwHwYDVR0jBBgwFoAUTgvvGqRAW6UXaYcwyjRoQ9BBrvIwZgYI
KwYBBQUHAQEEWjBYMCcGCCsGAQUFBzABhhtodHRwOi8vb2NzcC5zdGFydHNzbC5jb20vY2Ew
LQYIKwYBBQUHMAKGIWh0dHA6Ly93d3cuc3RhcnRzc2wuY29tL3Nmc2NhLmNydDBbBgNVHR8E
VDBSMCegJaAjhiFodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9zZnNjYS5jcmwwJ6AloCOGIWh0
dHA6Ly9jcmwuc3RhcnRzc2wuY29tL3Nmc2NhLmNybDCBgAYDVR0gBHkwdzB1BgsrBgEEAYG1
NwECATBmMC4GCCsGAQUFBwIBFiJodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9wb2xpY3kucGRm
MDQGCCsGAQUFBwIBFihodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9pbnRlcm1lZGlhdGUucGRm
MA0GCSqGSIb3DQEBBQUAA4ICAQAKgwh9eKssBly4Y4xerhy5I3dNoXHYfYa8PlVLL/qtXnkF
gdtY1o95CfegFJTwqBBmf8pyTUnFsukDFUI22zF5bVHzuJ+GxhnSqN2sD1qetbYwBYK2iyYA
5Pg7Er1A+hKMIzEzcduRkIMmCeUTyMyikfbUFvIBivtvkR8ZFAk22BZy+pJfAoedO61HTz4q
SfQoCRcLN5A0t4DkuVhTMXIzuQ8CnykhExD6x4e6ebIbrjZLb7L+ocR0y4YjCl/Pd4MXU91y
0vTipgr/O75CDUHDRHCCKBVmz/Rzkc/b970MEeHt5LC3NiWTgBSvrLEuVzBKM586YoRD9Dy3
OHQgWI270g+5MYA8GfgI/EPT5G7xPbCDz+zjdH89PeR3U4So4lSXur6H6vp+m9TQXPF3a0Lw
Zrp8MQ+Z77U1uL7TelWO5lApsbAonrqASfTpaprFVkL4nyGH+NHST2ZJPWIBk81i6Vw0ny0q
ZW2Niy/QvVNKbb43A43ny076khXO7cNbBIRdJ/6qQNq9Bqb5C0Q5nEsFcj75oxQRqlKf6Tcv
GbjxkJh8BYtv9ePsXklAxtm8J7GCUBthHSQgepbkOexhJ0wP8imUkyiPHQ0GvEnd83129fZj
oEhdGwXV27ioRKbj/cIq7JRXun0NbeY+UdMYu9jGfIpDLtUUGSgsg2zMGs5R4jGCA90wggPZ
AgEBMIGUMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UE
CxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMvU3RhcnRD
b20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0ECAwa/eTAJBgUrDgMC
GgUAoIICHTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xMzA4
MDIxNDM3NTdaMCMGCSqGSIb3DQEJBDEWBBTG8qpih5iNuGas9nbFAqx1iQ1vbzBsBgkqhkiG
9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjALBglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZI
hvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMIGlBgkr
BgEEAYI3EAQxgZcwgZQwgYwxCzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQu
MSswKQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQD
Ey9TdGFydENvbSBDbGFzcyAxIFByaW1hcnkgSW50ZXJtZWRpYXRlIENsaWVudCBDQQIDBr95
MIGnBgsqhkiG9w0BCRACCzGBl6CBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0
Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcx
ODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50
IENBAgMGv3kwDQYJKoZIhvcNAQEBBQAEggEAF7hUR4V6Jb/pe3BXRtHPXLaRIqAfv/m5wMvR
2YI/wbbQ0ESF8qf35axsV8yfJq+IL8L/SDIFh1Gf05Lo3LcEe0wQhWPkUdfs4/dScKAg0nsv
pylx59FLxPwE+uqrfy4DY63bbZxsl6LiUx6guC5dgoNWcyjGmlxqg/yhjP0+kxRncRJ9kFmw
LGrw1Z8MXJS9PAHpDtPPRf+G0fNcBs/f6X0Al7+8SwdAlKqwD9KQLShGJYGvb9tD0PcIdjGT
SEQcbpbbfLTQRks5hOv04S19gwyr5HGO+UEuw5P7tmiuHQeIegFtdJy/0F4PwLB9537fIn3w
5/sk/GJ4OCxm8476ZAAAAAAAAA==
--------------ms070201020905050100040206--
