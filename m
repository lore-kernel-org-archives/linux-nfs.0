Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:6813 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754746Ab2JSVFK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Oct 2012 17:05:10 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: RE: [PATCH] SUNRPC: Set alloc_slot for backchannel tcp ops
Date: Fri, 19 Oct 2012 21:05:08 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA909285321@SACEXCMBX04-PRD.hq.netapp.com>
References: <1348508341-19642-1-git-send-email-bjschuma@netapp.com>
 <20121019193951.GA30593@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9092851AD@SACEXCMBX04-PRD.hq.netapp.com>
 <20121019210121.GB2320@fieldses.org>
In-Reply-To: <20121019210121.GB2320@fieldses.org>
Content-Type: multipart/mixed;
	boundary="_002_4FA345DA4F4AE44899BD2B03EEEC2FA909285321SACEXCMBX04PRDh_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA909285321SACEXCMBX04PRDh_
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Friday, October 19, 2012 5:01 PM
> To: Myklebust, Trond
> Cc: Schumaker, Bryan; linux-nfs@vger.kernel.org; stable@vger.kernel.org
> Subject: Re: [PATCH] SUNRPC: Set alloc_slot for backchannel tcp ops
>=20
> On Fri, Oct 19, 2012 at 08:23:05PM +0000, Myklebust, Trond wrote:
> >
> > Et tu Bruce?
> >
> > Not yet, because if you check, neither has commit f39c1bfb5a (SUNRPC: F=
ix
> a UDP transport regression). I figured it is better to send them both tog=
ether
> as a single patch.
>=20
> I'm confused, I thought I did check.  Looking again...  It's in 3.6:
>=20
> 	$ git log v3.6..f39c1bfb5a
> 	$

Yes. 3.6 still has the original patch+problem.

> and cc'd to stable:
>=20
> 	$ git show f39c1bfb5a|grep stable
> 	    Cc: stable@vger.kernel.org [>=3D 3.1]
>=20
> so presumably it's already on its way to older stable branches too.

No. See attachment...=20

=20
> >
> > Trond
> >
> > > -----Original Message-----
> > > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > > Sent: Friday, October 19, 2012 3:40 PM
> > > To: Schumaker, Bryan
> > > Cc: Myklebust, Trond; linux-nfs@vger.kernel.org;
> > > stable@vger.kernel.org
> > > Subject: Re: [PATCH] SUNRPC: Set alloc_slot for backchannel tcp ops
> > >
> > > Did this not get sent to stable?  (Now upstream as
> > > 84e28a307e376f271505af65a7b7e212dd6f61f4.)
> > >
> > > --b.
> > >
> > > On Mon, Sep 24, 2012 at 01:39:01PM -0400, bjschuma@netapp.com
> wrote:
> > > > From: Bryan Schumaker <bjschuma@netapp.com>
> > > >
> > > > f39c1bfb5a03e2d255451bff05be0d7255298fa4 (SUNRPC: Fix a UDP
> > > transport
> > > > regression) introduced the "alloc_slot" function for xprt
> > > > operations, but never created one for the backchannel operations.
> > > > This patch fixes a null pointer dereference when mounting NFS over
> v4.1.
> > > >
> > > > Call Trace:
> > > >  [<ffffffffa0207957>] ? xprt_reserve+0x47/0x50 [sunrpc]
> > > > [<ffffffffa02023a4>] call_reserve+0x34/0x60 [sunrpc]
> > > > [<ffffffffa020e280>] __rpc_execute+0x90/0x400 [sunrpc]
> > > > [<ffffffffa020e61a>] rpc_async_schedule+0x2a/0x40 [sunrpc]
> > > > [<ffffffff81073589>] process_one_work+0x139/0x500
> > > > [<ffffffff81070e70>] ? alloc_worker+0x70/0x70  [<ffffffffa020e5f0>]=
 ?
