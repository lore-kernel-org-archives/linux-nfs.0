From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: NSM lock recovery fails too often
Date: Mon, 8 Mar 2004 20:30:45 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435DD1C@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/related;
	type="multipart/alternative";
	boundary="----_=_NextPart_001_01C4058F.49E84022"
Cc: "Olaf Kirch" <okir@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0Z1s-0002M1-4I
	for nfs@lists.sourceforge.net; Mon, 08 Mar 2004 20:39:44 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B0YtH-0006Q0-Pk
	for nfs@lists.sourceforge.net; Mon, 08 Mar 2004 20:30:51 -0800
To: <nfs@lists.sourceforge.net>
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

This is a multi-part message in MIME format.

------_=_NextPart_001_01C4058F.49E84022
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_002_01C4058F.49E84022"


------_=_NextPart_002_01C4058F.49E84022
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

the way things work today, NLM is in-kernel on most Linux systems,
and it uses an in-kernel equivalent of gethostname(3) to determine
the client's hostname for use when making NLM requests.  NSM,
though, is still in user-land, and uses gethostbyname(3) to
determine the client's hostname.  very often this results in
NSM using a different client hostname string than NLM, thus
causing lock recovery to fail.

NLM and NSM must use the same hostname string.

this is a real bug that many of NetApp's customers hit all
the time.  the problem is exposed only after a client crashes
and recovers, not when it shuts down normally and reboots.

i attach two patches that accomplish a solution in different
ways.

first is a patch by Olaf Kirch against nfs-utils-1.0.1 that
adds an option to disable the extra gethostbyname(3) call in
rpc.statd.  second is a reductionist approach -- just excise
that call entirely.  the first patch allows backwards compat-
ibility with the user-level lockd, which nfs-utils still
contains.  the second makes rpc.statd match the behavior of
the in-kernel lockd unconditionally.

perhaps the best solution is to use an option as Olaf's patch
does, but to make the default behavior match the in-kernel
lockd's behavior, not the user-level lockd's behavior.  or,
maybe we use the second patch and simply remove the user
level lockd from nfs-utils.

comments?

------_=_NextPart_002_01C4058F.49E84022
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.0.6249.1">
<TITLE>NSM lock recovery fails too often</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/plain format -->

<P><FONT SIZE=3D2>the way things work today, NLM is in-kernel on most =
Linux systems,</FONT>

<BR><FONT SIZE=3D2>and it uses an in-kernel equivalent of gethostname(3) =
to determine</FONT>

<BR><FONT SIZE=3D2>the client's hostname for use when making NLM =
requests.&nbsp; NSM,</FONT>

<BR><FONT SIZE=3D2>though, is still in user-land, and uses =
gethostbyname(3) to</FONT>

<BR><FONT SIZE=3D2>determine the client's hostname.&nbsp; very often =
this results in</FONT>

<BR><FONT SIZE=3D2>NSM using a different client hostname string than =
NLM, thus</FONT>

<BR><FONT SIZE=3D2>causing lock recovery to fail.</FONT>
</P>

<P><FONT SIZE=3D2>NLM and NSM must use the same hostname string.</FONT>
</P>

<P><FONT SIZE=3D2>this is a real bug that many of NetApp's customers hit =
all</FONT>

<BR><FONT SIZE=3D2>the time.&nbsp; the problem is exposed only after a =
client crashes</FONT>

<BR><FONT SIZE=3D2>and recovers, not when it shuts down normally and =
reboots.</FONT>
</P>

<P><FONT SIZE=3D2>i attach two patches that accomplish a solution in =
different</FONT>

<BR><FONT SIZE=3D2>ways.</FONT>
</P>

<P><FONT SIZE=3D2>first is a patch by Olaf Kirch against nfs-utils-1.0.1 =
that</FONT>

<BR><FONT SIZE=3D2>adds an option to disable the extra gethostbyname(3) =
call in</FONT>

<BR><FONT SIZE=3D2>rpc.statd.&nbsp; second is a reductionist approach -- =
just excise</FONT>

<BR><FONT SIZE=3D2>that call entirely.&nbsp; the first patch allows =
backwards compat-</FONT>

<BR><FONT SIZE=3D2>ibility with the user-level lockd, which nfs-utils =
still</FONT>

<BR><FONT SIZE=3D2>contains.&nbsp; the second makes rpc.statd match the =
behavior of</FONT>

<BR><FONT SIZE=3D2>the in-kernel lockd unconditionally.</FONT>
</P>

<P><FONT SIZE=3D2>perhaps the best solution is to use an option as =
Olaf's patch</FONT>

