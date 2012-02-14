Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8148 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758734Ab2BNBxd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Feb 2012 20:53:33 -0500
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Andy Adamson <androsadamson@gmail.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] SUNRPC: add sending,pending queue and max slot to
 xprt stats
Date: Tue, 14 Feb 2012 01:53:07 +0000
Message-ID: <1F402E54-6FCC-4AA4-BDAA-AA8C2953D4B0@netapp.com>
References: <1329126847-2197-1-git-send-email-andros@netapp.com>
 <22313268-E5C1-471C-9284-92423037B3BC@oracle.com>
 <CAHVgHyVGKD1nPZRMfuWnkvqT9CcR=1yoJ3=f5skhsuCPswUoQg@mail.gmail.com>
In-Reply-To: <CAHVgHyVGKD1nPZRMfuWnkvqT9CcR=1yoJ3=f5skhsuCPswUoQg@mail.gmail.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_DA0CB009-31D5-4319-98F0-3B7DF078ADC9";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_DA0CB009-31D5-4319-98F0-3B7DF078ADC9
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=iso-8859-1


On Feb 13, 2012, at 6:08 PM, Andy Adamson wrote:

> On Mon, Feb 13, 2012 at 6:01 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>> Hi-
>>=20
>> On Feb 13, 2012, at 4:54 AM, andros@netapp.com wrote:
>>=20
>>> From: Andy Adamson <andros@netapp.com>
>>>=20
>>> With static RPC slots, the xprt backlog queue stats were useful in =
showing
>>> when the transport (TCP) was starved by lack of RPC slots. The new =
dynamic
>>> RPC slot code, commit d9ba131d8f58c0d2ff5029e7002ab43f913b36f9, =
always
>>> provides an RPC slot and so only uses the xprt backlog queue when =
the
>>> tcp_max_slot_table_entries value has been hit or when an allocation =
error
>>> occurs. All requests are now placed on the xprt sending or pending =
queue which
>>> need to be monitored for debugging.
>>>=20
>>> The max_slot stat shows the maximum number of dynamic RPC slots =
reached which is
>>> useful when debugging performance issues.
>>>=20
>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>=20
>> OK, now I'm really confused.  The e-mail address says "W Andros =
Adamson" -- I thought that this is the son, Weston Andros Adamson, not =
the father.  But the sign-off is from andros@netapp.com.  Help?
>=20
> I don't see "W Andros Adamson" anywhere - but that is my name! I'm
> William Andros Adamson, Dros is Weston Andros Adamson which makes us
> both W. Andros Adamson.

Just to confuse everyone :)

For the purposes of this list he is Andy (andros@) and I am Dros =
(dros@).  It's not wrong when you call me Andy or Andros - it's just =
confusing!

>=20
> heh heh.
>=20

^^ Blame no one but yourself!  I guess you can blame Mom too...=20

-dros