> > > > __rpc_execute+0x400/0x400 [sunrpc]  [<ffffffff81073d1e>]
> > > > worker_thread+0x15e/0x460  [<ffffffff8145c839>] ?
> > > > preempt_schedule+0x49/0x70  [<ffffffff81073bc0>] ?
> > > > rescuer_thread+0x230/0x230  [<ffffffff81079603>] kthread+0x93/0xa0
> > > > [<ffffffff81465d04>] kernel_thread_helper+0x4/0x10
> > > > [<ffffffff81079570>] ? kthread_freezable_should_stop+0x70/0x70
> > > >  [<ffffffff81465d00>] ? gs_change+0x13/0x13
> > > >
> > > > Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> > > > ---
> > > >  net/sunrpc/xprtsock.c | 1 +
> > > >  1 file changed, 1 insertion(+)
> > > >
> > > > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c index
> > > > 86b7777..aaaadfb 100644
> > > > --- a/net/sunrpc/xprtsock.c
> > > > +++ b/net/sunrpc/xprtsock.c
> > > > @@ -2521,6 +2521,7 @@ static struct rpc_xprt_ops xs_tcp_ops =3D {
> > > > static struct rpc_xprt_ops bc_tcp_ops =3D {
> > > >  	.reserve_xprt		=3D xprt_reserve_xprt,
> > > >  	.release_xprt		=3D xprt_release_xprt,
> > > > +	.alloc_slot		=3D xprt_alloc_slot,
> > > >  	.rpcbind		=3D xs_local_rpcbind,
> > > >  	.buf_alloc		=3D bc_malloc,
> > > >  	.buf_free		=3D bc_free,
> > > > --
> > > > 1.7.12.1
> > > >
> > > > --
> > > > To unsubscribe from this list: send the line "unsubscribe linux-nfs=
"
> > > > in the body of a message to majordomo@vger.kernel.org More
> > > majordomo
> > > > info at  http://vger.kernel.org/majordomo-info.html

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA909285321SACEXCMBX04PRDh_
Content-Type: message/rfc822
Content-Disposition: attachment;
	creation-date="Fri, 19 Oct 2012 21:05:07 GMT";
	modification-date="Fri, 19 Oct 2012 21:05:07 GMT"

From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>, "alan@lxorguk.ukuu.org.uk"
	<alan@lxorguk.ukuu.org.uk>, Dick Streefland <dick.streefland@altium.nl>
Subject: Re: [ 070/218] SUNRPC: Fix a UDP transport regression
Thread-Topic: [ 070/218] SUNRPC: Fix a UDP transport regression
Thread-Index: AQHNnbddGh1NIDpKcE2ye9YPNHTip5egqeAA
Date: Fri, 28 Sep 2012 20:29:38 +0000
Message-ID: <1348864178.4297.18.camel@lade.trondhjem.org>
References: <20120928201501.208384923@linuxfoundation.org>
	 <20120928201509.596735923@linuxfoundation.org>
In-Reply-To: <20120928201509.596735923@linuxfoundation.org>
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-evolution-source: 
x-evolution-transport: 1347325948.2863.24@lade.trondhjem.org-transport
x-evolution-source-message: AAMkAGViNGE0ZjM1LWQyNDQtNDUwNS1iMDQzLWExOTk4Mjg1ZTZmNABGAAAAAABvAk7Rdw1YToroT31ccKMABwBjeieNjQ28Q46l51xuGBi5AAAB3XQrAABPo0XaT0rkSJm9KwPu7C+pAAAI+9HaAAA=
x-evolution-source-flags: ANSWERED ANSWERED_ALL SEEN 
x-evolution-source-folder: folder://1347325948.2863.24%40lade.trondhjem.org/Inbox
x-evolution-format: text/plain
x-evolution-account: 1347325948.2863.24@lade.trondhjem.org
x-evolution-fcc: folder://1347325948.2863.24%40lade.trondhjem.org/Sent%20Items
Content-Type: text/plain; charset="utf-8"
Content-ID: <AB35CC1288292B4E8CFD983CE5D3C35E@tahoe.netapp.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0

T24gRnJpLCAyMDEyLTA5LTI4IGF0IDEzOjE0IC0wNzAwLCBHcmVnIEtyb2FoLUhhcnRtYW4gd3Jv
dGU6DQo+IDMuNC1zdGFibGUgcmV2aWV3IHBhdGNoLiAgSWYgYW55b25lIGhhcyBhbnkgb2JqZWN0
aW9ucywgcGxlYXNlIGxldCBtZSBrbm93Lg0KPg0KPiAtLS0tLS0tLS0tLS0tLS0tLS0NCj4NCj4g
RnJvbTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbT4NCj4NCj4g
Y29tbWl0IGYzOWMxYmZiNWEwM2UyZDI1NTQ1MWJmZjA1YmUwZDcyNTUyOThmYTQgdXBzdHJlYW0u
DQo+DQo+IENvbW1pdCA0M2NlZGJmMGU4ZGZiOWM1NjEwZWI3OTg1ZDVmMjEyNjNlMzEzODAyIChT
VU5SUEM6IEVuc3VyZSB0aGF0DQo+IHdlIGdyYWIgdGhlIFhQUlRfTE9DSyBiZWZvcmUgY2FsbGlu
ZyB4cHJ0X2FsbG9jX3Nsb3QpIGlzIGNhdXNpbmcNCj4gaGFuZ3MgaW4gdGhlIGNhc2Ugb2YgTkZT
IG92ZXIgVURQIG1vdW50cy4NCg0KRGl0dG8gd2l0aCB0aGlzLiBQbGVhc2UgaG9sZCB0aGlzIHBh
dGNoIHVudGlsIHRoZSAxIGxpbmUgZml4IG1lbnRpb25lZA0KcHJldmlvdXNseSBoYXMgYmVlbiBt
ZXJnZWQgdXBzdHJlYW0gKGF0IHdoaWNoIHBvaW50IEkgd2lsbCByZXNlbmQgdGhlDQpwYXRjaCB0
aHJvdWdoIHN0YWJsZUB2Z2VyLmtlcm5lbC5vcmcpLg0KDQpUaGFua3MhDQogIFRyb25kDQoNCi0t
DQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHAN
ClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0K

--_002_4FA345DA4F4AE44899BD2B03EEEC2FA909285321SACEXCMBX04PRDh_--
