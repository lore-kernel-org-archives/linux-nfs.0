Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga02.intel.com ([134.134.136.20]:25509 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755323Ab3FCCCs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 2 Jun 2013 22:02:48 -0400
From: "Yong, Fan" <fan.yong@intel.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Dilger, Andreas" <andreas.dilger@intel.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <steved@redhat.com>,
        "Peng Tao (bergwolf@gmail.com)" <bergwolf@gmail.com>
Subject: RE: [PATCH] nfs: support 64-bit root inode number in NFS FSID
Date: Mon, 3 Jun 2013 02:02:42 +0000
Message-ID: <7FB055E0B36B6F4EB93E637E0640A56F5FBF18E3@FMSMSX114.amr.corp.intel.com>
References: <CDC2ABAC.3341C%andreas.dilger@intel.com>
	 <CA+a=Yy4CQ7zG48dGOVjh8YBv0e+X1Gk4RxpDzdR4vM8JmqossQ@mail.gmail.com>
 <1369313382.3764.2.camel@leira.trondhjem.org>
In-Reply-To: <1369313382.3764.2.camel@leira.trondhjem.org>
Content-Type: multipart/mixed;
	boundary="_002_7FB055E0B36B6F4EB93E637E0640A56F5FBF18E3FMSMSX114amrcor_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_7FB055E0B36B6F4EB93E637E0640A56F5FBF18E3FMSMSX114amrcor_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Update the patch as suggested. Here is the patch...

--
Cheers,
Nasf



-----Original Message-----
From: Myklebust, Trond [mailto:Trond.Myklebust@netapp.com]=20
Sent: Thursday, May 23, 2013 8:50 PM
To: Peng Tao
Cc: Dilger, Andreas; J. Bruce Fields; linux-nfs@vger.kernel.org; Yong, Fan;=
 Steve Dickson
Subject: Re: [PATCH] nfs: support 64-bit root inode number in NFS FSID

On Thu, 2013-05-23 at 16:12 +0800, Peng Tao wrote:
> [nfs-utils patch needs to be sent to Steve Dickson (CC'ed)]
>=20
> On Thu, May 23, 2013 at 7:06 AM, Dilger, Andreas=20
> <andreas.dilger@intel.com> wrote:
> > When exporting a filesystem via NFS, it can generate several kinds=20
> > of NFS filesystem IDs. For most of cases, it uses a 32-bit inode=20
> > number in the NFS FSID, but this does not work on a filesystem using=20
> > a 64-bit root inode number.
> >
> > In kernel space, NFS can generate/use NFS FSID with a 64-bit inode=20
> > number for the "FSID_UUID16_INUM" type. Unfortunately, while the=20
> > user space nfs-utils decode the 64-bit inode number from the FSID=20
> > correctly, it is truncated when storing it in "struct parsed_fsid".
> > Expand the "struct parsed_fsid" inode field to store the full 64-bit=20
> > root inode number.
> >
> > Intel-bug-id: LU-2904
> > Signed-off-by: Fan Yong <fan.yong@intel.com>
> > Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
> > ---
> >  utils/mountd/cache.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >
> > diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c index=20
> > 517aa62..a7212e7 100644
> > --- a/utils/mountd/cache.c
> > +++ b/utils/mountd/cache.c
> > @@ -388,7 +388,7 @@ struct parsed_fsid {
> >         int fsidtype;
> >         /* We could use a union for this, but it would be more
> >          * complicated; why bother? */
> > -       unsigned int inode;
> > +       unsigned long long inode; /* We need 64-bits ino# */
> >         unsigned int minor;
> >         unsigned int major;
> >         unsigned int fsidnum;
> > --1.7.1
> >
> > Patch is also attached separately, since it will likely be butchered=20
> > by this email client.
> >
> >
> > Cheers, Andreas
> > --
> > Andreas Dilger

Why not just specify a uint64_t size then?

--
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

--_002_7FB055E0B36B6F4EB93E637E0640A56F5FBF18E3FMSMSX114amrcor_
Content-Type: application/octet-stream;
	name="0001-nfs-support-64-bit-root-inode-number-in-NFS-FSID.patch"
Content-Description: 0001-nfs-support-64-bit-root-inode-number-in-NFS-FSID.patch
Content-Disposition: attachment;
	filename="0001-nfs-support-64-bit-root-inode-number-in-NFS-FSID.patch";
	size=1779; creation-date="Mon, 03 Jun 2013 02:02:00 GMT";
	modification-date="Sat, 01 Jun 2013 12:48:05 GMT"
Content-Transfer-Encoding: base64

RnJvbSA2MDZkN2I0M2JlODQxNzczYmYxZDM0MmQ2ZGUwMjY3YzhiYjBiNDVlIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBGYW4gWW9uZyA8eW9uZy5mYW5Ad2hhbWNsb3VkLmNvbT4KRGF0
ZTogTW9uLCAxMyBNYXkgMjAxMyAxMzo1Mzo0MiArMDgwMApTdWJqZWN0OiBbUEFUQ0hdIG5mczog
c3VwcG9ydCA2NC1iaXQgcm9vdCBpbm9kZSBudW1iZXIgaW4gTkZTIEZTSUQKCldoZW4gZXhwb3J0
aW5nIGEgZmlsZXN5c3RlbSB2aWEgTkZTLCBpdCBjYW4gZ2VuZXJhdGUgc2V2ZXJhbCBraW5kcwpv
ZiBORlMgZmlsZXN5c3RlbSBJRHMuIEZvciBtb3N0IG9mIGNhc2VzLCBpdCB1c2VzIGEgMzItYml0
IGlub2RlCm51bWJlciBpbiB0aGUgTkZTIEZTSUQsIGJ1dCB0aGlzIGRvZXMgbm90IHdvcmsgb24g
YSBmaWxlc3lzdGVtCnVzaW5nIGEgNjQtYml0IHJvb3QgaW5vZGUgbnVtYmVyLgoKSW4ga2VybmVs
IHNwYWNlLCBORlMgY2FuIGdlbmVyYXRlL3VzZSBORlMgRlNJRCB3aXRoIGEgNjQtYml0IGlub2Rl
Cm51bWJlciBmb3IgdGhlICJGU0lEX1VVSUQxNl9JTlVNIiB0eXBlLiBVbmZvcnR1bmF0ZWx5LCB3
aGlsZSB0aGUKdXNlciBzcGFjZSBuZnMtdXRpbHMgZGVjb2RlIHRoZSA2NC1iaXQgaW5vZGUgbnVt
YmVyIGZyb20gdGhlIEZTSUQKY29ycmVjdGx5LCBpdCBpcyB0cnVuY2F0ZWQgd2hlbiBzdG9yaW5n
IGl0IGluICJzdHJ1Y3QgcGFyc2VkX2ZzaWQiLgpFeHBhbmQgdGhlICJzdHJ1Y3QgcGFyc2VkX2Zz
aWQiIGlub2RlIGZpZWxkIHRvIHN0b3JlIHRoZSBmdWxsIDY0LWJpdApyb290IGlub2RlIG51bWJl
ci4KCkludGVsLWJ1Zy1pZDogTFUtMjkwNApTaWduZWQtb2ZmLWJ5OiBGYW4gWW9uZyA8ZmFuLnlv
bmdAaW50ZWwuY29tPgpTaWduZWQtb2ZmLWJ5OiBBbmRyZWFzIERpbGdlciA8YW5kcmVhcy5kaWxn
ZXJAaW50ZWwuY29tPgotLS0KIHV0aWxzL21vdW50ZC9jYWNoZS5jIHwgICAgNCArKy0tCiAxIGZp
bGVzIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQg
YS91dGlscy9tb3VudGQvY2FjaGUuYyBiL3V0aWxzL21vdW50ZC9jYWNoZS5jCmluZGV4IDUxN2Fh
NjIuLmJlOTliN2QgMTAwNjQ0Ci0tLSBhL3V0aWxzL21vdW50ZC9jYWNoZS5jCisrKyBiL3V0aWxz
L21vdW50ZC9jYWNoZS5jCkBAIC0zODUsMTAgKzM4NSwxMCBAQCBzdGF0aWMgYm9vbCBzdWJleHBv
cnQoc3RydWN0IGV4cG9ydGVudCAqZTEsIHN0cnVjdCBleHBvcnRlbnQgKmUyKQogfQogCiBzdHJ1
Y3QgcGFyc2VkX2ZzaWQgeworCXVpbnQ2NF90IGlub2RlOyAvKiBXZSBuZWVkIDY0LWJpdHMgaW5v
IyAqLwogCWludCBmc2lkdHlwZTsKIAkvKiBXZSBjb3VsZCB1c2UgYSB1bmlvbiBmb3IgdGhpcywg
YnV0IGl0IHdvdWxkIGJlIG1vcmUKIAkgKiBjb21wbGljYXRlZDsgd2h5IGJvdGhlcj8gKi8KLQl1
bnNpZ25lZCBpbnQgaW5vZGU7CiAJdW5zaWduZWQgaW50IG1pbm9yOwogCXVuc2lnbmVkIGludCBt
YWpvcjsKIAl1bnNpZ25lZCBpbnQgZnNpZG51bTsKQEAgLTQwMCw3ICs0MDAsNyBAQCBzdGF0aWMg
aW50IHBhcnNlX2ZzaWQoaW50IGZzaWR0eXBlLCBpbnQgZnNpZGxlbiwgY2hhciAqZnNpZCwKIAkJ
c3RydWN0IHBhcnNlZF9mc2lkICpwYXJzZWQpCiB7CiAJdW5zaWduZWQgaW50IGRldjsKLQl1bnNp
Z25lZCBsb25nIGxvbmcgaW5vZGU2NDsKKwl1aW50NjRfdCBpbm9kZTY0OwogCiAJbWVtc2V0KHBh
cnNlZCwgMCwgc2l6ZW9mKCpwYXJzZWQpKTsKIAlwYXJzZWQtPmZzaWR0eXBlID0gZnNpZHR5cGU7
Ci0tIAoxLjcuMQoK

--_002_7FB055E0B36B6F4EB93E637E0640A56F5FBF18E3FMSMSX114amrcor_--