<BR><FONT SIZE=3D2>does, but to make the default behavior match the =
in-kernel</FONT>

<BR><FONT SIZE=3D2>lockd's behavior, not the user-level lockd's =
behavior.&nbsp; or,</FONT>

<BR><FONT SIZE=3D2>maybe we use the second patch and simply remove the =
user</FONT>

<BR><FONT SIZE=3D2>level lockd from nfs-utils.</FONT>
</P>

<P><FONT SIZE=3D2>comments?</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_002_01C4058F.49E84022--

------_=_NextPart_001_01C4058F.49E84022
Content-Type: TEXT/PLAIN;
	name="nfs-utils-1.0.1-local-hostname.patch"
Content-Transfer-Encoding: base64
Content-ID: <Pine.BSO.4.33.0403082304580.1296@citi.umich.edu>
Content-Description: nfs-utils-1.0.1-local-hostname.patch
Content-Disposition: attachment;
	filename="nfs-utils-1.0.1-local-hostname.patch"
Content-Location: 1_MULTIPART%3F2_nfs-utils-1.0.1-local-hostname.patch

ZGlmZiAtdXIgbmZzLXV0aWxzLTEuMC4xL3V0aWxzL3N0YXRkL3N0YXRkLmMgbmZzLXV0aWxzLTEu
MC4xLmxvY2FsLW5hbWUvdXRpbHMvc3RhdGQvc3RhdGQuYw0KLS0tIG5mcy11dGlscy0xLjAuMS91
dGlscy9zdGF0ZC9zdGF0ZC5jCTIwMDQtMDItMTMgMTY6Mzc6MzUuMDAwMDAwMDAwICswMTAwDQor
KysgbmZzLXV0aWxzLTEuMC4xLmxvY2FsLW5hbWUvdXRpbHMvc3RhdGQvc3RhdGQuYwkyMDA0LTAy
LTEzIDE2OjM3OjA2LjAwMDAwMDAwMCArMDEwMA0KQEAgLTI3LDYgKzI3LDcgQEANCiANCiBzaG9y
dCBpbnQgcmVzdGFydCA9IDA7DQogaW50CXJ1bl9tb2RlID0gMDsJCS8qIGZvcmVncm91bmQgbG9n
Z2luZyBtb2RlICovDQoraW50CXVzZV9sb2NhbF9ob3N0bmFtZSA9IDA7DQogDQogLyogTEggLSBJ
IGhhZCB0aGVzZSBsb2NhbCB0byBtYWluLCBidXQgaXQgc2VlbWVkIHNpbGx5IHRvIGhhdmUgDQog
ICogdHdvIGNvcGllcyBvZiBlYWNoIC0gb25lIGluIG1haW4oKSwgb25lIHN0YXRpYyBpbiBsb2cu
Yy4uLiANCkBAIC00Myw2ICs0NCw3IEBADQogCXsgIm91dGdvaW5nLXBvcnQiLCAxLCAwLCAnbycg
fSwNCiAJeyAicG9ydCIsIDEsIDAsICdwJyB9LA0KIAl7ICJuYW1lIiwgMSwgMCwgJ24nIH0sDQor
CXsgInVzZS1sb2NhbC1ob3N0bmFtZSIsIDEsIDAsICdsJyB9LA0KIAl7IE5VTEwsIDAsIDAsIDAg
fQ0KIH07DQogDQpAQCAtMTI0LDYgKzEyNiw4IEBADQogCWZwcmludGYoc3RkZXJyLCIgICAgICAt
aCwgLT8sIC0taGVscCAgICAgICBQcmludCB0aGlzIGhlbHAgc2NyZWVuLlxuIik7DQogCWZwcmlu
dGYoc3RkZXJyLCIgICAgICAtRiwgLS1mb3JlZ3JvdW5kICAgICBGb3JlZ3JvdW5kIChuby1kYWVt
b24gbW9kZSlcbiIpOw0KIAlmcHJpbnRmKHN0ZGVyciwiICAgICAgLWQsIC0tbm8tc3lzbG9nICAg
ICAgVmVyYm9zZSBsb2dnaW5nIHRvIHN0ZGVyci4gIEZvcmVncm91bmQgbW9kZSBvbmx5LlxuIik7
DQorCWZwcmludGYoc3RkZXJyLCIgICAgICAtbCwgLS11c2UtbG9jYWwtaG9zdG5hbWVcbiINCisJ
ICAgICAgICAgICAgICAgIiAgICAgICAgICAgICAgICAgICAgICAgICAgIERvbid0IGFkZCBhIGRv
bWFpbiB0byB0aGUgaG9zdG5hbWUgaW4gTk9USUZZIGNhbGxzXG4iKTsNCiAJZnByaW50ZihzdGRl
cnIsIiAgICAgIC1wLCAtLXBvcnQgICAgICAgICAgIFBvcnQgdG8gbGlzdGVuIG9uXG4iKTsNCiAJ
ZnByaW50ZihzdGRlcnIsIiAgICAgIC1vLCAtLW91dGdvaW5nLXBvcnQgIFBvcnQgZm9yIG91dGdv
aW5nIGNvbm5lY3Rpb25zXG4iKTsNCiAJZnByaW50ZihzdGRlcnIsIiAgICAgIC1WLCAtdiwgLS12
ZXJzaW9uICAgIERpc3BsYXkgdmVyc2lvbiBpbmZvcm1hdGlvbiBhbmQgZXhpdC5cbiIpOw0KQEAg
LTE2MSw3ICsxNjUsNyBAQA0KIAlNWV9OQU1FID0gTlVMTDsNCiANCiAJLyogUHJvY2VzcyBjb21t
YW5kIGxpbmUgc3dpdGNoZXMgKi8NCi0Jd2hpbGUgKChhcmcgPSBnZXRvcHRfbG9uZyhhcmdjLCBh
cmd2LCAiaD92VkZkbjpwOm86IiwgbG9uZ29wdHMsIE5VTEwpKSAhPSBFT0YpIHsNCisJd2hpbGUg
KChhcmcgPSBnZXRvcHRfbG9uZyhhcmdjLCBhcmd2LCAiaD92VkZkbG46cDpvOiIsIGxvbmdvcHRz
LCBOVUxMKSkgIT0gRU9GKSB7DQogCQlzd2l0Y2ggKGFyZykgew0KIAkJY2FzZSAnVic6CS8qIFZl
cnNpb24gKi8NCiAJCWNhc2UgJ3YnOg0KQEAgLTE5MSw2ICsxOTUsOSBAQA0KIAkJCQlleGl0KDEp
Ow0KIAkJCX0NCiAJCQlicmVhazsNCisJCWNhc2UgJ2wnOg0KKwkJCXVzZV9sb2NhbF9ob3N0bmFt
ZSA9IDE7DQorCQkJYnJlYWs7DQogCQljYXNlICduJzoJLyogU3BlY2lmeSBsb2NhbCBob3N0bmFt
ZSAqLw0KIAkJCU1ZX05BTUUgPSB4c3RyZHVwKG9wdGFyZyk7DQogCQkJYnJlYWs7DQpkaWZmIC11
ciBuZnMtdXRpbHMtMS4wLjEvdXRpbHMvc3RhdGQvc3RhdGQuaCBuZnMtdXRpbHMtMS4wLjEubG9j
YWwtbmFtZS91dGlscy9zdGF0ZC9zdGF0ZC5oDQotLS0gbmZzLXV0aWxzLTEuMC4xL3V0aWxzL3N0
YXRkL3N0YXRkLmgJMjAwMC0xMC0wNSAyMToxMTozOS4wMDAwMDAwMDAgKzAyMDANCisrKyBuZnMt
dXRpbHMtMS4wLjEubG9jYWwtbmFtZS91dGlscy9zdGF0ZC9zdGF0ZC5oCTIwMDQtMDItMTMgMTY6
MzM6NTMuMDAwMDAwMDAwICswMTAwDQpAQCAtNDgsNiArNDgsNyBAQA0KIHN0YXRfY2hnZQkJU01f
c3RhdF9jaGdlOw0KICNkZWZpbmUgTVlfTkFNRQkJU01fc3RhdF9jaGdlLm1vbl9uYW1lDQogI2Rl
ZmluZSBNWV9TVEFURQlTTV9zdGF0X2NoZ2Uuc3RhdGUNCitleHRlcm4gaW50CQl1c2VfbG9jYWxf
aG9zdG5hbWU7DQogDQogLyoNCiAgKiBTb21lIHRpbWVvdXQgdmFsdWVzLiAgKFRpbWVvdXQgdmFs
dWVzIGFyZSBpbiB3aG9sZSBzZWNvbmRzLikNCmRpZmYgLXVyIG5mcy11dGlscy0xLjAuMS91dGls
cy9zdGF0ZC9zdGF0ZS5jIG5mcy11dGlscy0xLjAuMS5sb2NhbC1uYW1lL3V0aWxzL3N0YXRkL3N0
YXRlLmMNCi0tLSBuZnMtdXRpbHMtMS4wLjEvdXRpbHMvc3RhdGQvc3RhdGUuYwkyMDA0LTAyLTEz
IDE2OjM3OjM1LjAwMDAwMDAwMCArMDEwMA0KKysrIG5mcy11dGlscy0xLjAuMS5sb2NhbC1uYW1l
L3V0aWxzL3N0YXRkL3N0YXRlLmMJMjAwNC0wMi0xMyAxNjozNToyOS4wMDAwMDAwMDAgKzAxMDAN
CkBAIC02NCw2ICs2NCwxMSBAQA0KICAgICBpZiAoZ2V0aG9zdG5hbWUgKGZ1bGxob3N0LCBTTV9N
QVhTVFJMRU4pID09IC0xKQ0KICAgICAgIGRpZSAoImdldGhvc3RuYW1lOiAlcyIsIHN0cmVycm9y
IChlcnJubykpOw0KIA0KKyAgICBpZiAodXNlX2xvY2FsX2hvc3RuYW1lKSB7DQorICAgICAgTVlf
TkFNRSA9IHhzdHJkdXAgKGZ1bGxob3N0KTsNCisgICAgICByZXR1cm47DQorICAgIH0NCisNCiAg
ICAgaWYgKChob3N0aW5mbyA9IGdldGhvc3RieW5hbWUgKGZ1bGxob3N0KSkgPT0gTlVMTCkNCiAg
ICAgICBsb2cgKExfRVJST1IsICJnZXRob3N0YnluYW1lIGVycm9yIGZvciAlcyIsIGZ1bGxob3N0
KTsNCiAgICAgZWxzZSB7DQo=

