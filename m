From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: Race condition in xprt_disconnect
Date: Mon, 05 Apr 2004 16:39:30 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1081197570.2641.133.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-wffVNpRm9tbctwe/vhCb"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BAasc-0006AV-UK
	for nfs@lists.sourceforge.net; Mon, 05 Apr 2004 13:39:38 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BAasc-0001ri-ES
	for nfs@lists.sourceforge.net; Mon, 05 Apr 2004 13:39:38 -0700
To: Olaf Kirch <okir@suse.de>
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


--=-wffVNpRm9tbctwe/vhCb
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

        it seems bad things can happen if two RPC processes call
        xprt_disconnect at the same time. I have two bug reports of ppc
        machines oopsing somewhere deep in some SELinux functions
        because inode->i_security is NULL. inode->i_security is
        allocated when the inode is created, and cleared when the inode
        is destroyed.

        The stack looks something like
        xprt_disconnect->sock_release->...->selinux_foofah

        The only way I can see this happening is if sock_release is
        called twice, and indeed we do not seem to protect against this.
        Please take a look at the attached patch. It should prevent
        these oopses, but I'm not entirely sure it's safe.

I initially thought that patch you sent out was correct, however the
more I think about it, the more I'm convinced it isn't sufficient.

The only way I see that we can have duplicate calls to sock_release() is
if we are scheduling xprt_socket_autoclose() or xprt_socket_connect()
more than once.
Normally xprt_lock_write() should protect us against this, and so AFAICS
any duplicates must imply that xprt_lock_write() is getting lost before
xprt_socket_connect() has had a chance to run. Presumably this is
occurring because xprt->snd_task is timing out and then being woken up
from xprt->pending.
Note that in that case we don't actually *want* to schedule a new
connect(), since the problem is not that the networking operation timed
out, but rather that keventd is being too slow...

The following patch should hopefully protect against this problem.

Cheers,
  Trond



--=-wffVNpRm9tbctwe/vhCb
Content-Disposition: attachment; filename=linux-2.6.5-34-sunrpc_disconnect.dif
Content-Transfer-Encoding: base64
Content-Type: text/plain; name=linux-2.6.5-34-sunrpc_disconnect.dif; charset=ISO-8859-1

