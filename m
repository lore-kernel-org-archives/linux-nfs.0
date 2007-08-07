From: "Kottaridis, Chris" <chris.kottaridis@windriver.com>
Subject: rpc.mountd memory leak
Date: Tue, 7 Aug 2007 14:27:39 -0700
Message-ID: <37B62E0F71C9E14B9859FADB1FC3E3E14EB034@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C7D939.C81F5E91"
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIWcQ-0007cV-RY
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 14:29:35 -0700
Received: from mail.windriver.com ([147.11.1.11] helo=mail.wrs.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IIWaf-0007EM-Gf
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 14:27:45 -0700
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.wrs.com (8.13.6/8.13.6) with ESMTP id l77LReWm016502
	for <nfs@lists.sourceforge.net>; Tue, 7 Aug 2007 14:27:40 -0700 (PDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.

------_=_NextPart_001_01C7D939.C81F5E91
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_002_01C7D939.C81F5E91"


------_=_NextPart_002_01C7D939.C81F5E91
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

I've got a customer experiencing a small memory leak in rpc.mountd using
nfs-utils-1.0.7. For their load it's about 150 KB/day. I have been
previously pointed me to a memory leak in add_name in
support/export/client.c. Thanks! they were seeing a 6 MB/ day leak
before that fix.
=20
I've had trouble reproducing the same leak here, but in looking through
the code I believe I have come across another possible memory leak in
the support/export/client.c file. This time in the client_compose()
routine. It may be the source of the current 150 KB/day leak my customer
is seeing.
=20
I've attached an anlysis from code inspection, but it boils down to the
fact that the 'he' variable of client_compose() needs to be xfree'd
before client_compose() returns. The 'he' variable is assigned a
xmalloc'ed value via either get_hostent() or get_reliable_hostbyaddr().
Once the client_compose() routine returns the pointer will be lost
forever. The code is identical in nfs-utils-1.1.0 so I believe the
memory leak exists there as well.
=20
I'll keep trying to verify that indeed there is a memory leak here, but
from code inspection it certainly seems like it.
=20
Let me know if you agree that client_compose() has a memory leak.
=20
Thanks
=20
Chris Kottaridis
Senior Engineer
Wind River Systems
719-522-9786
=20

------_=_NextPart_002_01C7D939.C81F5E91
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<META content=3D"MSHTML 6.00.2900.3132" name=3DGENERATOR></HEAD>
<BODY>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D585484620-07082007>I've =
got a customer=20
experiencing a small memory leak in rpc.mountd using nfs-utils-1.0.7. =
For their=20
load it's about 150 KB/day. I have been previously pointed me to a =
memory leak=20
in add_name in support/export/client.c. Thanks! they were seeing&nbsp;a =
6 MB/=20
day leak before that fix.</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN=20
class=3D585484620-07082007></SPAN></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D585484620-07082007>I've =
had trouble=20
reproducing the same leak here, but in looking through the code I =
believe I have=20
come across another possible memory leak in the support/export/client.c =
file.=20
This time in the client_compose() routine. It may be the source of the =
current=20
150 KB/day leak my customer is seeing.</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN=20
class=3D585484620-07082007></SPAN></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D585484620-07082007>I've =
attached an=20
anlysis from code inspection, but it boils down to the fact that the =
'he'=20
variable of client_compose() needs to be xfree'd before client_compose() =

returns. The 'he' variable is assigned a xmalloc'ed value via either=20
get_hostent() or get_reliable_hostbyaddr(). Once the client_compose() =
routine=20
returns the pointer will be lost forever. The code is identical in=20
nfs-utils-1.1.0 so I believe the</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D585484620-07082007>memory =
leak exists=20
there as well.</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN=20
class=3D585484620-07082007></SPAN></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D585484620-07082007>I'll =
keep trying to=20
verify that indeed there is a memory leak here, but from code inspection =
it=20
certainly seems like it.</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN=20
class=3D585484620-07082007></SPAN></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D585484620-07082007>Let me =
know if you=20
agree that client_compose() has a memory leak.</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN=20
class=3D585484620-07082007></SPAN></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2><SPAN=20
class=3D585484620-07082007>Thanks</SPAN></FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV align=3Dleft><FONT face=3DArial size=3D2>Chris =
Kottaridis</FONT></DIV>
<DIV align=3Dleft><FONT face=3DArial =
size=3D2>Senior&nbsp;Engineer</FONT></DIV>
<DIV align=3Dleft><FONT face=3DArial size=3D2>Wind River =
Systems</FONT></DIV>
<DIV align=3Dleft><FONT face=3DArial size=3D2>719-522-9786</FONT></DIV>
<DIV align=3Dleft><FONT face=3DArial size=3D2><SPAN =
class=3D971590420-14032006><FONT=20
face=3DArial size=3D2></FONT></SPAN></FONT></DIV>
<DIV>&nbsp;</DIV></BODY></HTML>

------_=_NextPart_002_01C7D939.C81F5E91--

------_=_NextPart_001_01C7D939.C81F5E91
Content-Type: application/octet-stream;
	name="rpcmountd_Notes"
Content-Transfer-Encoding: base64
Content-Description: rpcmountd_Notes
Content-Disposition: attachment;
	filename="rpcmountd_Notes"

VGhlIHByb2JsZW0gaXMgYSB2ZXJ5IGdyYWR1YWwgbWVtb3J5IGxlYWsgaW4gcnBjLm1vdW50ZCBv
dmVyIHRpbWUuIEN1c3RvbWVyCmlzIHNlZWluZyBhYm91dCAxNTBLIHBlciBkYXkgbGVhay4gV2Ug
YWxyZWFkeSBmaXhlZCBhIDYgTUIgcGVyIGRheSBsZWFrCmJ5IHBhdGNoaW5nIHVwIGFkZF9uYW1l
IGZ1bmN0aW9uIGluIG5mcy11dGlscy0xLjAuNy9zdXBwb3J0L2V4cG9ydC9jbGllbnQuYy4KVGhl
IHN1c3BlY3RlZCBjbGllbnRfY29tcG9zZSgpIHJvdXRpbmUgaXMgYWxzbyBpbgpuZnMtdXRpbHMt
MS4wLjcvc3VwcG9ydC9leHBvcnQvY2xpZW50LmMuCgpJbiB0YWtpbmcgYSBsb29rIGF0IHRoZSBz
b3VyY2UgY29kZSBJIGNhbWUgYWxvbmcgdGhlIGNsaWVudF9jb21wb3NlKCkgcm91dGluZToKPT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09Ci8qCiAq
IEZpbmQgY2xpZW50IG5hbWUgZ2l2ZW4gYW4gSVAgYWRkcmVzcwogKiBUaGlzIGlzIGZvdW5kIGJ5
IGdhdGhlcmluZyBhbGwga25vd24gbmFtZXMgdGhhdCBtYXRjaCB0aGF0IElQIGFkZHJlc3MsCiAq
IHNvcnRpbmcgdGhlbSBhbmQgam9pbmluZyB0aGVtIHdpdGggJysnCiAqCiAqLwpzdGF0aWMgY2hh
ciAqYWRkX25hbWUoY2hhciAqb2xkLCBjaGFyICphZGQpOwoKY2hhciAqCmNsaWVudF9jb21wb3Nl
KHN0cnVjdCBpbl9hZGRyIGFkZHIpCnsKICAgICAgICBzdHJ1Y3QgaG9zdGVudCAqaGUgPSBOVUxM
OwogICAgICAgIGNoYXIgKm5hbWUgPSBOVUxMOwogICAgICAgIGludCBpOwoKICAgICAgICBpZiAo
Y2xpZW50bGlzdFtNQ0xfV0lMRENBUkRdIHx8IGNsaWVudGxpc3RbTUNMX05FVEdST1VQXSkKICAg
ICAgICAgICAgICAgIGhlID0gZ2V0X3JlbGlhYmxlX2hvc3RieWFkZHIoKGNvbnN0IGNoYXIqKSZh
ZGRyLCBzaXplb2YoYWRkciksIEFGX0lORVQpOwogICAgICAgIGlmIChoZSA9PSBOVUxMKQogICAg
ICAgICAgICAgICAgaGUgPSBnZXRfaG9zdGVudCgoY29uc3QgY2hhciopJmFkZHIsIHNpemVvZihh
ZGRyKSwgQUZfSU5FVCk7CgogICAgICAgIGZvciAoaSA9IDAgOyBpIDwgTUNMX01BWFRZUEVTOyBp
KyspIHsKICAgICAgICAgICAgICAgIG5mc19jbGllbnQgICAgICAqY2xwOwogICAgICAgICAgICAg
ICAgZm9yIChjbHAgPSBjbGllbnRsaXN0W2ldOyBjbHAgOyBjbHAgPSBjbHAtPm1fbmV4dCkgewog
ICAgICAgICAgICAgICAgICAgICAgICBpZiAoIWNsaWVudF9jaGVjayhjbHAsIGhlKSkKICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICBjb250aW51ZTsKICAgICAgICAgICAgICAgICAgICAg
ICAgbmFtZSA9IGFkZF9uYW1lKG5hbWUsIGNscC0+bV9ob3N0bmFtZSk7CiAgICAgICAgICAgICAg
ICB9CiAgICAgICAgfQogICAgICAgIHJldHVybiBuYW1lOwp9Cj09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0KCk5vdGUgdGhhdCB0aGUgJ2hlJyB2
YXJpYWJsZSBnZXRzIGRlZmluZWQgZnJvbSBlaXRoZXIgdGhlCmdldF9yZWxpYWJsZV9ob3N0Ynlh
ZGRyKCkgb3IgdGhlIGdldF9ob3N0ZW50KCkgcm91dGluZS4gQm90aCBvZiB0aGVzZSByb3V0aW5l
cwpwZXJmb3JtIGEgeG1hbGxvYyB0byBjcmVhdGUgaXQncyByZXR1cm4gdmFsdWUgdGhhdCBnZXRz
IHB1dCBpbnRvICdoZScuCgpJbiB0aGUgY2FzZSBvZiBnZXRfaG9zdGVudCgpIHhtYWxsb2MgaXMg
ZGlyZWN0bHkgY2FsbGVkIHRvIGFzc2lnbiBpdCdzIGxvY2FsCmNwIHZhcmlhYmxlLiBJdCdzIHRo
aXMgJ2NwJyB2YXJpYWJsZSBnZXRfaG9zdGVudCgpIHVsdG1hdGVseSByZXR1cm5zIHRvCmFuZCBj
bGluZXRfY29tcG9zZSBhc3NpZ25zIHRvIGl0J3MgaGUgdmFyaWFibGUuCgo9PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09CnN0cnVjdCBob3N0ZW50
ICoKZ2V0X2hvc3RlbnQgKGNvbnN0IGNoYXIgKmFkZHIsIGludCBsZW4sIGludCB0eXBlKQp7CiAg
c3RydWN0IGhvc3RlbnQgKmNwOwogIGludCBsZW5fZW50OwogIGNvbnN0IGNoYXIgKm5hbWU7CiAg
aW50IGxlbl9uYW1lOwogIGludCBudW1fYWxpYXNlcyA9IDE7CiAgaW50IGxlbl9hbGlhc2VzID0g
c2l6ZW9mIChjaGFyICopOwogIGludCBudW1fYWRkcl9saXN0ID0gMTsKICBpbnQgbGVuX2FkZHJf
bGlzdCA9IHNpemVvZiAoY2hhciAqKTsKICBpbnQgcG9zOwogIHN0cnVjdCBpbl9hZGRyICppcHY0
OwoKICBzd2l0Y2ggKHR5cGUpCiAgICB7CiAgICBjYXNlIEFGX0lORVQ6CiAgICAgIGlwdjQgPSAo
c3RydWN0IGluX2FkZHIgKikgYWRkcjsKICAgICAgbmFtZSA9IGluZXRfbnRvYSAoKmlwdjQpOwog
ICAgICBicmVhazsKCiAgICBkZWZhdWx0OgogICAgICByZXR1cm4gTlVMTDsKICAgIH0KCiAgbGVu
X2VudCA9IGFsaWduIChzaXplb2YgKCpjcCksIEFMSUdOTUVOVCk7CiAgbGVuX25hbWUgPSBhbGln
biAoc3RybGVuIChuYW1lKSArIDEsIEFMSUdOTUVOVCk7CgogIG51bV9hZGRyX2xpc3QrKzsKICBs
ZW5fYWRkcl9saXN0ICs9IGFsaWduIChsZW4sIEFMSUdOTUVOVCkgKyBzaXplb2YgKGNoYXIgKik7
CgogIGNwID0gKHN0cnVjdCBob3N0ZW50ICopIHhtYWxsb2MgKGxlbl9lbnQgKyBsZW5fbmFtZSAr
IGxlbl9hbGlhc2VzCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgKyBsZW5fYWRk
cl9saXN0KTsKCiAgY3AtPmhfYWRkcnR5cGUgPSB0eXBlOwogIGNwLT5oX2xlbmd0aCA9IGxlbjsK
ICBwb3MgPSBsZW5fZW50OwogIGNwLT5oX25hbWUgPSAoY2hhciAqKSAmKCgoY2hhciAqKSBjcCkg
W3Bvc10pOwogIHN0cmNweSAoY3AtPmhfbmFtZSwgbmFtZSk7CgogIHBvcyArPSBsZW5fbmFtZTsK
ICBjcC0+aF9hbGlhc2VzID0gKGNoYXIgKiopICYoKChjaGFyICopIGNwKSBbcG9zXSk7CiAgcG9z
ICs9IG51bV9hbGlhc2VzICogc2l6ZW9mIChjaGFyICopOwogIGNwLT5oX2FsaWFzZXMgWzBdID0g
TlVMTDsKCiAgcG9zID0gbGVuX2VudCArIGxlbl9uYW1lICsgbGVuX2FsaWFzZXM7CiAgY3AtPmhf
YWRkcl9saXN0ID0gKGNoYXIgKiopICYoKChjaGFyICopIGNwKSBbcG9zXSk7CiAgcG9zICs9IG51
bV9hZGRyX2xpc3QgKiBzaXplb2YgKGNoYXIgKik7CiAgY3AtPmhfYWRkcl9saXN0IFswXSA9IChj
aGFyICopICYoKChjaGFyICopIGNwKSBbcG9zXSk7CiAgbWVtY3B5IChjcC0+aF9hZGRyX2xpc3Qg
WzBdLCBhZGRyLCBjcC0+aF9sZW5ndGgpOwogIHBvcyArPSBhbGlnbiAoY3AtPmhfbGVuZ3RoLCBB
TElHTk1FTlQpOwogIGNwLT5oX2FkZHJfbGlzdCBbMV0gPSBOVUxMOwoKICByZXR1cm4gY3A7Cn0K
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0K
CkluIHRoZSBjYXNlIG9mIGdldF9yZWxpYWJsZV9ob3N0YnlhZGRyKCkgIHlvdSBjYW4gc2VlIGJl
bG93IHRoYXQgaXQncwpyZXR1cm5lZCB2YWx1ZSBvZiAnaHAnIGdldHMgZGVmaW5lZCBieSBhIGNh
bGwgdG8gaG9zdGVudF9kdXAoKS4KCj09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09Ci8qIE1hcCBJUCB0byBob3N0bmFtZSwgYW5kIHRoZW4gbWFw
IGJhY2sgdG8gYWRkciB0byBtYWtlIHN1cmUgaXQgaXMgYQogKiByZWxpYWJsZSBob3N0bmFtZQog
Ki8Kc3RydWN0IGhvc3RlbnQgKgpnZXRfcmVsaWFibGVfaG9zdGJ5YWRkcihjb25zdCBjaGFyICph
ZGRyLCBpbnQgbGVuLCBpbnQgdHlwZSkKewogICAgICAgIHN0cnVjdCBob3N0ZW50ICpocCA9IE5V
TEw7CgogICAgICAgIHN0cnVjdCBob3N0ZW50ICpyZXZlcnNlOwogICAgICAgIHN0cnVjdCBob3N0
ZW50ICpmb3J3YXJkOwogICAgICAgIGNoYXIgKipzcDsKCiAgICAgICAgcmV2ZXJzZSA9IGdldGhv
c3RieWFkZHIgKGFkZHIsIGxlbiwgdHlwZSk7CiAgICAgICAgaWYgKCFyZXZlcnNlKQogICAgICAg
ICAgICAgICAgcmV0dXJuIE5VTEw7CgogICAgICAgIC8qIG11c3QgbWFrZSBzdXJlIHRoZSBob3N0
ZW50IGlzIGF1dGhvcmF0aXZlLiAqLwoKICAgICAgICByZXZlcnNlID0gaG9zdGVudF9kdXAgKHJl
dmVyc2UpOwogICAgICAgIGZvcndhcmQgPSBnZXRob3N0YnluYW1lIChyZXZlcnNlLT5oX25hbWUp
OwoKICAgICAgICBpZiAoZm9yd2FyZCkgewogICAgICAgICAgICAgICAgLyogbm93IG1ha2Ugc3Vy
ZSB0aGUgImFkZHIiIGlzIGluIHRoZSBsaXN0ICovCiAgICAgICAgICAgICAgICBmb3IgKHNwID0g
Zm9yd2FyZC0+aF9hZGRyX2xpc3QgOyAqc3AgOyBzcCsrKSB7CiAgICAgICAgICAgICAgICAgICAg
ICAgIGlmIChtZW1jbXAgKCpzcCwgYWRkciwgZm9yd2FyZC0+aF9sZW5ndGgpID09IDApCiAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgYnJlYWs7CiAgICAgICAgICAgICAgICB9CgogICAg
ICAgICAgICAgICAgaWYgKCpzcCkgewogICAgICAgICAgICAgICAgICAgICAgICAvKiBpdCdzIHZh
bGlkICovCiAgICAgICAgICAgICAgICAgICAgICAgIGhwID0gaG9zdGVudF9kdXAgKGZvcndhcmQp
OwogICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgZWxzZSB7CiAgICAgICAgICAgICAg
ICAgICAgICAgIC8qIGl0IHdhcyBhIEZBS0UgKi8KICAgICAgICAgICAgICAgICAgICAgICAgeGxv
ZyAoTF9XQVJOSU5HLCAiRmFrZSBob3N0bmFtZSAlcyBmb3IgJXMgLSBmb3J3YXJkIGxvb2t1cCBk
b2Vzbid0IG1hdGNoIHJldmVyc2UiLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICByZXZl
cnNlLT5oX25hbWUsIGluZXRfbnRvYSgqKHN0cnVjdCBpbl9hZGRyKilhZGRyKSk7CiAgICAgICAg
ICAgICAgICB9CiAgICAgICAgfQogICAgICAgIGVsc2UgewogICAgICAgICAgICAgICAgLyogbmV2
ZXIgaGVhcmQgb2YgaXQuIG1pc2NvbmZpZ3VyZWQgRE5TPyAqLwogICAgICAgICAgICAgICAgeGxv
ZyAoTF9XQVJOSU5HLCAiRmFrZSBob3N0bmFtZSAlcyBmb3IgJXMgLSBmb3J3YXJkIGxvb2t1cCBk
b2Vzbid0IGV4aXN0IiwKICAgICAgICAgICAgICAgICAgICAgIHJldmVyc2UtPmhfbmFtZSwgaW5l
dF9udG9hKCooc3RydWN0IGluX2FkZHIqKWFkZHIpKTsKICAgICAgICB9CgogICAgICAgIGZyZWUg
KHJldmVyc2UpOwogICAgICAgIHJldHVybiBocDsKfQo9PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09CgpUaGUgaG9zdGVudF9kdXAoKSByb3V0aW5l
IGdldHMgaXQncyByZXR1cm5lZCB2YWx1ZSBmcm9tIGEgeG1hbGxvYygpOgoKPT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQpzdHJ1Y3QgaG9zdGVu
dCAqCmhvc3RlbnRfZHVwIChzdHJ1Y3QgaG9zdGVudCAqaHApCnsKICBpbnQgbGVuX2VudCA9IGFs
aWduIChzaXplb2YgKCpocCksIEFMSUdOTUVOVCk7CiAgaW50IGxlbl9uYW1lID0gYWxpZ24gKHN0
cmxlbiAoaHAtPmhfbmFtZSkgKyAxLCBBTElHTk1FTlQpOwogIGludCBudW1fYWxpYXNlcyA9IDE7
CiAgaW50IGxlbl9hbGlhc2VzID0gc2l6ZW9mIChjaGFyICopOwogIGludCBudW1fYWRkcl9saXN0
ID0gMTsKICBpbnQgbGVuX2FkZHJfbGlzdCA9IHNpemVvZiAoY2hhciAqKTsKICBpbnQgcG9zLCBp
OwogIGNoYXIgKipzcDsKICBzdHJ1Y3QgaG9zdGVudCAqY3A7CgogIGZvciAoc3AgPSBocC0+aF9h
bGlhc2VzOyBzcCAmJiAqc3A7IHNwKyspCiAgICB7CiAgICAgIG51bV9hbGlhc2VzKys7CiAgICAg
IGxlbl9hbGlhc2VzICs9IGFsaWduIChzdHJsZW4gKCpzcCkgKyAxLCBBTElHTk1FTlQpCiAgICAg
ICAgICAgICAgICAgICAgICsgc2l6ZW9mIChjaGFyICopOwogICAgfQoKICBmb3IgKHNwID0gaHAt
PmhfYWRkcl9saXN0OyAqc3A7IHNwKyspCiAgICB7CiAgICAgIG51bV9hZGRyX2xpc3QrKzsKICAg
ICAgbGVuX2FkZHJfbGlzdCArPSBhbGlnbiAoaHAtPmhfbGVuZ3RoLCBBTElHTk1FTlQpCiAgICAg
ICAgICAgICAgICAgICAgICAgKyBzaXplb2YgKGNoYXIgKik7CiAgICB9CgogIGNwID0gKHN0cnVj
dCBob3N0ZW50ICopIHhtYWxsb2MgKGxlbl9lbnQgKyBsZW5fbmFtZSArIGxlbl9hbGlhc2VzCiAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgKyBsZW5fYWRkcl9saXN0KTsKCiAgKmNw
ID0gKmhwOwogIHBvcyA9IGxlbl9lbnQ7CiAgY3AtPmhfbmFtZSA9IChjaGFyICopICYoKChjaGFy
ICopIGNwKSBbcG9zXSk7CiAgc3RyY3B5IChjcC0+aF9uYW1lLCBocC0+aF9uYW1lKTsKCiAgcG9z
ICs9IGxlbl9uYW1lOwogIGNwLT5oX2FsaWFzZXMgPSAoY2hhciAqKikgJigoKGNoYXIgKikgY3Ap
IFtwb3NdKTsKICBwb3MgKz0gbnVtX2FsaWFzZXMgKiBzaXplb2YgKGNoYXIgKik7CiAgZm9yIChz
cCA9IGhwLT5oX2FsaWFzZXMsIGkgPSAwOyBpIDwgbnVtX2FsaWFzZXM7IGkrKywgc3ArKykKICAg
IGlmIChzcCAmJiAqc3ApCiAgICAgIHsKICAgICAgICBjcC0+aF9hbGlhc2VzIFtpXSA9IChjaGFy
ICopICYoKChjaGFyICopIGNwKSBbcG9zXSk7CiAgICAgICAgc3RyY3B5IChjcC0+aF9hbGlhc2Vz
IFtpXSwgKnNwKTsKICAgICAgICBwb3MgKz0gYWxpZ24gKHN0cmxlbiAoKnNwKSArIDEsIEFMSUdO
TUVOVCk7CiAgICAgIH0KICAgIGVsc2UKICAgICAgY3AtPmhfYWxpYXNlcyBbaV0gPSBOVUxMOwoK
ICBwb3MgPSBsZW5fZW50ICsgbGVuX25hbWUgKyBsZW5fYWxpYXNlczsKICBjcC0+aF9hZGRyX2xp
c3QgPSAoY2hhciAqKikgJigoKGNoYXIgKikgY3ApIFtwb3NdKTsKICBwb3MgKz0gbnVtX2FkZHJf
bGlzdCAqIHNpemVvZiAoY2hhciAqKTsKICBmb3IgKHNwID0gaHAtPmhfYWRkcl9saXN0LCBpID0g
MDsgaSA8IG51bV9hZGRyX2xpc3Q7IGkrKywgc3ArKykKICAgIGlmICgqc3ApCiAgICAgIHsKICAg
ICAgICBjcC0+aF9hZGRyX2xpc3QgW2ldID0gKGNoYXIgKikgJigoKGNoYXIgKikgY3ApIFtwb3Nd
KTsKICAgICAgICBtZW1jcHkgKGNwLT5oX2FkZHJfbGlzdCBbaV0sICpzcCwgaHAtPmhfbGVuZ3Ro
KTsKICAgICAgICBwb3MgKz0gYWxpZ24gKGhwLT5oX2xlbmd0aCwgQUxJR05NRU5UKTsKICAgICAg
fQogICAgZWxzZQogICAgICBjcC0+aF9hZGRyX2xpc3QgW2ldID0gKnNwOwoKICByZXR1cm4gY3A7
Cn0KPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT0KClNvLCBubyBtYXR0ZXIgaG93IHRoZSAnaGUnIHZhcmlhYmxlIG9mIGNsaWVudF9jb21wb3Nl
KCkgZ2V0cyBhc3NpZ25lZCBpdCBpcwphbiB4bWFsbG9jJ2VkIHZhbHVlIGFuZCBuZWVkcyB0byBi
ZSB4ZnJlZSdkIGF0IHNvbWUgcG9pbnQuIFRoZSBvbmx5IHBsYWNlCndoZXJlIHRoZSAnaGUnIHZh
cmlhYmxlIGdldHMgdXNlZCBpbiB0aGUgY2xpZW50X2NvbXBvc2UoKSByb3V0aW5lIGlzIHdoZW4g
aXQKZ2V0cyBwYXNzZWQgdG8gY2xpZW50X2NoZWNrKCkuIFRoZSBjbGllbnRfY2hlY2soKSByb3V0
aW5lIG9ubHkgdXNlcwp2YXJpb3VzIGZpZWxkcyBmcm9tICdoZScgdG8gY29tcGFyZSBhZ2FpbnN0
IG90aGVyIHZhbHVpZXMuIEl0IGRvZXMgbm90CnN0b3JlIHRoZSAnaGUnIHZhbHVlIGludG8gYW55
IHN0cnVjdHVyZSB0aGF0IGEgbGF0ZXIgeGZyZWUoKSBjb3VsZCBiZSBkb25lCm9uIGl0LgoKVGhl
IHVwc2hvdCBvZiBhbGwgb2YgdGhpcyBpcyB0aGF0IHRoZSAnaGUnIHZhcmlhYmxlIG9mIGNsaWVu
dF9jb21wb3NlKCkgaXMKYSB4bWFsbG9jJ2VkIHZhbHVlIHRoYXQgbmVlZHMgdG8gYmUgeGZyZWUn
ZCBiZWZvcmUgdGhlIGNsaWVudF9jb21wb3NlKCkKcm91dGluZSBleGl0cy4gQXMgdGhlcmUgaXMg
bm8gd2F5IGZvciBhbnkgcm91dGluZSB0aGF0IG1heSBjYWxsCmNsaWVudF9jb21wb3NlKCkgdG8g
ZnJlZSB0aGUgdmFsdWUgaW4gdGhlICdoZScgcG9pbnRlci4gU28sIGV2ZXJ5IHRpbWUKY2xpZW50
X2NvbXBvc2UoKSBnZXRzIGNhbGxlZCB0aGVyZSB3aWxsIGJlIGEgbWVtb3J5IGxlYWsgb2YgdGhl
IHNpemUgb2YKdGhlICdoZScgaG9zdGVudCBzdHJ1Y3R1cmUuCgpUaGUgZml4IHdvdWxkIGJlIHRv
IGhhdmUgYSB4ZnJlZSBvZiAnaGUnIHZhcmlhYmxlIGF0IHRoZSBleGl0IHBvaW50IG9mIApjbGll
bnRfY29tcG9zZSgpOgoKY2hhciAqCmNsaWVudF9jb21wb3NlKHN0cnVjdCBpbl9hZGRyIGFkZHIp
CnsKICAgICAgICBzdHJ1Y3QgaG9zdGVudCAqaGUgPSBOVUxMOwogICAgICAgIGNoYXIgKm5hbWUg
PSBOVUxMOwogICAgICAgIGludCBpOwoKICAgICAgICBpZiAoY2xpZW50bGlzdFtNQ0xfV0lMRENB
UkRdIHx8IGNsaWVudGxpc3RbTUNMX05FVEdST1VQXSkKICAgICAgICAgICAgICAgIGhlID0gZ2V0
X3JlbGlhYmxlX2hvc3RieWFkZHIoKGNvbnN0IGNoYXIqKSZhZGRyLCBzaXplb2YoYWRkciksIEFG
X0lORVQpOwogICAgICAgIGlmIChoZSA9PSBOVUxMKQogICAgICAgICAgICAgICAgaGUgPSBnZXRf
aG9zdGVudCgoY29uc3QgY2hhciopJmFkZHIsIHNpemVvZihhZGRyKSwgQUZfSU5FVCk7CgogICAg
ICAgIGZvciAoaSA9IDAgOyBpIDwgTUNMX01BWFRZUEVTOyBpKyspIHsKICAgICAgICAgICAgICAg
IG5mc19jbGllbnQgICAgICAqY2xwOwogICAgICAgICAgICAgICAgZm9yIChjbHAgPSBjbGllbnRs
aXN0W2ldOyBjbHAgOyBjbHAgPSBjbHAtPm1fbmV4dCkgewogICAgICAgICAgICAgICAgICAgICAg
ICBpZiAoIWNsaWVudF9jaGVjayhjbHAsIGhlKSkKICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICBjb250aW51ZTsKICAgICAgICAgICAgICAgICAgICAgICAgbmFtZSA9IGFkZF9uYW1lKG5h
bWUsIGNscC0+bV9ob3N0bmFtZSk7CiAgICAgICAgICAgICAgICB9CiAgICAgICAgfQoJaWYgKGhl
ICE9IE5VTEwpCgkJeGZyZWUgKGhlKTsKCiAgICAgICAgcmV0dXJuIG5hbWU7Cn0KCg==

------_=_NextPart_001_01C7D939.C81F5E91
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
------_=_NextPart_001_01C7D939.C81F5E91
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

------_=_NextPart_001_01C7D939.C81F5E91--
