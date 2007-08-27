From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Attribute timeout handling and wrapping
	u32	jiffies
Date: Mon, 27 Aug 2007 09:23:40 -0400
Message-ID: <1188221020.6701.41.camel@heimdal.trondhjem.org>
References: <20070725030809.GB27619@sleipnir.redhat.com>
	<1185372013.6585.73.camel@localhost>
	<20070725142824.GA24321@sleipnir.redhat.com>
	<1185373979.6585.81.camel@localhost>
	<20070727015900.GA3000@sleipnir.redhat.com>
	<20070731162503.GC2964@sleipnir.redhat.com>
	<1185911253.6700.52.camel@localhost>
	<20070822182547.GD2874@sleipnir.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs <nfs@lists.sourceforge.net>
To: Fabio Olive Leite <fleite@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPeZO-00064B-Pk
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 06:23:55 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPeZR-0005U5-Uu
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 06:23:59 -0700
In-Reply-To: <20070822182547.GD2874@sleipnir.redhat.com>
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

T24gV2VkLCAyMDA3LTA4LTIyIGF0IDE1OjI1IC0wMzAwLCBGYWJpbyBPbGl2ZSBMZWl0ZSB3cm90
ZToKPiBIaSBUcm9uZCwKPiAKPiBPbiBUdWUsIEp1bCAzMSwgMjAwNyBhdCAwMzo0NzozM1BNIC0w
NDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6Cj4gPiAKPiA+IEl0IGxvb2tlZCBnb29kIHdoZW4g
SSBsYXN0ZXIgcmV2aWV3ZWQgaXQsIGJ1dCBJIGhhdmVuJ3QgeWV0IHRlc3RlZAo+ID4gaXQgbXlz
ZWxmLiBQbGVhc2Ugc2VuZCBtZSBhIHJlbWluZGVyIGlmIHlvdSBkb24ndCBzZWUgaXQgYXBwZWFy
IGluCj4gPiB0aGUgbmV4dCBORlNfQUxMIHJlbGVhc2UgKHdoaWNoIHNob3VsZCBiZSB3aXRoaW4g
YSB3ZWVrKS4KPiAKPiBJdCB3YXMgY29tbWl0ZWQgdG8gdGhlIG5mcy0yLjYuZ2l0IHJlcG8sIGJ1
dCBJIGhhdmVuJ3Qgc2VlbiBpdCBnZXQKPiB1cHN0cmVhbSB5ZXQuIFdlcmUgdGhlcmUgYW55IGlz
c3VlcyBJIGNvdWxkIHdvcmsgb24gdG8gc3BlZWQgdXAgdGhpcwo+IGNvbW1pdD8KPiAKPiBUaGFu
a3MhCj4gRsOhYmlvCgpJdCBkb2VzIG5vdCBhcHBlYXIgdG8gYmUgYSBjcml0aWNhbCBmaXgsIG9y
IGlmIGl0IGlzIHRoZW4gSSBuZWVkIGEKcmVmZXJlbmNlIHRvIGEgY2FzZSB3aGVyZSBhbiBPb3Bz
IG9yIGNvcnJ1cHRpb24gd2FzIHNlZW4gc28gdGhhdCBJIGNhbgpqdXN0aWZ5IG1lcmdpbmcgaXQg
bm93IHRvIExpbnVzIGFuZCBBbmRyZXcuCgpGYWlsaW5nIHRoYXQgSSBoYXZlIHF1ZXVlZCBpdCBm
b3IgdGhlIDIuNi4yNCBtZXJnZSB3aW5kb3cuCgpDaGVlcnMKICBUcm9uZAoKCi0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0KVGhpcyBTRi5uZXQgZW1haWwgaXMgc3BvbnNvcmVkIGJ5OiBTcGx1bmsgSW5jLgpTdGls
bCBncmVwcGluZyB0aHJvdWdoIGxvZyBmaWxlcyB0byBmaW5kIHByb2JsZW1zPyAgU3RvcC4KTm93
IFNlYXJjaCBsb2cgZXZlbnRzIGFuZCBjb25maWd1cmF0aW9uIGZpbGVzIHVzaW5nIEFKQVggYW5k
IGEgYnJvd3Nlci4KRG93bmxvYWQgeW91ciBGUkVFIGNvcHkgb2YgU3BsdW5rIG5vdyA+PiAgaHR0
cDovL2dldC5zcGx1bmsuY29tLwpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fXwpORlMgbWFpbGxpc3QgIC0gIE5GU0BsaXN0cy5zb3VyY2Vmb3JnZS5uZXQKaHR0
cHM6Ly9saXN0cy5zb3VyY2Vmb3JnZS5uZXQvbGlzdHMvbGlzdGluZm8vbmZzCg==