IGluY2x1ZGUvbGludXgvc3VucnBjL3hwcnQuaCB8ICAgIDUgKystDQogbmV0L3N1bnJwYy94cHJ0
LmMgICAgICAgICAgIHwgICA1OCArKysrKysrKysrKysrKysrKystLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLQ0KIDIgZmlsZXMgY2hhbmdlZCwgMjcgaW5zZXJ0aW9ucygrKSwgMzYgZGVsZXRpb25z
KC0pDQoNCmRpZmYgLXUgLS1yZWN1cnNpdmUgLS1uZXctZmlsZSAtLXNob3ctYy1mdW5jdGlvbiBs
aW51eC0yLjYuNS0zMy1ncmFjZS9pbmNsdWRlL2xpbnV4L3N1bnJwYy94cHJ0LmggbGludXgtMi42
LjUtMzQtc3VucnBjX2Rpc2Nvbm5lY3QvaW5jbHVkZS9saW51eC9zdW5ycGMveHBydC5oDQotLS0g
bGludXgtMi42LjUtMzMtZ3JhY2UvaW5jbHVkZS9saW51eC9zdW5ycGMveHBydC5oCTIwMDQtMDQt
MDUgMTM6MjQ6NDguMDAwMDAwMDAwIC0wNDAwDQorKysgbGludXgtMi42LjUtMzQtc3VucnBjX2Rp
c2Nvbm5lY3QvaW5jbHVkZS9saW51eC9zdW5ycGMveHBydC5oCTIwMDQtMDQtMDUgMTQ6NDk6NDgu
MDAwMDAwMDAwIC0wNDAwDQpAQCAtMjE2LDggKzIxNiw5IEBAIHZvaWQJCQl4cHJ0X2Nvbm5lY3Qo
c3RydWN0IHJwY190YXNrICopOw0KIGludAkJCXhwcnRfY2xlYXJfYmFja2xvZyhzdHJ1Y3QgcnBj
X3hwcnQgKik7DQogdm9pZAkJCXhwcnRfc29ja19zZXRidWZzaXplKHN0cnVjdCBycGNfeHBydCAq
KTsNCiANCi0jZGVmaW5lIFhQUlRfQ09OTkVDVAkwDQotI2RlZmluZSBYUFJUX0xPQ0tFRAkxDQor
I2RlZmluZSBYUFJUX0xPQ0tFRAkwDQorI2RlZmluZSBYUFJUX0NPTk5FQ1QJMQ0KKyNkZWZpbmUg
WFBSVF9DT05ORUNUSU5HCTINCiANCiAjZGVmaW5lIHhwcnRfY29ubmVjdGVkKHhwKQkJKHRlc3Rf
Yml0KFhQUlRfQ09OTkVDVCwgJih4cCktPnNvY2tzdGF0ZSkpDQogI2RlZmluZSB4cHJ0X3NldF9j
b25uZWN0ZWQoeHApCQkoc2V0X2JpdChYUFJUX0NPTk5FQ1QsICYoeHApLT5zb2Nrc3RhdGUpKQ0K
ZGlmZiAtdSAtLXJlY3Vyc2l2ZSAtLW5ldy1maWxlIC0tc2hvdy1jLWZ1bmN0aW9uIGxpbnV4LTIu
Ni41LTMzLWdyYWNlL25ldC9zdW5ycGMveHBydC5jIGxpbnV4LTIuNi41LTM0LXN1bnJwY19kaXNj
b25uZWN0L25ldC9zdW5ycGMveHBydC5jDQotLS0gbGludXgtMi42LjUtMzMtZ3JhY2UvbmV0L3N1
bnJwYy94cHJ0LmMJMjAwNC0wNC0wNSAxMzoyNDo1OC4wMDAwMDAwMDAgLTA0MDANCisrKyBsaW51
eC0yLjYuNS0zNC1zdW5ycGNfZGlzY29ubmVjdC9uZXQvc3VucnBjL3hwcnQuYwkyMDA0LTA0LTA1
IDE1OjI3OjQyLjAwMDAwMDAwMCAtMDQwMA0KQEAgLTQ0OCw3ICs0NDgsMTAgQEAgeHBydF9pbml0
X2F1dG9kaXNjb25uZWN0KHVuc2lnbmVkIGxvbmcgZA0KIAkJZ290byBvdXRfYWJvcnQ7DQogCXNw
aW5fdW5sb2NrKCZ4cHJ0LT5zb2NrX2xvY2spOw0KIAkvKiBMZXQga2V2ZW50ZCBjbG9zZSB0aGUg
c29ja2V0ICovDQotCXNjaGVkdWxlX3dvcmsoJnhwcnQtPnRhc2tfY2xlYW51cCk7DQorCWlmICh0
ZXN0X2JpdChYUFJUX0NPTk5FQ1RJTkcsICZ4cHJ0LT5zb2Nrc3RhdGUpICE9IDApDQorCQl4cHJ0
X3JlbGVhc2Vfd3JpdGUoeHBydCwgTlVMTCk7DQorCWVsc2UNCisJCXNjaGVkdWxlX3dvcmsoJnhw
cnQtPnRhc2tfY2xlYW51cCk7DQogCXJldHVybjsNCiBvdXRfYWJvcnQ6DQogCXNwaW5fdW5sb2Nr
KCZ4cHJ0LT5zb2NrX2xvY2spOw0KQEAgLTQ2MCwxMiArNDYzLDggQEAgc3RhdGljIHZvaWQgeHBy
dF9zb2NrZXRfY29ubmVjdCh2b2lkICphcg0KIAlzdHJ1Y3Qgc29ja2V0ICpzb2NrID0geHBydC0+
c29jazsNCiAJaW50IHN0YXR1cyA9IC1FSU87DQogDQotCWlmICh4cHJ0LT5zaHV0ZG93bikgew0K
LQkJcnBjX3dha2VfdXBfc3RhdHVzKCZ4cHJ0LT5wZW5kaW5nLCAtRUlPKTsNCi0JCXJldHVybjsN
Ci0JfQ0KLQlpZiAoIXhwcnQtPmFkZHIuc2luX3BvcnQpDQotCQlnb3RvIG91dF9lcnI7DQorCWlm
ICh4cHJ0LT5zaHV0ZG93biB8fCB4cHJ0LT5hZGRyLnNpbl9wb3J0ID09IDApDQorCQlnb3RvIG91
dDsNCiANCiAJLyoNCiAJICogU3RhcnQgYnkgcmVzZXR0aW5nIGFueSBleGlzdGluZyBzdGF0ZQ0K
QEAgLTQ3NSwxMiArNDc0LDEyIEBAIHN0YXRpYyB2b2lkIHhwcnRfc29ja2V0X2Nvbm5lY3Qodm9p
ZCAqYXINCiAJaWYgKHNvY2sgPT0gTlVMTCkgew0KIAkJLyogY291bGRuJ3QgY3JlYXRlIHNvY2tl
dCBvciBiaW5kIHRvIHJlc2VydmVkIHBvcnQ7DQogCQkgKiB0aGlzIGlzIGxpa2VseSBhIHBlcm1h
bmVudCBlcnJvciwgc28gY2F1c2UgYW4gYWJvcnQgKi8NCi0JCWdvdG8gb3V0X2VycjsNCi0JCXJl
dHVybjsNCisJCWdvdG8gb3V0Ow0KIAl9DQogCXhwcnRfYmluZF9zb2NrZXQoeHBydCwgc29jayk7
DQogCXhwcnRfc29ja19zZXRidWZzaXplKHhwcnQpOw0KIA0KKwlzdGF0dXMgPSAwOw0KIAlpZiAo
IXhwcnQtPnN0cmVhbSkNCiAJCWdvdG8gb3V0Ow0KIA0KQEAgLTQ5MSwyOSArNDkwLDIyIEBAIHN0
YXRpYyB2b2lkIHhwcnRfc29ja2V0X2Nvbm5lY3Qodm9pZCAqYXINCiAJCQlzaXplb2YoeHBydC0+
YWRkciksIE9fTk9OQkxPQ0spOw0KIAlkcHJpbnRrKCJSUEM6ICVwICBjb25uZWN0IHN0YXR1cyAl
ZCBjb25uZWN0ZWQgJWQgc29jayBzdGF0ZSAlZFxuIiwNCiAJCQl4cHJ0LCAtc3RhdHVzLCB4cHJ0
X2Nvbm5lY3RlZCh4cHJ0KSwgc29jay0+c2stPnNrX3N0YXRlKTsNCi0JaWYgKHN0YXR1cyA+PSAw
KQ0KLQkJZ290byBvdXQ7DQotCXN3aXRjaCAoc3RhdHVzKSB7DQotCQljYXNlIC1FSU5QUk9HUkVT
UzoNCi0JCWNhc2UgLUVBTFJFQURZOg0KLQkJCXJldHVybjsNCi0JCWRlZmF1bHQ6DQotCQkJZ290
byBvdXRfZXJyOw0KKwlpZiAoc3RhdHVzIDwgMCkgew0KKwkJc3dpdGNoIChzdGF0dXMpIHsNCisJ
CQljYXNlIC1FSU5QUk9HUkVTUzoNCisJCQljYXNlIC1FQUxSRUFEWToNCisJCQkJZ290byBvdXRf
Y2xlYXI7DQorCQl9DQogCX0NCiBvdXQ6DQotCXNwaW5fbG9ja19iaCgmeHBydC0+c29ja19sb2Nr
KTsNCi0JaWYgKHhwcnQtPnNuZF90YXNrKQ0KLQkJcnBjX3dha2VfdXBfdGFzayh4cHJ0LT5zbmRf
dGFzayk7DQotCXNwaW5fdW5sb2NrX2JoKCZ4cHJ0LT5zb2NrX2xvY2spOw0KLQlyZXR1cm47DQot
b3V0X2VycjoNCi0Jc3Bpbl9sb2NrX2JoKCZ4cHJ0LT5zb2NrX2xvY2spOw0KLQlpZiAoeHBydC0+
c25kX3Rhc2spIHsNCi0JCXhwcnQtPnNuZF90YXNrLT50a19zdGF0dXMgPSBzdGF0dXM7DQotCQly
cGNfd2FrZV91cF90YXNrKHhwcnQtPnNuZF90YXNrKTsNCi0JfSBlbHNlDQotCQlycGNfd2FrZV91
cF9zdGF0dXMoJnhwcnQtPnBlbmRpbmcsIC1FTk9UQ09OTik7DQotCXNwaW5fdW5sb2NrX2JoKCZ4
cHJ0LT5zb2NrX2xvY2spOw0KKwlpZiAoc3RhdHVzIDwgMCkNCisJCXJwY193YWtlX3VwX3N0YXR1
cygmeHBydC0+cGVuZGluZywgc3RhdHVzKTsNCisJZWxzZQ0KKwkJcnBjX3dha2VfdXAoJnhwcnQt
PnBlbmRpbmcpOw0KK291dF9jbGVhcjoNCisJc21wX21iX19iZWZvcmVfY2xlYXJfYml0KCk7DQor
CWNsZWFyX2JpdChYUFJUX0NPTk5FQ1RJTkcsICZ4cHJ0LT5zb2Nrc3RhdGUpOw0KKwlzbXBfbWJf
X2FmdGVyX2NsZWFyX2JpdCgpOw0KIH0NCiANCiAvKg0KQEAgLTU0NSw3ICs1MzcsOCBAQCB2b2lk
IHhwcnRfY29ubmVjdChzdHJ1Y3QgcnBjX3Rhc2sgKnRhc2spDQogDQogCXRhc2stPnRrX3RpbWVv
dXQgPSBSUENfQ09OTkVDVF9USU1FT1VUOw0KIAlycGNfc2xlZXBfb24oJnhwcnQtPnBlbmRpbmcs
IHRhc2ssIHhwcnRfY29ubmVjdF9zdGF0dXMsIE5VTEwpOw0KLQlzY2hlZHVsZV93b3JrKCZ4cHJ0
LT5zb2NrX2Nvbm5lY3QpOw0KKwlpZiAoIXRlc3RfYW5kX3NldF9iaXQoWFBSVF9DT05ORUNUSU5H
LCAmeHBydC0+c29ja3N0YXRlKSkNCisJCXNjaGVkdWxlX3dvcmsoJnhwcnQtPnNvY2tfY29ubmVj
dCk7DQogCXJldHVybjsNCiAgb3V0X3dyaXRlOg0KIAl4cHJ0X3JlbGVhc2Vfd3JpdGUoeHBydCwg
dGFzayk7DQpAQCAtMTAyNyw5ICsxMDIwLDYgQEAgdGNwX3N0YXRlX2NoYW5nZShzdHJ1Y3Qgc29j
ayAqc2spDQogCQkJeHBydC0+dGNwX3JlY2xlbiA9IDA7DQogCQkJeHBydC0+dGNwX2NvcGllZCA9
IDA7DQogCQkJeHBydC0+dGNwX2ZsYWdzID0gWFBSVF9DT1BZX1JFQ00gfCBYUFJUX0NPUFlfWElE
Ow0KLQ0KLQkJCWlmICh4cHJ0LT5zbmRfdGFzaykNCi0JCQkJcnBjX3dha2VfdXBfdGFzayh4cHJ0
LT5zbmRfdGFzayk7DQogCQkJcnBjX3dha2VfdXAoJnhwcnQtPnBlbmRpbmcpOw0KIAkJfQ0KIAkJ
c3Bpbl91bmxvY2tfYmgoJnhwcnQtPnNvY2tfbG9jayk7DQo=

--=-wffVNpRm9tbctwe/vhCb--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
