From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH -next] nfs: fix ISO C90 warning
Date: Thu, 17 Dec 2009 18:00:29 +0800
Message-ID: <2375c9f90912170200m12a5310cg90343c5c1081fbb8@mail.gmail.com>
References: <20091215165309.58e98eea.sfr@canb.auug.org.au>
	 <20091216142334.6a0ba115.randy.dunlap@oracle.com>
	 <1261003219.13878.6.camel@localhost>
	 <20091216144700.34b80b4b.randy.dunlap@oracle.com>
	 <alpine.LFD.2.00.0912162355350.2755@localhost.localdomain>
	 <1261004497.13878.9.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016e64f69ec6e924d047ae9b17a
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1261004497.13878.9.camel@localhost>
Sender: linux-next-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--0016e64f69ec6e924d047ae9b17a
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 17, 2009 at 7:01 AM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Wed, 2009-12-16 at 23:58 +0100, Thomas Gleixner wrote:
>> On Wed, 16 Dec 2009, Randy Dunlap wrote:
>> > On Wed, 16 Dec 2009 17:40:19 -0500 Trond Myklebust wrote:
>> >
>> > > On Wed, 2009-12-16 at 14:23 -0800, Randy Dunlap wrote:
>> > > > From: Randy Dunlap <randy.dunlap@oracle.com>
>> > > >
>> > > > Fix gcc ISO C90 warning:
>> > > >
>> > > > fs/nfs/callback.c:356: warning: ISO C90 forbids mixed declarations=
 and code
