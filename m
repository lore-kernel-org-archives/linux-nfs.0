From: Nikolaus Rath <Nikolaus@rath.org>
Subject: NFS FAQ, 6.4 Tunneling through SSH
Date: Tue, 10 Jul 2007 14:48:17 +0200
Message-ID: <87tzscjuge.fsf@nokile.rath.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I8F8S-00050a-UJ
	for nfs@lists.sourceforge.net; Tue, 10 Jul 2007 05:48:09 -0700
Received: from nelarikon.net ([85.214.16.64] helo=ebox.rath.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I8F8V-0008SW-10
	for nfs@lists.sourceforge.net; Tue, 10 Jul 2007 05:48:12 -0700
Received: from [130.183.93.76] (helo=nokile.rath.org)
	by ebox.rath.org with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63) (envelope-from <Nikolaus@rath.org>) id 1I8F84-00040Q-NY
	for nfs@lists.sourceforge.net; Tue, 10 Jul 2007 14:47:48 +0200
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

SGVsbG8sCgpJIGhhdmUgYSBxdWVzdGlvbiB0byB0aGUgRkFRIGVudHJ5IDYuNC4gVGhlcmUgaXQg
c2F5cyB0aGF0CihodHRwOi8vbmZzLnNvdXJjZWZvcmdlLm5ldC9uZnMtaG93dG8vYXIwMXMwNi5o
dG1sI3R1bm5lbGluZ19uZnNfc3NoKQoKLC0tLS0KfCBIYXZpbmcgZG9uZSB0aGlzLCB3ZSBjYW4g
c2VlIHdoeSB0aGUgYWJvdmUgd2lsbCBiZSBpbmNyZWRpYmx5IGluc2VjdXJlCnwgaWYgd2UgaGF2
ZSBhbnkgb3JkaW5hcnkgdXNlcnMgd2hvIGFyZSBhYmxlIHRvIGxvZyBpbiB0byB0aGUgc2VydmVy
CnwgbG9jYWxseS4gSWYgdGhleSBjYW4sIHRoZXJlIGlzIG5vdGhpbmcgcHJldmVudGluZyB0aGVt
IGZyb20gZG9pbmcgd2hhdAp8IHdlIGRpZCBhbmQgdXNpbmcgc3NoIHRvIGZvcndhcmQgYSBwcml2
aWxlZ2VkIHBvcnQgb24gdGhlaXIgb3duIGNsaWVudAp8IG1hY2hpbmUgKHdoZXJlIHRoZXkgYXJl
IGxlZ2l0aW1hdGVseSByb290KSB0byBwb3J0cyAyMDQ5IGFuZCAzMjc2NyBvbgp8IHRoZSBzZXJ2
ZXIuIFRodXMsIGFueSBvcmRpbmFyeSB1c2VyIG9uIHRoZSBzZXJ2ZXIgY2FuIG1vdW50IG91cgp8
IGZpbGVzeXN0ZW1zIHdpdGggdGhlIHNhbWUgcmlnaHRzIGFzIHJvb3Qgb24gb3VyIGNsaWVudC4K
YC0tLS0KCkkgZG8gbm90IHF1aXRlIHVuZGVyc3RhbmQgdGhpcyBwb2ludC4gSWYgSSBjcmVhdGUg
YW4gU1NIIHR1bm5lbCBmcm9tIGEKcmVtb3RlIGhvc3QgdG8gbXkgTkZTIHNlcnZlciwgdGhlbiB0
aGUgTkZTIHNlcnZlciB3aWxsIHJlY2VpdmUgYQpjb25uZWN0aW9uIGZyb20gbG9jYWxob3N0LCBi
dXQgYWxzbyBmcm9tIGEgbm9uLXByaXZpbGVnZWQsIHNlbWlyYW5kb20KcG9ydC4gSWYgSSB1c2Ug
dGhlICJzZWN1cmUiIG9wdGlvbiBpbiAvZXRjL2V4cG9ydHMgKHdoaWNoIHNlZW1zIHRvIGJlCnRo
ZSBkZWZhdWx0KSwgdGhlbiB0aGVzZSByZXF1ZXN0cyB3aWxsIGJlIGlnbm9yZWQgYmVjYXVzZSB0
aGV5IGRvbid0CmNvbWUgZnJvbSBhIHByaXZpbGVnZWQgcG9ydC4KCkNhbiBzb21lb25lIGV4cGxh
aW4gbXkgd2h5IHRoaXMgaXMgc3RpbGwgaW5zZWN1cmU/CgoKQmVzdCwKICAgLU5pa29sYXVzCgot
LSAKIE5pa29sYXVzQHJhdGgub3JnIHwgQ29sbGVnZSBSaW5nIDYsIDI4NzU5IEJyZW1lbiwgR2Vy
bWFueQogQ2xhc3Mgb2YgMjAwOCAtIFBoeXNpY3MgfCBKYWNvYnMgVW5pdmVyc2l0eSBCcmVtZW4K
CiDCu015IG9waW5pb25zIG1heSBoYXZlIGNoYW5nZWQsIGJ1dCBub3QgdGhlIGZhY3QgdGhhdCBJ
IGFtIHJpZ2h0LsKrCgotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tClRoaXMgU0YubmV0IGVtYWlsIGlzIHNwb25z
b3JlZCBieSBEQjIgRXhwcmVzcwpEb3dubG9hZCBEQjIgRXhwcmVzcyBDIC0gdGhlIEZSRUUgdmVy
c2lvbiBvZiBEQjIgZXhwcmVzcyBhbmQgdGFrZQpjb250cm9sIG9mIHlvdXIgWE1MLiBObyBsaW1p
dHMuIEp1c3QgZGF0YS4gQ2xpY2sgdG8gZ2V0IGl0IG5vdy4KaHR0cDovL3NvdXJjZWZvcmdlLm5l
dC9wb3dlcmJhci9kYjIvCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fCk5GUyBtYWlsbGlzdCAgLSAgTkZTQGxpc3RzLnNvdXJjZWZvcmdlLm5ldApodHRwczov
L2xpc3RzLnNvdXJjZWZvcmdlLm5ldC9saXN0cy9saXN0aW5mby9uZnMK
