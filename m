From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: NFS readonly failover and linux?
Date: Tue, 01 Feb 2005 12:45:11 -0800
Message-ID: <1107290711.10571.44.camel@seki.nac.uci.edu>
References: <1106871309.6181.254.camel@seki.nac.uci.edu>
	 <Pine.LNX.4.61.0501291127450.1607@donald.themaw.net>
	 <1107205302.4071.17.camel@seki.nac.uci.edu>
	 <Pine.LNX.4.58.0502010945400.25875@wombat.indigo.net.au>
	 <16895.57760.531261.8465@segfault.boston.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-DcQMhw9MIxIlQvh6ZSj2"
Cc: strombrg@dcs.nac.uci.edu, Ian Kent <raven@themaw.net>,
	autofs mailing list <autofs@linux.kernel.org>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cw4to-00088g-H6
	for nfs@lists.sourceforge.net; Tue, 01 Feb 2005 12:45:24 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cw4th-0006Jp-QO
	for nfs@lists.sourceforge.net; Tue, 01 Feb 2005 12:45:24 -0800
To: jmoyer@redhat.com
In-Reply-To: <16895.57760.531261.8465@segfault.boston.redhat.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--=-DcQMhw9MIxIlQvh6ZSj2
Content-Type: multipart/mixed; boundary="=-CUy7NdRRXlGCofzP3gZC"


--=-CUy7NdRRXlGCofzP3gZC
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2005-02-01 at 15:08 -0500, Jeff Moyer wrote:

> So what is the actual problem, here?  Are you using the automounter?  Wha=
t
> do your config files look like?

I guess the problems are:

1) I haven't looked into this very far
2) I was beginning to think I shouldn't continue looking into this
because of the red herring in the man page
3) I've been trying sun-style automount maps only (copied from a sun),
and I'm not really sure if linux' autofs is compatible with exactly the
same format

> raven> Can you confirm please Jeff?
>=20
> raven> Perhaps you are seeing a bug which needs to be addressed.
>=20
> Yes, the replicated server code is present in both of these versions.

Sweet.


>=20
> raven> Once again I believe that the kernels mentioned here are up to dat=
e
> raven> wrt autofs.
>=20
> raven> Certainly, the latest FC3 kernel is at 2.6.10 which has all the
> raven> autofs4 updates included in the base kernel.
>=20
> raven> I believe the latest update to RHEL3 is also up to date. Jeff?
>=20
> Yes, both kernels have the necessary patches to support replicated server=
.
>=20
> raven> So perhaps you could send a log trace with the "--debug" option
> raven> added to the master map entry.
>=20
> And please include the contents of your maps!


I've attached a shar archive of the two relevant files that we use on
Solaris.


>=20

--=-CUy7NdRRXlGCofzP3gZC
Content-Disposition: attachment; filename=automount-maps.shar
Content-Type: application/x-shellscript; name=automount-maps.shar
Content-Transfer-Encoding: base64