>=20
>>=20
>> More below.
>>=20
>>> ---
>>> include/linux/sunrpc/xprt.h |    7 +++++--
>>> net/sunrpc/xprt.c           |    7 ++++++-
>>> net/sunrpc/xprtsock.c       |   25 ++++++++++++++++++-------
>>> 3 files changed, 29 insertions(+), 10 deletions(-)
>>>=20
>>> diff --git a/include/linux/sunrpc/xprt.h =
b/include/linux/sunrpc/xprt.h
>>> index 15518a1..344b6f2 100644
>>> --- a/include/linux/sunrpc/xprt.h
>>> +++ b/include/linux/sunrpc/xprt.h
>>> @@ -219,10 +219,13 @@ struct rpc_xprt {
>>>                                       connect_time,   /* jiffies =
waiting for connect */
>>>                                       sends,          /* how many =
complete requests */
>>>                                       recvs,          /* how many =
complete requests */
>>> -                                     bad_xids;       /* lookup_rqst =
didn't find XID */
>>> +                                     bad_xids,       /* lookup_rqst =
didn't find XID */
>>> +                                     max_slots;      /* max =
rpc_slots used */
>>>=20
>>>               unsigned long long      req_u,          /* average =
requests on the wire */
>>> -                                     bklog_u;        /* backlog =
queue utilization */
>>> +                                     bklog_u,        /* backlog =
queue utilization */
>>> +                                     sending_u,      /* send q =
utilization */
>>> +                                     pending_u;      /* pend q =
utilization */
>>>       } stat;
>>>=20
>>>       struct net              *xprt_net;
>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>> index c64c0ef..fb95e25 100644
>>> --- a/net/sunrpc/xprt.c
>>> +++ b/net/sunrpc/xprt.c
>>> @@ -884,7 +884,7 @@ void xprt_transmit(struct rpc_task *task)
>>> {
>>>       struct rpc_rqst *req =3D task->tk_rqstp;
>>>       struct rpc_xprt *xprt =3D req->rq_xprt;
>>> -     int status;
>>> +     int status, numreqs;
>>>=20
>>>       dprintk("RPC: %5u xprt_transmit(%u)\n", task->tk_pid, =
req->rq_slen);
>>>=20
>>> @@ -921,9 +921,14 @@ void xprt_transmit(struct rpc_task *task)
>>>=20
>>>       xprt->ops->set_retrans_timeout(task);
>>>=20
>>> +     numreqs =3D atomic_read(&xprt->num_reqs);
>>> +     if (numreqs > xprt->stat.max_slots)
>>> +             xprt->stat.max_slots =3D numreqs;
>>>       xprt->stat.sends++;
>>>       xprt->stat.req_u +=3D xprt->stat.sends - xprt->stat.recvs;
>>>       xprt->stat.bklog_u +=3D xprt->backlog.qlen;
>>> +     xprt->stat.sending_u +=3D xprt->sending.qlen;
>>> +     xprt->stat.pending_u +=3D xprt->pending.qlen;
>>>=20
>>>       /* Don't race with disconnect */
>>>       if (!xprt_connected(xprt))
>>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>>> index 55472c4..2a80817 100644
>>> --- a/net/sunrpc/xprtsock.c
>>> +++ b/net/sunrpc/xprtsock.c
>>> @@ -2226,8 +2226,8 @@ static void xs_local_print_stats(struct =
rpc_xprt *xprt, struct seq_file *seq)
>>>       if (xprt_connected(xprt))
>>>               idle_time =3D (long)(jiffies - xprt->last_used) / HZ;
>>>=20
>>> -     seq_printf(seq, "\txprt:\tlocal %lu %lu %lu %ld %lu %lu %lu "
>>> -                     "%llu %llu\n",
>>> +     seq_printf(seq, "\txprt:\tlocal %lu %lu %lu %ld %lu %lu %lu =
%lu "
>>> +                     "%llu %llu %llu %llu\n",
>>>                       xprt->stat.bind_count,
>>>                       xprt->stat.connect_count,
>>>                       xprt->stat.connect_time,
>>> @@ -2235,8 +2235,11 @@ static void xs_local_print_stats(struct =
rpc_xprt *xprt, struct seq_file *seq)
>>>                       xprt->stat.sends,
>>>                       xprt->stat.recvs,
>>>                       xprt->stat.bad_xids,
>>> +                     xprt->stat.max_slots,
>>>                       xprt->stat.req_u,
>>> -                     xprt->stat.bklog_u);
>>> +                     xprt->stat.bklog_u,
>>> +                     xprt->stat.sending_u,
>>> +                     xprt->stat.pending_u);
>>> }
>>>=20
>>> /**
>>=20
>> This hunk changes the format and content of /proc/self/mountstats.  I =
don't see where you are bumping the statvers so mountstats can tell what =
is going on.  Since you are adding fields, mountstats may not complain =
about this, but it will probably display incorrect output since you are =
adding a field somewhere in the middle of the line.
>=20
> Noted: I'll add a bump to the statvers.
>=20
> -->Andy
>=20
>>=20
>>> @@ -2249,14 +2252,18 @@ static void xs_udp_print_stats(struct =
rpc_xprt *xprt, struct seq_file *seq)
>>> {
>>>       struct sock_xprt *transport =3D container_of(xprt, struct =
sock_xprt, xprt);
>>>=20
>>> -     seq_printf(seq, "\txprt:\tudp %u %lu %lu %lu %lu %Lu %Lu\n",
>>> +     seq_printf(seq, "\txprt:\tudp %u %lu %lu %lu %lu %lu %llu %llu =
"
>>> +                     "%llu %llu\n",
>>>                       transport->srcport,
>>>                       xprt->stat.bind_count,
>>>                       xprt->stat.sends,
>>>                       xprt->stat.recvs,
>>>                       xprt->stat.bad_xids,
>>> +                     xprt->stat.max_slots,
>>>                       xprt->stat.req_u,
>>> -                     xprt->stat.bklog_u);
>>> +                     xprt->stat.bklog_u,
>>> +                     xprt->stat.sending_u,
>>> +                     xprt->stat.pending_u);
>>> }
>>>=20
>>> /**
>>=20
>> Likewise.
>>=20
>>> @@ -2273,7 +2280,8 @@ static void xs_tcp_print_stats(struct rpc_xprt =
*xprt, struct seq_file *seq)
>>>       if (xprt_connected(xprt))
>>>               idle_time =3D (long)(jiffies - xprt->last_used) / HZ;
>>>=20
>>> -     seq_printf(seq, "\txprt:\ttcp %u %lu %lu %lu %ld %lu %lu %lu =
%Lu %Lu\n",
>>> +     seq_printf(seq, "\txprt:\ttcp %u %lu %lu %lu %ld %lu %lu %lu =
%lu "
>>> +                     "%llu %llu %llu %llu\n",
>>>                       transport->srcport,
>>>                       xprt->stat.bind_count,
>>>                       xprt->stat.connect_count,
>>> @@ -2282,8 +2290,11 @@ static void xs_tcp_print_stats(struct =
rpc_xprt *xprt, struct seq_file *seq)
>>>                       xprt->stat.sends,
>>>                       xprt->stat.recvs,
>>>                       xprt->stat.bad_xids,
>>> +                     xprt->stat.max_slots,
>>>                       xprt->stat.req_u,
>>> -                     xprt->stat.bklog_u);
>>> +                     xprt->stat.bklog_u,
>>> +                     xprt->stat.sending_u,
>>> +                     xprt->stat.pending_u);
>>> }
>>>=20
>>> /*
>>=20
>> And here too.
>>=20
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>=20
>>=20
>>=20
>>=20
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Apple-Mail=_DA0CB009-31D5-4319-98F0-3B7DF078ADC9
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMTQwMTUzMDdaMCMGCSqGSIb3DQEJBDEWBBRNF3HaUqwya9Jb
AVR6jOFD02l8wjANBgkqhkiG9w0BAQEFAASCAQBFwsSAX0M85a311j1Cyb2xxT1Bg5ialtPRREYI
xo+MzPQOb/v88/ZUOXdVlHtEj6naKHqxPDJsjE75a81qeK/IxdDwfUrbFYzfkoVfPO21cDtWDCLo
D8yqWTSmRNjJMsDArGEFnc8x4mOX6revLoxQcOsLeV5R1Acrb+TnhXUrOOtZ9mxwwl4q12PXv6Z5
TZ9XX85YwmiP685QIqwzTgf4bkrk/73G5aDVaV//gFu1Uh8l/LlMQ8MXx8vueir1Heq6/pgAcB8e
CKdOPar8nEL+GFZE5rHMjLIsCMYVHwI32kxJ/n7fWaGLjWnVi8HH8zjfNRpJh/wxiZwWIy782iaB
AAAAAAAA

--Apple-Mail=_DA0CB009-31D5-4319-98F0-3B7DF078ADC9--
