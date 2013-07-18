Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esa-annu.mail.uoguelph.ca ([131.104.91.36]:2884 "EHLO
	esa-annu.net.uoguelph.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S934571Ab3GRXa5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jul 2013 19:30:57 -0400
Date: Thu, 18 Jul 2013 19:30:55 -0400 (EDT)
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Andre Heider <a.heider@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Message-ID: <1774242197.1390191.1374190255822.JavaMail.root@uoguelph.ca>
In-Reply-To: <CAHsu+b_FuHaa9LG1vRv1d5LwA5Ue_Ss2eoJsKEC5dx-rnuApOg@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFSv4: Fix a regression against the FreeBSD server
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_1390189_1474009002.1374190255820"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

------=_Part_1390189_1474009002.1374190255820
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

Andre Heider wrote:
> On Wed, Jul 17, 2013 at 11:59 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > Technically, the Linux client is allowed by the NFSv4 spec to send
> > 3 word bitmaps as part of an OPEN request. However, this causes the
> > current FreeBSD server to return NFS4ERR_ATTRNOTSUPP errors.
> >
> > Fix the regression by making the Linux client use a 2 word bitmap
> > unless
> > doing NFSv4.2 with labeled NFS.
> >
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Tested-by: Andre Heider <a.heider@gmail.com>
> 
I've attached the patch I plan to commit to FreeBSD's head soon, which
fixes the server so that it checks for the high order bitmaps words
being non-zero before replying with NFS4_ERR_ATTRNOTSUPP.

The patch is pretty straightforward, but if you can apply it to your
server and test it against the unpatched Linux client, that would be
appreciated.

It will take a while for the patch to find its way to a FreeBSD release,
so having the workaround in the Linux client will be very helpful.

Thanks for reporting this, rick


------=_Part_1390189_1474009002.1374190255820
Content-Type: text/x-patch; name=big-attrbits.patch
Content-Disposition: attachment; filename=big-attrbits.patch
Content-Transfer-Encoding: base64

LS0tIHN5cy9mcy9uZnMvbmZzX2NvbW1vbnN1YnMuYy5vcmlnCTIwMTMtMDctMTggMTk6MTU6MjUu
MDAwMDAwMDAwIC0wNDAwCisrKyBzeXMvZnMvbmZzL25mc19jb21tb25zdWJzLmMJMjAxMy0wNy0x
OCAxOToxNTo1OC4wMDAwMDAwMDAgLTA0MDAKQEAgLTc2MSwyMSArNzYxLDIxIEBAIG5mc3J2X2dl
dGF0dHJiaXRzKHN0cnVjdCBuZnNydl9kZXNjcmlwdCAKIAkJZXJyb3IgPSBORlNFUlJfQkFEWERS
OwogCQlnb3RvIG5mc21vdXQ7CiAJfQotCWlmIChjbnQgPiBORlNBVFRSQklUX01BWFdPUkRTKSB7
CisJaWYgKGNudCA+IE5GU0FUVFJCSVRfTUFYV09SRFMpCiAJCW91dGNudCA9IE5GU0FUVFJCSVRf
TUFYV09SRFM7Ci0JCWlmIChyZXRub3RzdXBwKQotCQkJKnJldG5vdHN1cHAgPSBORlNFUlJfQVRU
Uk5PVFNVUFA7Ci0JfSBlbHNlIHsKKwllbHNlCiAJCW91dGNudCA9IGNudDsKLQl9CiAJTkZTWkVS
T19BVFRSQklUKGF0dHJiaXRwKTsKIAlpZiAob3V0Y250ID4gMCkgewogCQlORlNNX0RJU1NFQ1Qo
dGwsIHVfaW50MzJfdCAqLCBvdXRjbnQgKiBORlNYX1VOU0lHTkVEKTsKIAkJZm9yIChpID0gMDsg
aSA8IG91dGNudDsgaSsrKQogCQkJYXR0cmJpdHAtPmJpdHNbaV0gPSBmeGRyX3Vuc2lnbmVkKHVf
aW50MzJfdCwgKnRsKyspOwogCX0KLQlpZiAoY250ID4gb3V0Y250KQotCQllcnJvciA9IG5mc21f
YWR2YW5jZShuZCwgKGNudCAtIG91dGNudCkgKiBORlNYX1VOU0lHTkVELCAtMSk7CisJZm9yIChp
ID0gMDsgaSA8IChjbnQgLSBvdXRjbnQpOyBpKyspIHsKKwkJTkZTTV9ESVNTRUNUKHRsLCB1X2lu
dDMyX3QgKiwgTkZTWF9VTlNJR05FRCk7CisJCWlmIChyZXRub3RzdXBwICE9IE5VTEwgJiYgKnRs
ICE9IDApCisJCQkqcmV0bm90c3VwcCA9IE5GU0VSUl9BVFRSTk9UU1VQUDsKKwl9CiAJaWYgKGNu
dHApCiAJCSpjbnRwID0gTkZTWF9VTlNJR05FRCArIChjbnQgKiBORlNYX1VOU0lHTkVEKTsKIG5m
c21vdXQ6Cg==
------=_Part_1390189_1474009002.1374190255820--