------_=_NextPart_001_01C4058F.49E84022
Content-Type: TEXT/PLAIN;
	name="nfs-utils-1.0.6-no-ghbn.patch"
Content-Transfer-Encoding: base64
Content-ID: <Pine.BSO.4.33.0403082304581.1296@citi.umich.edu>
Content-Description: nfs-utils-1.0.6-no-ghbn.patch
Content-Disposition: attachment;
	filename="nfs-utils-1.0.6-no-ghbn.patch"
Content-Location: 1_MULTIPART%3F3_nfs-utils-1.0.6-no-ghbn.patch

ZGlmZiAtTmF1cnAgbmZzLXV0aWxzLTEuMC42L3V0aWxzL3N0YXRkL3N0YXRlLmMgbmZzLXV0aWxz
LTEuMC42LWZpeC91dGlscy9zdGF0ZC9zdGF0ZS5jDQotLS0gbmZzLXV0aWxzLTEuMC42L3V0aWxz
L3N0YXRkL3N0YXRlLmMJMjAwMy0wOS0xMiAwMTo0MTo0MC4wMDAwMDAwMDAgLTA0MDANCisrKyBu
ZnMtdXRpbHMtMS4wLjYtZml4L3V0aWxzL3N0YXRkL3N0YXRlLmMJMjAwNC0wMy0wOCAyMjo1ODo0
MC4wMDAwMDAwMDAgLTA1MDANCkBAIC02MywxMyArNjMsNiBAQCBjaGFuZ2Vfc3RhdGUgKHZvaWQp
DQogICAgIGlmIChnZXRob3N0bmFtZSAoZnVsbGhvc3QsIFNNX01BWFNUUkxFTikgPT0gLTEpDQog
ICAgICAgZGllICgiZ2V0aG9zdG5hbWU6ICVzIiwgc3RyZXJyb3IgKGVycm5vKSk7DQogDQotICAg
IGlmICgoaG9zdGluZm8gPSBnZXRob3N0YnluYW1lIChmdWxsaG9zdCkpID09IE5VTEwpDQotICAg
ICAgbm90ZSAoTl9FUlJPUiwgImdldGhvc3RieW5hbWUgZXJyb3IgZm9yICVzIiwgZnVsbGhvc3Qp
Ow0KLSAgICBlbHNlIHsNCi0gICAgICBzdHJuY3B5IChmdWxsaG9zdCwgaG9zdGluZm8tPmhfbmFt
ZSwgc2l6ZW9mIChmdWxsaG9zdCkgLSAxKTsNCi0gICAgICBmdWxsaG9zdFtzaXplb2YgKGZ1bGxo
b3N0KSAtIDFdID0gJ1wwJzsNCi0gICAgfQ0KLQ0KICAgICBNWV9OQU1FID0geHN0cmR1cCAoZnVs
bGhvc3QpOw0KICAgfQ0KIH0NCg==

------_=_NextPart_001_01C4058F.49E84022--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
