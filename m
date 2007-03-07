From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] NFS: Sign Extentions with Tru64 FSIDs.
Date: Wed, 07 Mar 2007 09:21:49 -0500
Message-ID: <45EECA7D.1080505@RedHat.com>
References: <45EC7F0F.4090600@RedHat.com>
	<1173130678.6315.7.camel@heimdal.trondhjem.org>
	<45EC8FD3.4010809@redhat.com>
	<1173132182.6315.27.camel@heimdal.trondhjem.org>
	<45EC9837.1010504@redhat.com>
	<1173186308.6393.7.camel@heimdal.trondhjem.org>
	<45ED8135.2010008@RedHat.com> <45EDE060.3020501@RedHat.com>
	<Pine.LNX.4.64.0703070842410.11660@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: nfs@lists.sourceforge.net
To: =?UTF-8?B?UGV0ZXIgw4VzdHJhbmQ=?= <astrand@cendio.se>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOx1c-000157-G1
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 06:21:52 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOx1d-0003vR-BE
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 06:21:54 -0800
In-Reply-To: <Pine.LNX.4.64.0703070842410.11660@maggie.lkpg.cendio.se>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

CgpQZXRlciDDhXN0cmFuZCB3cm90ZToKPiBPbiBUdWUsIDYgTWFyIDIwMDcsIFN0ZXZlIERpY2tz
b24gd3JvdGU6Cj4gCj4+ICsgICAgICAgICAgICAgICB7IE5GU19NT1VOVF9OT1JESVJQTFVTLCAi
LG5vcmRpcnBsdXMiLCAiIiB9LAo+IAo+IEkgcHJlZmVyIHRoZSBvcHRpb24gbmFtZSAibm9yZWFk
ZGlycGx1cyIuIEl0J3Mgb25seSAzIGNoYXJzIGxvbmdlciwgYnV0IAo+IHRoYXQncyBhIHNtYWxs
IHByaWNlIHRvIHBheSBmb3IgYXZvaWRpbmcgY29uZnVzaW9uIGV0Yy4KVGhlIHJlYXNvbiBJIHVz
ZWQgJ25vcmRpcnBsdXMnIHdhcyBiZWNhdXNlIEFwcGxlIHVzZXMgdGhvc2UgY2hhcmFjdGVycwph
bmQgSSB0aG91Z2h0IGl0IGJlIGEgZ29vZCBJIGRpZCB0byB0cnkgYW5kIGtlZXAgdGhpbmdzIGNv
bnNpc3RlbnQuCkJ1dCBpbiB0aGUgZW5kLCBJIGNvdWxkIGNhcmVsZXNzIHdoYXQgd2UgY2FsbCB0
aGUgb3B0aW9uIGFzIGxvbmcKYXMgdGhlIGZ1bmN0aW9uYWxpdHkgaXMgdGhlcmUuLi4KCnN0ZXZl
ZC4KCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0KVGFrZSBTdXJ2ZXlzLiBFYXJuIENhc2guIEluZmx1ZW5jZSB0
aGUgRnV0dXJlIG9mIElUCkpvaW4gU291cmNlRm9yZ2UubmV0J3MgVGVjaHNheSBwYW5lbCBhbmQg
eW91J2xsIGdldCB0aGUgY2hhbmNlIHRvIHNoYXJlIHlvdXIKb3BpbmlvbnMgb24gSVQgJiBidXNp
bmVzcyB0b3BpY3MgdGhyb3VnaCBicmllZiBzdXJ2ZXlzLWFuZCBlYXJuIGNhc2gKaHR0cDovL3d3
dy50ZWNoc2F5LmNvbS9kZWZhdWx0LnBocD9wYWdlPWpvaW4ucGhwJnA9c291cmNlZm9yZ2UmQ0lE
PURFVkRFVgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpO
RlMgbWFpbGxpc3QgIC0gIE5GU0BsaXN0cy5zb3VyY2Vmb3JnZS5uZXQKaHR0cHM6Ly9saXN0cy5z
b3VyY2Vmb3JnZS5uZXQvbGlzdHMvbGlzdGluZm8vbmZzCg==
