Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Thu, 3 Sep 2009 09:54:04 -0400
To: Steve French <smfrench@gmail.com>
Subject: Re: POSIX ACL support for NFSV4 (using sideband protocol)
Message-ID: <20090903135404.GA4566@fieldses.org>
References: <4A9F6027.9050807@s3group.cz>
	<7A24DF798E223B4C9864E8F92E8C93EC03F0ABED@SACMVEXC1-PRD.hq.netapp.com>
	<524f69650909030636g68706b09wa50ad91984407878@mail.gmail.com>
In-Reply-To: <524f69650909030636g68706b09wa50ad91984407878@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        nfsv4@linux-nfs.org, ffilzlnx@linux.vnet.ibm.com, jra@samba.org,
        agruen@suse.de
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="utf-8"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCBTZXAgMDMsIDIwMDkgYXQgMDg6MzY6NDRBTSAtMDUwMCwgU3RldmUgRnJlbmNoIHdy
b3RlOgo+IE9uIFRodSwgU2VwIDMsIDIwMDkgYXQgMjo0NiBBTSwgTXVudHosIERhbmllbDxEYW4u
TXVudHpAbmV0YXBwLmNvbT4gd3JvdGU6Cj4gPiBJJ3ZlIGFsd2F5cyB0aG91Z2h0IG9mIE5GUyBh
cyBhIG1lYW5zIGZvciBtYWtpbmcgcGh5c2ljYWwgZmlsZSBzeXN0ZW1zCj4gPiBhdmFpbGFibGUg
YWNyb3NzIGEgbmV0d29yay4gwqBORlMgaGF2aW5nIGl0cyBvd24gQUNMcyBkb2Vzbid0IGZpdCB0
aGlzCj4gPiBtb2RlbC4gwqBFLmcuLCAiTkZTIEFDTHMiIHdpbGwgbmV2ZXIgYmUgaW50ZWdyYXRl
ZCBpbnRvIE5URlMuIMKgSG93ZXZlciwgSQo+ID4gY291bGQgaW1hZ2luZSBORlMgQUNMcyBzb2x2
aW5nIHRoZSBnZW5lcmFsIHByb2JsZW0gaWYgdGhleSB3ZXJlIHRvIGZvcm0KPiA+IGEgc3VwZXJz
ZXQgb2YgdGhlIEFDTHMgb2YgZXhwb3J0YWJsZSBwaHlzaWNhbCBmaWxlIHN5c3RlbXMKPiAKPiBO
RlN2NCBBQ0xzIGFyZSBzaW1pbGFyIHRvIENJRlMvTlRGUyBBQ0xTLiBORlN2NCBBQ0xzIHdlcmUK
PiBvcmlnaW5hbGx5IGJhc2VkIG9uIENJRlMvTlRGUyBBQ0xzIHNvIGl0IHdvdWxkIGJlIHJlYXNv
bmFibGUKPiB0byBleHBvcnQgdGhlbSBmcm9tIE5URlMgKGFsdGhvdWdoIHRoZSBTSURzIChVVUlE
cykgaGF2ZSB0byBiZSBtYXBwZWQKPiB0byBsb2NhbCBMaW51eCBVSURzIC0gd2UgaGF2ZSB1c2Vy
IHNwYWNlIGNvZGUgdGhhdCBjYW4gZG8gdGhpcyBpbiBTYW1iYSkuCgpPbiB0aGUgc2VydmVyIHNp
ZGUsIHlvdSdkIGFjdHVhbGx5IGhhdmUgdG8gbWFwIGJldHdlZW4gU0lEcyBhbmQgTkZTdjQKbmFt
ZXMgKHN0cmluZ3Mgb2YgdGhlIGZvcm0gdXNlckBkb21haW4pLgoKLS1iLgoKPiBOb3RlIFNhbWJh
IHNlcnZlciBjYW4gbWFwIGJldHdlZW4gdGhlIENJRlMvTlRGUyBhbmQgTkZTdjQKPiBBQ0xzIGFs
cmVhZHkgYW5kIGhhcyBmb3IgbWFueSB5ZWFycy4KPiAKPiBKUkEgb24gdGhlIFNhbWJhIHRlYW0g
YW5kIEFuZHJlYXMgaGF2ZSBkb25lIHNvbWUgZ29vZAo+IHByZXNlbnRhdGlvbnMgb24gdGhlIGRp
ZmZlcmVuY2VzIGluIEFDTCBtb2RlbHMsIGJ1dCBvdGhlciB0aGFuCj4gc3RvcmluZyB0aGUgIm1h
c2siIG9yIGVxdWl2YWxlbnQgLSBQT1NJWCBBQ0xzIGNhbiBiZSB0aG91Z2h0IG9mIGFzCj4gYSBz
dWJzZXQgb2YgTkZTdjQvQ0lGUy9OVEZTIEFDTHMKX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX18KTkZTdjQgbWFpbGluZyBsaXN0Ck5GU3Y0QGxpbnV4LW5mcy5v
cmcKaHR0cDovL2xpbnV4LW5mcy5vcmcvY2dpLWJpbi9tYWlsbWFuL2xpc3RpbmZvL25mc3Y0
