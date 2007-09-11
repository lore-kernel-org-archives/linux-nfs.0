From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/15] SUNRPC: Clean up in rpc_show_tasks
Date: Tue, 11 Sep 2007 18:00:25 -0400
Message-ID: <20070911220025.26136.15011.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVDn9-0006wr-KL
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:01:07 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVDnD-0005Qv-11
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:01:12 -0700
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

L2hvbWUvY2VsL2xpbnV4L25ldC9zdW5ycGMvY2xudC5jOiBJbiBmdW5jdGlvbiDigJhycGNfc2hv
d190YXNrc+KAmToKL2hvbWUvY2VsL2xpbnV4L25ldC9zdW5ycGMvY2xudC5jOjE1Mzg6IHdhcm5p
bmc6CglzaWduZWQgYW5kIHVuc2lnbmVkIHR5cGUgaW4gY29uZGl0aW9uYWwgZXhwcmVzc2lvbgoK
VGhpcyBwb2ludHMgb3V0IGFub3RoZXIgY2FzZSB3aGVyZSBhIGNvbmRpdGlvbmFsIGV4cHJlc3Np
b24gcmV0dXJucyBhCnNpZ25lZCB2YWx1ZSBpbiBvbmUgYXJtIGFuZCBhbiB1bnNpZ25lZCB2YWx1
ZSBpbiB0aGUgb3RoZXIuCgpTaWduZWQtb2ZmLWJ5OiBDaHVjayBMZXZlciA8Y2h1Y2subGV2ZXJA
b3JhY2xlLmNvbT4KLS0tCgogbmV0L3N1bnJwYy9jbG50LmMgfCAgICA5ICsrKysrKystLQogMSBm
aWxlcyBjaGFuZ2VkLCA3IGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0
IGEvbmV0L3N1bnJwYy9jbG50LmMgYi9uZXQvc3VucnBjL2NsbnQuYwppbmRleCAwMzU3ODE5Li43
YTdjZDNiIDEwMDY0NAotLS0gYS9uZXQvc3VucnBjL2NsbnQuYworKysgYi9uZXQvc3VucnBjL2Ns
bnQuYwpAQCAtMTUyNiwxMyArMTUyNiwxOCBAQCB2b2lkIHJwY19zaG93X3Rhc2tzKHZvaWQpCiAJ
CXNwaW5fbG9jaygmY2xudC0+Y2xfbG9jayk7CiAJCWxpc3RfZm9yX2VhY2hfZW50cnkodCwgJmNs
bnQtPmNsX3Rhc2tzLCB0a190YXNrKSB7CiAJCQljb25zdCBjaGFyICpycGNfd2FpdHEgPSAibm9u
ZSI7CisJCQlpbnQgcHJvYzsKKworCQkJaWYgKHQtPnRrX21zZy5ycGNfcHJvYykKKwkJCQlwcm9j
ID0gdC0+dGtfbXNnLnJwY19wcm9jLT5wX3Byb2M7CisJCQllbHNlCisJCQkJcHJvYyA9IC0xOwog
CiAJCQlpZiAoUlBDX0lTX1FVRVVFRCh0KSkKIAkJCQlycGNfd2FpdHEgPSBycGNfcW5hbWUodC0+
dS50a193YWl0LnJwY193YWl0cSk7CiAKIAkJCXByaW50aygiJTV1ICUwNGQgJTA0eCAlNmQgJThw
ICU2ZCAlOHAgJThsZCAlOHMgJThwICU4cFxuIiwKLQkJCQl0LT50a19waWQsCi0JCQkJKHQtPnRr
X21zZy5ycGNfcHJvYyA/IHQtPnRrX21zZy5ycGNfcHJvYy0+cF9wcm9jIDogLTEpLAorCQkJCXQt
PnRrX3BpZCwgcHJvYywKIAkJCQl0LT50a19mbGFncywgdC0+dGtfc3RhdHVzLAogCQkJCXQtPnRr
X2NsaWVudCwKIAkJCQkodC0+dGtfY2xpZW50ID8gdC0+dGtfY2xpZW50LT5jbF9wcm9nIDogMCks
CgoKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLQpUaGlzIFNGLm5ldCBlbWFpbCBpcyBzcG9uc29yZWQgYnk6IE1p
Y3Jvc29mdApEZWZ5IGFsbCBjaGFsbGVuZ2VzLiBNaWNyb3NvZnQoUikgVmlzdWFsIFN0dWRpbyAy
MDA1LgpodHRwOi8vY2xrLmF0ZG10LmNvbS9NUlQvZ28vdnNlMDEyMDAwMDA3MG1ydC9kaXJlY3Qv
MDEvCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCk5GUyBt
YWlsbGlzdCAgLSAgTkZTQGxpc3RzLnNvdXJjZWZvcmdlLm5ldApodHRwczovL2xpc3RzLnNvdXJj
ZWZvcmdlLm5ldC9saXN0cy9saXN0aW5mby9uZnMK