>> > > >
>> > > > Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
>> > > > ---
>> > > > =C2=A0fs/nfs/callback.c | =C2=A0 =C2=A02 +-
>> > > > =C2=A01 file changed, 1 insertion(+), 1 deletion(-)
>> > > >
>> > > > --- linux-next-20091215.orig/fs/nfs/callback.c
>> > > > +++ linux-next-20091215/fs/nfs/callback.c
>> > > > @@ -352,8 +352,8 @@ static int check_gss_callback_principal(
>> > > > =C2=A0static int nfs_callback_authenticate(struct svc_rqst *rqstp)
>> > > > =C2=A0{
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct nfs_client *clp;
>> > > > - =C2=A0 =C2=A0 =C2=A0 RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 int ret =3D SVC_OK;
>> > > > + =C2=A0 =C2=A0 =C2=A0 RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
>> > > >
>> > >
>> > > What version of gcc is giving rise to this warning?
>> >
>> > > gcc --version
>> > gcc (GCC) 4.2.1 (SUSE Linux)
>> >
>> > > RPC_IFDEBUG is a macro that either evaluates to its argument, or to
>> > > nothing, depending on whether or not RPC_DEBUG is defined or not. In
>> > > neither case should it evaluate to anything illegal under C90 rules
>> > > afaics.
>> >
>> > Yep. =C2=A0Odd warning.
>>
>> Not really. If the debug macro evaluates to nothing then you have:
>>
>> =C2=A0 =C2=A0 struct nfs_client *clp;
>> =C2=A0 =C2=A0 ;
>> =C2=A0 =C2=A0 int ret =3D SVC_OK;
>>
>> So you have a stray semicolon, which is interpreted as an empty code
>> line. That qualifies for the mixed declaration and code case :)
>>
>> I know it's nitpicking, but ...
>
> Ah... I see what you mean.
>
> So really what we should do is just move that semicolon inside the
> macro. That would change the !RPC_DEBUG case to
>
> =C2=A0 =C2=A0struct nfs_client *clp;
>
> =C2=A0 =C2=A0int ret =3D SVC_OK;
>
> which is 100% legal...
>

Hi,
Check that currently all usages of RPC_DEBUG are the same,
we can replace them all.

What do you think about the attached patch?

Sorry for attaching it, I have a bad mail environment here.

Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>

--0016e64f69ec6e924d047ae9b17a
Content-Type: text/plain; charset=US-ASCII; name="rpc-replace-rpc-ifdebug.diff"
Content-Disposition: attachment; filename="rpc-replace-rpc-ifdebug.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g3bd52yd0

ZGlmZiAtLWdpdCBhL2ZzL2xvY2tkL3N2Yy5jIGIvZnMvbG9ja2Qvc3ZjLmMKaW5kZXggZTUwY2Zh
My4uNGZjZTBmMiAxMDA2NDQKLS0tIGEvZnMvbG9ja2Qvc3ZjLmMKKysrIGIvZnMvbG9ja2Qvc3Zj
LmMKQEAgLTE1Miw3ICsxNTIsNyBAQCBsb2NrZCh2b2lkICp2cnFzdHApCiAJICovCiAJd2hpbGUg
KCFrdGhyZWFkX3Nob3VsZF9zdG9wKCkpIHsKIAkJbG9uZyB0aW1lb3V0ID0gTUFYX1NDSEVEVUxF
X1RJTUVPVVQ7Ci0JCVJQQ19JRkRFQlVHKGNoYXIgYnVmW1JQQ19NQVhfQUREUkJVRkxFTl0pOwor
CQlSUENCVUZfSUZERUJVRyhidWYpOwogCiAJCS8qIHVwZGF0ZSBzdl9tYXhjb25uIGlmIGl0IGhh
cyBjaGFuZ2VkICovCiAJCXJxc3RwLT5ycV9zZXJ2ZXItPnN2X21heGNvbm4gPSBubG1fbWF4X2Nv
bm5lY3Rpb25zOwpkaWZmIC0tZ2l0IGEvZnMvbmZzL2NhbGxiYWNrLmMgYi9mcy9uZnMvY2FsbGJh
Y2suYwppbmRleCA3M2FiMjIwLi5lMDViNmZjIDEwMDY0NAotLS0gYS9mcy9uZnMvY2FsbGJhY2su
YworKysgYi9mcy9uZnMvY2FsbGJhY2suYwpAQCAtMzUyLDcgKzM1Miw3IEBAIHN0YXRpYyBpbnQg
Y2hlY2tfZ3NzX2NhbGxiYWNrX3ByaW5jaXBhbChzdHJ1Y3QgbmZzX2NsaWVudCAqY2xwLAogc3Rh
dGljIGludCBuZnNfY2FsbGJhY2tfYXV0aGVudGljYXRlKHN0cnVjdCBzdmNfcnFzdCAqcnFzdHAp
CiB7CiAJc3RydWN0IG5mc19jbGllbnQgKmNscDsKLQlSUENfSUZERUJVRyhjaGFyIGJ1ZltSUENf
TUFYX0FERFJCVUZMRU5dKTsKKwlSUENCVUZfSUZERUJVRyhidWYpOwogCWludCByZXQgPSBTVkNf
T0s7CiAKIAkvKiBEb24ndCB0YWxrIHRvIHN0cmFuZ2VycyAqLwpkaWZmIC0tZ2l0IGEvZnMvbmZz
ZC9uZnNmaC5jIGIvZnMvbmZzZC9uZnNmaC5jCmluZGV4IDFjMTIxNzcuLjdhODQ0MzMgMTAwNjQ0
Ci0tLSBhL2ZzL25mc2QvbmZzZmguYworKysgYi9mcy9uZnNkL25mc2ZoLmMKQEAgLTkwLDcgKzkw
LDcgQEAgc3RhdGljIF9fYmUzMiBuZnNkX3NldHVzZXJfYW5kX2NoZWNrX3BvcnQoc3RydWN0IHN2
Y19ycXN0ICpycXN0cCwKIAogCS8qIENoZWNrIGlmIHRoZSByZXF1ZXN0IG9yaWdpbmF0ZWQgZnJv
bSBhIHNlY3VyZSBwb3J0LiAqLwogCWlmICghcnFzdHAtPnJxX3NlY3VyZSAmJiAoZmxhZ3MgJiBO
RlNFWFBfSU5TRUNVUkVfUE9SVCkpIHsKLQkJUlBDX0lGREVCVUcoY2hhciBidWZbUlBDX01BWF9B
RERSQlVGTEVOXSk7CisJCVJQQ0JVRl9JRkRFQlVHKGJ1Zik7CiAJCWRwcmludGsoS0VSTl9XQVJO
SU5HCiAJCSAgICAgICAibmZzZDogcmVxdWVzdCBmcm9tIGluc2VjdXJlIHBvcnQgJXMhXG4iLAog
CQkgICAgICAgc3ZjX3ByaW50X2FkZHIocnFzdHAsIGJ1Ziwgc2l6ZW9mKGJ1ZikpKTsKZGlmZiAt
LWdpdCBhL2luY2x1ZGUvbGludXgvc3VucnBjL2RlYnVnLmggYi9pbmNsdWRlL2xpbnV4L3N1bnJw
Yy9kZWJ1Zy5oCmluZGV4IGMyNzg2ZjIuLjEzMTg1YmIgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGlu
dXgvc3VucnBjL2RlYnVnLmgKKysrIGIvaW5jbHVkZS9saW51eC9zdW5ycGMvZGVidWcuaApAQCAt
NTIsMTEgKzUyLDExIEBAIGV4dGVybiB1bnNpZ25lZCBpbnQJCW5sbV9kZWJ1ZzsKICNpZmRlZiBS
UENfREVCVUcJCQkKICMgZGVmaW5lIGlmZGVidWcoZmFjKQkJaWYgKHVubGlrZWx5KHJwY19kZWJ1
ZyAmIFJQQ0RCR18jI2ZhYykpCiAjIGRlZmluZSBkZnByaW50ayhmYWMsIGFyZ3MuLi4pCWRvIHsg
aWZkZWJ1ZyhmYWMpIHByaW50ayhhcmdzKTsgfSB3aGlsZSgwKQotIyBkZWZpbmUgUlBDX0lGREVC
VUcoeCkJCXgKKyMgZGVmaW5lIFJQQ0JVRl9JRkRFQlVHKHgpCWNoYXIgeFtSUENfTUFYX0FERFJC
VUZMRU5dCiAjZWxzZQogIyBkZWZpbmUgaWZkZWJ1ZyhmYWMpCQlpZiAoMCkKICMgZGVmaW5lIGRm
cHJpbnRrKGZhYywgYXJncy4uLikJZG8gOyB3aGlsZSAoMCkKLSMgZGVmaW5lIFJQQ19JRkRFQlVH
KHgpCisjIGRlZmluZSBSUENCVUZfSUZERUJVRyh4KQljaGFyIHhbMF0KICNlbmRpZgogCiAvKgpk
aWZmIC0tZ2l0IGEvbmV0L3N1bnJwYy9zdmNzb2NrLmMgYi9uZXQvc3VucnBjL3N2Y3NvY2suYwpp
bmRleCA4NzA5MjllLi40MjVjNGMxIDEwMDY0NAotLS0gYS9uZXQvc3VucnBjL3N2Y3NvY2suYwor
KysgYi9uZXQvc3VucnBjL3N2Y3NvY2suYwpAQCAtMjI4LDcgKzIyOCw3IEBAIHN0YXRpYyBpbnQg
c3ZjX3NlbmR0byhzdHJ1Y3Qgc3ZjX3Jxc3QgKnJxc3RwLCBzdHJ1Y3QgeGRyX2J1ZiAqeGRyKQog
CWludAkJbGVuID0gMDsKIAl1bnNpZ25lZCBsb25nIHRhaWxvZmY7CiAJdW5zaWduZWQgbG9uZyBo
ZWFkb2ZmOwotCVJQQ19JRkRFQlVHKGNoYXIgYnVmW1JQQ19NQVhfQUREUkJVRkxFTl0pOworCVJQ
Q0JVRl9JRkRFQlVHKGJ1Zik7CiAKIAlpZiAocnFzdHAtPnJxX3Byb3QgPT0gSVBQUk9UT19VRFAp
IHsKIAkJc3RydWN0IG1zZ2hkciBtc2cgPSB7CkBAIC04MDgsNyArODA4LDcgQEAgc3RhdGljIHN0
cnVjdCBzdmNfeHBydCAqc3ZjX3RjcF9hY2NlcHQoc3RydWN0IHN2Y194cHJ0ICp4cHJ0KQogCXN0
cnVjdCBzb2NrZXQJKm5ld3NvY2s7CiAJc3RydWN0IHN2Y19zb2NrCSpuZXdzdnNrOwogCWludAkJ
ZXJyLCBzbGVuOwotCVJQQ19JRkRFQlVHKGNoYXIgYnVmW1JQQ19NQVhfQUREUkJVRkxFTl0pOwor
CVJQQ0JVRl9JRkRFQlVHKGJ1Zik7CiAKIAlkcHJpbnRrKCJzdmM6IHRjcF9hY2NlcHQgJXAgc29j
ayAlcFxuIiwgc3Zzaywgc29jayk7CiAJaWYgKCFzb2NrKQpAQCAtMTQxMCw3ICsxNDEwLDcgQEAg
c3RhdGljIHN0cnVjdCBzdmNfeHBydCAqc3ZjX2NyZWF0ZV9zb2NrZXQoc3RydWN0IHN2Y19zZXJ2
ICpzZXJ2LAogCWludAkJbmV3bGVuOwogCWludAkJZmFtaWx5OwogCWludAkJdmFsOwotCVJQQ19J
RkRFQlVHKGNoYXIgYnVmW1JQQ19NQVhfQUREUkJVRkxFTl0pOworCVJQQ0JVRl9JRkRFQlVHKGJ1
Zik7CiAKIAlkcHJpbnRrKCJzdmM6IHN2Y19jcmVhdGVfc29ja2V0KCVzLCAlZCwgJXMpXG4iLAog
CQkJc2Vydi0+c3ZfcHJvZ3JhbS0+cGdfbmFtZSwgcHJvdG9jb2wsCg==
--0016e64f69ec6e924d047ae9b17a--
