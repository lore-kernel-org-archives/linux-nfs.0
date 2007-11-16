From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: osync-on-error getting upstream?
Date: Fri, 16 Nov 2007 12:25:08 -0500
Message-ID: <1195233908.7653.64.camel@heimdal.trondhjem.org>
References: <20071116171337.GA3864@sleipnir.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: nfs@lists.sourceforge.net
To: Fabio Olive Leite <fleite@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1It4wL-0005Dn-2s
	for nfs@lists.sourceforge.net; Fri, 16 Nov 2007 09:25:13 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1It4wK-0004W9-GY
	for nfs@lists.sourceforge.net; Fri, 16 Nov 2007 09:25:14 -0800
In-Reply-To: <20071116171337.GA3864@sleipnir.redhat.com>
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

Ck9uIEZyaSwgMjAwNy0xMS0xNiBhdCAxNToxMyAtMDIwMCwgRmFiaW8gT2xpdmUgTGVpdGUgd3Jv
dGU6Cj4gSGkgYWxsLAo+IAo+IFdoZW4gY2FuIHdlIGV4cGVjdCB0aGUgb3N5bmMtb24tZXJyb3Ig
cGF0Y2ggdG8gZ2V0IHVwc3RyZWFtPwo+IAo+IFRoYW5rcyEKPiBGw6FiaW8KCkknZCBzYXksIHJv
dWdobHksIGEgY291cGxlIG9mIHdlZWtzIGFnby4uLiA6LSkKCnRyb25kbXlAaGVpbWRhbDp+L3Jl
cG9zL2dpdC9saW51eC0yLjYkIGdpdCBsb2cgN2IxNTlmYzE4ZDQxNzk4MGY1N2FlZjY0Y2FiMzQx
N2VlNmFmNzBmOApBdXRob3I6IFRyb25kIE15a2xlYnVzdCA8VHJvbmQuTXlrbGVidXN0QG5ldGFw
cC5jb20+CkRhdGU6ICAgV2VkIEp1bCAyNSAxNDowOTo1NCAyMDA3IC0wNDAwCgogICAgTkZTOiBG
YWxsIGJhY2sgdG8gc3luY2hyb25vdXMgd3JpdGVzIHdoZW4gYSBiYWNrZ3JvdW5kIHdyaXRlIGVy
cm9ycy4uLgogICAgCiAgICBUaGlzIGhlbHBzIHByZXZlbnQgaHVnZSBxdWV1ZXMgb2YgYmFja2dy
b3VuZCB3cml0ZXMgZnJvbSBidWlsZGluZyB1cAogICAgd2hlbmV2ZXIgdGhlIHNlcnZlciBydW5z
IG91dCBvZiBkaXNrIG9yIHF1b3RhIHNwYWNlLCBvciBpZiBzb21lb25lIGNoYW5nZXMKICAgIHRo
ZSBmaWxlIGFjY2VzcyBtb2RlcyBiZWhpbmQgb3VyIGJhY2tzLgogICAgCiAgICBTaWduZWQtb2Zm
LWJ5OiBUcm9uZCBNeWtsZWJ1c3QgPFRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tPgoKdHJvbmRt
eUBoZWltZGFsOn4vcmVwb3MvZ2l0L2xpbnV4LTIuNiQgZ2l0IGRlc2NyaWJlIDdiMTU5ZmMxOGQ0
MTc5ODBmNTdhZWY2NGNhYjM0MTdlZTZhZjcwZjgKdjIuNi4yMy03LWc3YjE1OWZjCgpDaGVlcnMK
ICBUcm9uZAoKCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KVGhpcyBTRi5uZXQgZW1haWwgaXMgc3BvbnNvcmVk
IGJ5OiBNaWNyb3NvZnQKRGVmeSBhbGwgY2hhbGxlbmdlcy4gTWljcm9zb2Z0KFIpIFZpc3VhbCBT
dHVkaW8gMjAwNS4KaHR0cDovL2Nsay5hdGRtdC5jb20vTVJUL2dvL3ZzZTAxMjAwMDAwNzBtcnQv
ZGlyZWN0LzAxLwpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
XwpORlMgbWFpbGxpc3QgIC0gIE5GU0BsaXN0cy5zb3VyY2Vmb3JnZS5uZXQKaHR0cHM6Ly9saXN0
cy5zb3VyY2Vmb3JnZS5uZXQvbGlzdHMvbGlzdGluZm8vbmZzCl9fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fClBsZWFzZSBub3RlIHRoYXQgbmZzQGxpc3RzLnNv
dXJjZWZvcmdlLm5ldCBpcyBiZWluZyBkaXNjb250aW51ZWQuClBsZWFzZSBzdWJzY3JpYmUgdG8g
bGludXgtbmZzQHZnZXIua2VybmVsLm9yZyBpbnN0ZWFkLgogICAgaHR0cDovL3ZnZXIua2VybmVs
Lm9yZy92Z2VyLWxpc3RzLmh0bWwjbGludXgtbmZzCg==
