Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f173.google.com ([209.85.214.173]:54977 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964781AbaEQQgO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 17 May 2014 12:36:14 -0400
Received: by mail-ob0-f173.google.com with SMTP id wm4so4368633obc.18
        for <linux-nfs@vger.kernel.org>; Sat, 17 May 2014 09:36:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5376025B.6010202@cogentembedded.com>
References: <1400190998-28153-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<5376025B.6010202@cogentembedded.com>
Date: Sat, 17 May 2014 18:36:13 +0200
Message-ID: <CAFo99gatLzLpOu92N23bMQ=a25BTnK3QK2rAzoQJcU3oxMuMgA@mail.gmail.com>
Subject: Re: [PATCH] Fix for possible null pointer dereference in auth.c
From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: multipart/mixed; boundary=089e013cba44e2c78304f99b2078
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--089e013cba44e2c78304f99b2078
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi

I have made a new patch according Sergei specification.

But there remains Tronds question though.

Best regards
Rickard Strandqvist


2014-05-16 14:19 GMT+02:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.=
com>:
> Hello.
>
>
> On 16-05-2014 1:56, Rickard Strandqvist wrote:
>
>> There is otherwise a risk of a possible null pointer dereference.
>
>
>> Was largely found by using a static code analysis program called cppchec=
k.
>
>
>> Signed-off-by: Rickard Strandqvist
>> <rickard_strandqvist@spectrumdigital.se>
>> ---
>>   net/sunrpc/auth.c |   10 +++++++---
>>   1 fil =C3=A4ndrad, 7 till=C3=A4gg(+), 3 borttagningar(-)
>
>
>> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
>> index 5285ead..3a55698 100644
>> --- a/net/sunrpc/auth.c
>> +++ b/net/sunrpc/auth.c
>> @@ -801,10 +801,14 @@ rpcauth_invalcred(struct rpc_task *task)
>>   {
>>         struct rpc_cred *cred =3D task->tk_rqstp->rq_cred;
>>
>> -       dprintk("RPC: %5u invalidating %s cred %p\n",
>> -               task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
>> -       if (cred)
>> +       if (cred) {
>> +               dprintk("RPC: %5u invalidating %s cred %p\n",
>> +                       task->tk_pid, cred->cr_auth->au_ops->au_name,
>> cred);
>> +
>>                 clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
>> +       }
>> +       else
>
>
>    } and *else* should be on the same line, and there should be {} in the
> *else* arm since there's {} in the *if* arm already, according to
> Documentation/CodingStyle.
>
>
>> +               dprintk("RPC: %5u invalidating is NULL\n", task->tk_pid)=
;
>
>
>    That's not a proper English, I'm afraid.
>
>>   }
>
>
> WBR, Sergei
>
>

--089e013cba44e2c78304f99b2078
Content-Type: text/x-patch; charset=US-ASCII;
	name="0001-Fix-for-possible-null-pointer-dereferenc.patch"
Content-Disposition: attachment;
	filename="0001-Fix-for-possible-null-pointer-dereferenc.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hvb4zt2z0

RnJvbSAyMTA5OTQ5MDVmN2Y3YjEzZjZjNjIxZjExMDY5OWYyOGZkMTM0OTgwIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBSaWNrYXJkIFN0cmFuZHF2aXN0IDxyaWNrYXJkX3N0cmFuZHF2
aXN0QHNwZWN0cnVtZGlnaXRhbC5zZT4KRGF0ZTogU3VuLCAxMSBNYXkgMjAxNCAxODo1MTo0MiAr
MDIwMApTdWJqZWN0OiBbUEFUQ0hdIG5ldDogc3VucnBjOiBhdXRoLmM6IEZpeCBmb3IgcG9zc2li
bGUgbnVsbCBwb2ludGVyIGRlcmVmZXJlbmNlCgpUaGVyZSBpcyBvdGhlcndpc2UgYSByaXNrIG9m
IGEgcG9zc2libGUgbnVsbCBwb2ludGVyIGRlcmVmZXJlbmNlLgoKV2FzIGxhcmdlbHkgZm91bmQg
YnkgdXNpbmcgYSBzdGF0aWMgY29kZSBhbmFseXNpcyBwcm9ncmFtIGNhbGxlZCBjcHBjaGVjay4K
ClNpZ25lZC1vZmYtYnk6IFJpY2thcmQgU3RyYW5kcXZpc3QgPHJpY2thcmRfc3RyYW5kcXZpc3RA
c3BlY3RydW1kaWdpdGFsLnNlPgotLS0KIG5ldC9zdW5ycGMvYXV0aC5jIHwgICAxMCArKysrKysr
LS0tCiAxIGZpbGUgY2hhbmdlZCwgNyBpbnNlcnRpb25zKCspLCAzIGRlbGV0aW9ucygtKQoKZGlm
ZiAtLWdpdCBhL25ldC9zdW5ycGMvYXV0aC5jIGIvbmV0L3N1bnJwYy9hdXRoLmMKaW5kZXggNTI4
NWVhZC4uYTllMTg2NiAxMDA2NDQKLS0tIGEvbmV0L3N1bnJwYy9hdXRoLmMKKysrIGIvbmV0L3N1
bnJwYy9hdXRoLmMKQEAgLTgwMSwxMCArODAxLDE0IEBAIHJwY2F1dGhfaW52YWxjcmVkKHN0cnVj
dCBycGNfdGFzayAqdGFzaykKIHsKIAlzdHJ1Y3QgcnBjX2NyZWQgKmNyZWQgPSB0YXNrLT50a19y
cXN0cC0+cnFfY3JlZDsKIAotCWRwcmludGsoIlJQQzogJTV1IGludmFsaWRhdGluZyAlcyBjcmVk
ICVwXG4iLAotCQl0YXNrLT50a19waWQsIGNyZWQtPmNyX2F1dGgtPmF1X29wcy0+YXVfbmFtZSwg
Y3JlZCk7Ci0JaWYgKGNyZWQpCisJaWYgKGNyZWQpIHsKKwkJZHByaW50aygiUlBDOiAlNXUgaW52
YWxpZGF0aW5nICVzIGNyZWQgJXBcbiIsCisJCQl0YXNrLT50a19waWQsIGNyZWQtPmNyX2F1dGgt
PmF1X29wcy0+YXVfbmFtZSwgY3JlZCk7CisKIAkJY2xlYXJfYml0KFJQQ0FVVEhfQ1JFRF9VUFRP
REFURSwgJmNyZWQtPmNyX2ZsYWdzKTsKKwl9IGVsc2UgeworCQlkcHJpbnRrKCJSUEM6ICU1dSBj
cmVkIHBvaW50ZXIgaXMgMCIsIHRhc2stPnRrX3BpZCk7CisJfQogfQogCiBpbnQKLS0gCjEuNy4x
MC40Cgo=
--089e013cba44e2c78304f99b2078--