IyEvYmluL3NoCiMgVGhpcyBpcyBhIHNoZWxsIGFyY2hpdmUgKHByb2R1Y2VkIGJ5IEdOVSBzaGFy
dXRpbHMgNC4yLjEpLgojIFRvIGV4dHJhY3QgdGhlIGZpbGVzIGZyb20gdGhpcyBhcmNoaXZlLCBz
YXZlIGl0IHRvIHNvbWUgRklMRSwgcmVtb3ZlCiMgZXZlcnl0aGluZyBiZWZvcmUgdGhlIGAhL2Jp
bi9zaCcgbGluZSBhYm92ZSwgdGhlbiB0eXBlIGBzaCBGSUxFJy4KIwojIE1hZGUgb24gMjAwNS0w
Mi0wMSAxMjo0MyBQU1QgYnkgPGRjc0BtZXRlci5lbmcudWNpLmVkdT4uCiMgU291cmNlIGRpcmVj
dG9yeSB3YXMgYC9EQ1MnLgojCiMgRXhpc3RpbmcgZmlsZXMgd2lsbCAqbm90KiBiZSBvdmVyd3Jp
dHRlbiB1bmxlc3MgYC1jJyBpcyBzcGVjaWZpZWQuCiMKIyBUaGlzIHNoYXIgY29udGFpbnM6CiMg
bGVuZ3RoIG1vZGUgICAgICAgbmFtZQojIC0tLS0tLSAtLS0tLS0tLS0tIC0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQojICAgIDEzMCAtcnctci0tci0tIC9ldGMvYXV0
b19tYXN0ZXIKIyAgICAxNzAgLXJ3LXItLXItLSAvZXRjL2F1dG9fZGNzbGliCiMKc2F2ZV9JRlM9
IiR7SUZTfSIKSUZTPSIke0lGU306IgpnZXR0ZXh0X2Rpcj1GQUlMRUQKbG9jYWxlX2Rpcj1GQUlM
RUQKZmlyc3RfcGFyYW09IiQxIgpmb3IgZGlyIGluICRQQVRICmRvCiAgaWYgdGVzdCAiJGdldHRl
eHRfZGlyIiA9IEZBSUxFRCAmJiB0ZXN0IC1mICRkaXIvZ2V0dGV4dCBcCiAgICAgJiYgKCRkaXIv
Z2V0dGV4dCAtLXZlcnNpb24gPi9kZXYvbnVsbCAyPiYxKQogIHRoZW4KICAgIHNldCBgJGRpci9n
ZXR0ZXh0IC0tdmVyc2lvbiAyPiYxYAogICAgaWYgdGVzdCAiJDMiID0gR05VCiAgICB0aGVuCiAg
ICAgIGdldHRleHRfZGlyPSRkaXIKICAgIGZpCiAgZmkKICBpZiB0ZXN0ICIkbG9jYWxlX2RpciIg
PSBGQUlMRUQgJiYgdGVzdCAtZiAkZGlyL3NoYXIgXAogICAgICYmICgkZGlyL3NoYXIgLS1wcmlu
dC10ZXh0LWRvbWFpbi1kaXIgPi9kZXYvbnVsbCAyPiYxKQogIHRoZW4KICAgIGxvY2FsZV9kaXI9
YCRkaXIvc2hhciAtLXByaW50LXRleHQtZG9tYWluLWRpcmAKICBmaQpkb25lCklGUz0iJHNhdmVf
SUZTIgppZiB0ZXN0ICIkbG9jYWxlX2RpciIgPSBGQUlMRUQgfHwgdGVzdCAiJGdldHRleHRfZGly
IiA9IEZBSUxFRAp0aGVuCiAgZWNobz1lY2hvCmVsc2UKICBURVhURE9NQUlORElSPSRsb2NhbGVf
ZGlyCiAgZXhwb3J0IFRFWFRET01BSU5ESVIKICBURVhURE9NQUlOPXNoYXJ1dGlscwogIGV4cG9y
dCBURVhURE9NQUlOCiAgZWNobz0iJGdldHRleHRfZGlyL2dldHRleHQgLXMiCmZpCmlmIHRvdWNo
IC1hbSAtdCAyMDAxMTIzMTIzNTkuNTkgJCQudG91Y2ggPi9kZXYvbnVsbCAyPiYxICYmIHRlc3Qg
ISAtZiAyMDAxMTIzMTIzNTkuNTkgLWEgLWYgJCQudG91Y2g7IHRoZW4KICBzaGFyX3RvdWNoPSd0
b3VjaCAtYW0gLXQgJDEkMiQzJDQkNSQ2LiQ3ICIkOCInCmVsaWYgdG91Y2ggLWFtIDEyMzEyMzU5
MjAwMS41OSAkJC50b3VjaCA+L2Rldi9udWxsIDI+JjEgJiYgdGVzdCAhIC1mIDEyMzEyMzU5MjAw
MS41OSAtYSAhIC1mIDEyMzEyMzU5MjAwMS41IC1hIC1mICQkLnRvdWNoOyB0aGVuCiAgc2hhcl90
b3VjaD0ndG91Y2ggLWFtICQzJDQkNSQ2JDEkMi4kNyAiJDgiJwplbGlmIHRvdWNoIC1hbSAxMjMx
MjM1OTAxICQkLnRvdWNoID4vZGV2L251bGwgMj4mMSAmJiB0ZXN0ICEgLWYgMTIzMTIzNTkwMSAt
YSAtZiAkJC50b3VjaDsgdGhlbgogIHNoYXJfdG91Y2g9J3RvdWNoIC1hbSAkMyQ0JDUkNiQyICIk
OCInCmVsc2UKICBzaGFyX3RvdWNoPToKICBlY2hvCiAgJGVjaG8gJ1dBUk5JTkc6IG5vdCByZXN0
b3JpbmcgdGltZXN0YW1wcy4gIENvbnNpZGVyIGdldHRpbmcgYW5kJwogICRlY2hvICJpbnN0YWxs
aW5nIEdOVSBcYHRvdWNoJywgZGlzdHJpYnV0ZWQgaW4gR05VIEZpbGUgVXRpbGl0aWVzLi4uIgog
IGVjaG8KZmkKcm0gLWYgMjAwMTEyMzEyMzU5LjU5IDEyMzEyMzU5MjAwMS41OSAxMjMxMjM1OTIw
MDEuNSAxMjMxMjM1OTAxICQkLnRvdWNoCiMKaWYgbWtkaXIgX3NoMDkxMTg7IHRoZW4KICAkZWNo
byAneCAtJyAnY3JlYXRpbmcgbG9jayBkaXJlY3RvcnknCmVsc2UKICAkZWNobyAnZmFpbGVkIHRv
IGNyZWF0ZSBsb2NrIGRpcmVjdG9yeScKICBleGl0IDEKZmkKIyA9PT09PT09PT09PT09IC9ldGMv
YXV0b19tYXN0ZXIgPT09PT09PT09PT09PT0KaWYgdGVzdCAhIC1kICcvZXRjJzsgdGhlbgogICRl
Y2hvICd4IC0nICdjcmVhdGluZyBkaXJlY3RvcnknICcvZXRjJwogIG1rZGlyICcvZXRjJwpmaQpp
ZiB0ZXN0IC1mICcvZXRjL2F1dG9fbWFzdGVyJyAmJiB0ZXN0ICIkZmlyc3RfcGFyYW0iICE9IC1j
OyB0aGVuCiAgJGVjaG8gJ3ggLScgU0tJUFBJTkcgJy9ldGMvYXV0b19tYXN0ZXInICcoZmlsZSBh
bHJlYWR5IGV4aXN0cyknCmVsc2UKICAkZWNobyAneCAtJyBleHRyYWN0aW5nICcvZXRjL2F1dG9f
bWFzdGVyJyAnKHRleHQpJwogIHNlZCAncy9eWC8vJyA8PCAnU0hBUl9FT0YnID4gJy9ldGMvYXV0
b19tYXN0ZXInICYmCiMgTWFzdGVyIG1hcCBmb3IgYXV0b21vdW50ZXIKIworYXV0by5tYXN0ZXIK
L25ldAkJLWhvc3RzCQktbm9zdWlkLG5vYnJvd3NlCiMvaG9tZQkJYXV0b19ob21lCS1ub2Jyb3dz
ZQojL3hmbgkJLXhmbgovLSBhdXRvX2Rjc2xpYgpTSEFSX0VPRgogIChzZXQgMjAgMDQgMDggMDMg
MTcgMTMgMTcgJy9ldGMvYXV0b19tYXN0ZXInOyBldmFsICIkc2hhcl90b3VjaCIpICYmCiAgY2ht
b2QgMDY0NCAnL2V0Yy9hdXRvX21hc3RlcicgfHwKICAkZWNobyAncmVzdG9yZSBvZicgJy9ldGMv
YXV0b19tYXN0ZXInICdmYWlsZWQnCiAgaWYgKCBtZDVzdW0gLS1oZWxwIDI+JjEgfCBncmVwICdz
YWdlOiBtZDVzdW0gXFsnICkgPi9kZXYvbnVsbCAyPiYxIFwKICAmJiAoIG1kNXN1bSAtLXZlcnNp
b24gMj4mMSB8IGdyZXAgLXYgJ3RleHR1dGlscyAxLjEyJyApID4vZGV2L251bGw7IHRoZW4KICAg
IG1kNXN1bSAtYyA8PCBTSEFSX0VPRiA+L2Rldi9udWxsIDI+JjEgXAogICAgfHwgJGVjaG8gJy9l
dGMvYXV0b19tYXN0ZXI6JyAnTUQ1IGNoZWNrIGZhaWxlZCcKYTJiMTk0OTgyZGI5NzhlZGJkZjNl
ZTQ0MWRmNTgxNTMgIC9ldGMvYXV0b19tYXN0ZXIKU0hBUl9FT0YKICBlbHNlCiAgICBzaGFyX2Nv
dW50PSJgTENfQUxMPSBMQ19DVFlQRT0gTEFORz0gd2MgLWMgPCAnL2V0Yy9hdXRvX21hc3Rlcidg
IgogICAgdGVzdCAxMzAgLWVxICIkc2hhcl9jb3VudCIgfHwKICAgICRlY2hvICcvZXRjL2F1dG9f
bWFzdGVyOicgJ29yaWdpbmFsIHNpemUnICcxMzAsJyAnY3VycmVudCBzaXplJyAiJHNoYXJfY291
bnQhIgogIGZpCmZpCiMgPT09PT09PT09PT09PSAvZXRjL2F1dG9fZGNzbGliID09PT09PT09PT09
PT09CmlmIHRlc3QgLWYgJy9ldGMvYXV0b19kY3NsaWInICYmIHRlc3QgIiRmaXJzdF9wYXJhbSIg
IT0gLWM7IHRoZW4KICAkZWNobyAneCAtJyBTS0lQUElORyAnL2V0Yy9hdXRvX2Rjc2xpYicgJyhm
aWxlIGFscmVhZHkgZXhpc3RzKScKZWxzZQogICRlY2hvICd4IC0nIGV4dHJhY3RpbmcgJy9ldGMv
YXV0b19kY3NsaWInICcodGV4dCknCiAgc2VkICdzL15YLy8nIDw8ICdTSEFSX0VPRicgPiAnL2V0
Yy9hdXRvX2Rjc2xpYicgJiYKL2RjcyAtcm8gZGNzbGliMS5uYWNzLnVjaS5lZHUsZGNzbGliMi5u
YWNzLnVjaS5lZHUsZGNzbGliMy5uYWNzLnVjaS5lZHU6L2Rjc3BkYi9zdW40LTUKL2Rjc2xpYiAt
cm8gZGNzbGliMS5uYWNzLnVjaS5lZHUsZGNzbGliMi5uYWNzLnVjaS5lZHUsZGNzbGliMy5uYWNz
LnVjaS5lZHU6L2Rjc3BkYQpTSEFSX0VPRgogIChzZXQgMjAgMDQgMDggMDMgMTcgMTMgMTcgJy9l
dGMvYXV0b19kY3NsaWInOyBldmFsICIkc2hhcl90b3VjaCIpICYmCiAgY2htb2QgMDY0NCAnL2V0
Yy9hdXRvX2Rjc2xpYicgfHwKICAkZWNobyAncmVzdG9yZSBvZicgJy9ldGMvYXV0b19kY3NsaWIn
ICdmYWlsZWQnCiAgaWYgKCBtZDVzdW0gLS1oZWxwIDI+JjEgfCBncmVwICdzYWdlOiBtZDVzdW0g
XFsnICkgPi9kZXYvbnVsbCAyPiYxIFwKICAmJiAoIG1kNXN1bSAtLXZlcnNpb24gMj4mMSB8IGdy
ZXAgLXYgJ3RleHR1dGlscyAxLjEyJyApID4vZGV2L251bGw7IHRoZW4KICAgIG1kNXN1bSAtYyA8
PCBTSEFSX0VPRiA+L2Rldi9udWxsIDI+JjEgXAogICAgfHwgJGVjaG8gJy9ldGMvYXV0b19kY3Ns
aWI6JyAnTUQ1IGNoZWNrIGZhaWxlZCcKZDE3Y2Y2YjJjMGFkZDU0OGVkMzM1YzQzMWY1YmUwNjMg
IC9ldGMvYXV0b19kY3NsaWIKU0hBUl9FT0YKICBlbHNlCiAgICBzaGFyX2NvdW50PSJgTENfQUxM
PSBMQ19DVFlQRT0gTEFORz0gd2MgLWMgPCAnL2V0Yy9hdXRvX2Rjc2xpYidgIgogICAgdGVzdCAx
NzAgLWVxICIkc2hhcl9jb3VudCIgfHwKICAgICRlY2hvICcvZXRjL2F1dG9fZGNzbGliOicgJ29y
aWdpbmFsIHNpemUnICcxNzAsJyAnY3VycmVudCBzaXplJyAiJHNoYXJfY291bnQhIgogIGZpCmZp
CnJtIC1mciBfc2gwOTExOApleGl0IDAK


--=-CUy7NdRRXlGCofzP3gZC--

--=-DcQMhw9MIxIlQvh6ZSj2
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBB/+pXo0feVm00f/8RAov4AJ0SAXktb+DSN4RY0tWFBIb1NpH1agCeOsBQ
HKaxOjcpj5i2BkelWIHs19U=
=35cF
-----END PGP SIGNATURE-----

--=-DcQMhw9MIxIlQvh6ZSj2--



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
