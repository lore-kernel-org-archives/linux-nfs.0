Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:28772 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757014Ab3CSQhT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Mar 2013 12:37:19 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/11] NFSv4.1: Enable open-by-filehandle
Date: Tue, 19 Mar 2013 16:37:17 +0000
Message-ID: <1363711037.7515.44.camel@leira.trondhjem.org>
References: <1363698463-3681-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1363698463-3681-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1363698463-3681-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1363698463-3681-10-git-send-email-Trond.Myklebust@netapp.com>
	 <20130319140901.GB7912@fieldses.org>
	 <1363702570.7515.6.camel@leira.trondhjem.org>
	 <20130319143236.GD7912@fieldses.org>
	 <1363704100.7515.12.camel@leira.trondhjem.org>
	 <20130319145035.GE7912@fieldses.org>
	 <1363706205.7515.43.camel@leira.trondhjem.org>
	 <20130319152304.GG7912@fieldses.org>
In-Reply-To: <20130319152304.GG7912@fieldses.org>
Content-Type: multipart/mixed;
	boundary="_002_1363711037751544camelleiratrondhjemorg_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_1363711037751544camelleiratrondhjemorg_
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <CBA178A977677544B700E9B957DDBC2E@tahoe.netapp.com>
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-03-19 at 11:23 -0400, J. Bruce Fields wrote:
> On Tue, Mar 19, 2013 at 03:16:46PM +0000, Myklebust, Trond wrote:
> > On Tue, 2013-03-19 at 10:50 -0400, J. Bruce Fields wrote:
> > > On Tue, Mar 19, 2013 at 02:41:42PM +0000, Myklebust, Trond wrote:
> > > > On Tue, 2013-03-19 at 10:32 -0400, J. Bruce Fields wrote:
> > > > > (Sorry for the digression, I was just trying to decide whether I =
can get
> > > > > away with turning on 4.1 by default before implementing SP4_MACH_=
CRED or
> > > > > GSS on the backchannel....)
> > > >=20
> > > > If you don't, could you please at least offer up a module parameter=
 that
> > > > allows me to do that? The current thing is a PITA, since it isn't
> > > > supported by any distro scripts, and it requires you to switch off =
the
> > > > server in order to change the version pseudofile contents.
> > >=20
> > > The module parameter on its own wouldn't help with that.
> > >=20
> > > We could probably fix the pseudofile interface to allow changing the
> > > version on the fly.
> > >=20
> > > My vague plan was to teach rpc.nfsd to read this (and other parameter=
s)
> > > from a config file, so then it'd be "vi /etc/nfsd && service nfsd
> > > restart" or equivalent.
> > >=20
> > > So is the main thing you want a more convenient interface or a way to
> > > change it without rebooting?
> >=20
> > Basically, all I want is to enable 4.1 permanently on those servers tha=
t
> > I want to use for NFSv4.1 testing.
> >=20
> > An --enable-nfs-version option for rpc.nfsd that acts together with
> > --no-nfs-version as a convenient interface for /proc/fs/nfsd/versions
> > would work fine too. All distro configuration scripts that I'm aware of
> > allow you to specify optional arguments to rpc.nfsd.
>=20
> Right, got it.  Yes, that's on my todo list.
>=20
> (But, of course, patches welcomed if someone wants to beat me to it.)

Here you go...

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

--_002_1363711037751544camelleiratrondhjemorg_
Content-Type: text/x-patch;
	name="0001-nfsd-Add-support-for-the-V-and-nfs-version-optional-.patch"
Content-Description: 0001-nfsd-Add-support-for-the-V-and-nfs-version-optional-.patch
Content-Disposition: attachment;
	filename="0001-nfsd-Add-support-for-the-V-and-nfs-version-optional-.patch";
	size=3943; creation-date="Tue, 19 Mar 2013 16:37:17 GMT";
	modification-date="Tue, 19 Mar 2013 16:37:17 GMT"
Content-ID: <76F724907215E64596BA595F0C6AF24B@tahoe.netapp.com>
Content-Transfer-Encoding: base64

RnJvbSAzYmVlYmM0NWQ1OWFhOTkwY2I1N2VmYmZiNTViNjJmNjkxODJkNDBhIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQ0KRnJvbTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0
YXBwLmNvbT4NCkRhdGU6IFR1ZSwgMTkgTWFyIDIwMTMgMTI6Mjg6MzUgLTA0MDANClN1YmplY3Q6
IFtQQVRDSF0gbmZzZDogQWRkIHN1cHBvcnQgZm9yIHRoZSAtViBhbmQgLS1uZnMtdmVyc2lvbiBv
cHRpb25hbA0KIGFyZ3VtZW50cw0KDQpBZGQgY29tbWFuZCBsaW5lIG9wdGlvbnMgdG8gZW5hYmxl
IHRob3NlIE5GUyB2ZXJzaW9ucyB0aGF0IGFyZQ0KY3VycmVudGx5IGRpc2FibGVkIGJ5IGRlZmF1
bHQuIFdlIGNob29zZSB0byB1c2UgdGhlIG9wdGlvbnMgJy1WJw0KYW5kICctLW5mcy12ZXJzaW9u
JyBmb3IgY29tcGF0aWJpbGl0eSB3aXRoIHJwYy5tb3VudGQuDQoNClNpZ25lZC1vZmYtYnk6IFRy
b25kIE15a2xlYnVzdCA8VHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20+DQotLS0NCiBzdXBwb3J0
L2luY2x1ZGUvbmZzL25mcy5oIHwgIDEgKw0KIHV0aWxzL25mc2QvbmZzZC5jICAgICAgICAgfCAy
NiArKysrKysrKysrKysrKysrKysrKysrKystLQ0KIHV0aWxzL25mc2QvbmZzZC5tYW4gICAgICAg
fCAgOSArKysrKysrKy0NCiAzIGZpbGVzIGNoYW5nZWQsIDMzIGluc2VydGlvbnMoKyksIDMgZGVs
ZXRpb25zKC0pDQoNCmRpZmYgLS1naXQgYS9zdXBwb3J0L2luY2x1ZGUvbmZzL25mcy5oIGIvc3Vw
cG9ydC9pbmNsdWRlL25mcy9uZnMuaA0KaW5kZXggMzIwODgwZS4uMTc0YzJkZCAxMDA2NDQNCi0t
LSBhL3N1cHBvcnQvaW5jbHVkZS9uZnMvbmZzLmgNCisrKyBiL3N1cHBvcnQvaW5jbHVkZS9uZnMv
bmZzLmgNCkBAIC01Miw2ICs1Miw3IEBAIHN0cnVjdCBuZnNfZmhfb2xkIHsNCiAjZGVmaW5lIE5G
U0NUTF9VRFBJU1NFVChfY2x0Yml0cykgICAgICgoX2NsdGJpdHMpICYgTkZTQ1RMX1VEUEJJVCkg
DQogI2RlZmluZSBORlNDVExfVENQSVNTRVQoX2NsdGJpdHMpICAgICAoKF9jbHRiaXRzKSAmIE5G
U0NUTF9UQ1BCSVQpIA0KIA0KKyNkZWZpbmUgTkZTQ1RMX1ZFUlNFVChfY2x0Yml0cywgX3YpICAg
KChfY2x0Yml0cykgfD0gKDEgPDwgKChfdikgLSAxKSkpIA0KICNkZWZpbmUgTkZTQ1RMX1VEUFNF
VChfY2x0Yml0cykgICAgICAgKChfY2x0Yml0cykgfD0gTkZTQ1RMX1VEUEJJVCkNCiAjZGVmaW5l
IE5GU0NUTF9UQ1BTRVQoX2NsdGJpdHMpICAgICAgICgoX2NsdGJpdHMpIHw9IE5GU0NUTF9UQ1BC
SVQpDQogDQpkaWZmIC0tZ2l0IGEvdXRpbHMvbmZzZC9uZnNkLmMgYi91dGlscy9uZnNkL25mc2Qu
Yw0KaW5kZXggMmEzZjVjYy4uZTg3YzBhOSAxMDA2NDQNCi0tLSBhL3V0aWxzL25mc2QvbmZzZC5j
DQorKysgYi91dGlscy9uZnNkL25mc2QuYw0KQEAgLTM4LDYgKzM4LDcgQEAgc3RhdGljIHN0cnVj
dCBvcHRpb24gbG9uZ29wdHNbXSA9DQogCXsgImhvc3QiLCAxLCAwLCAnSCcgfSwNCiAJeyAiaGVs
cCIsIDAsIDAsICdoJyB9LA0KIAl7ICJuby1uZnMtdmVyc2lvbiIsIDEsIDAsICdOJyB9LA0KKwl7
ICJuZnMtdmVyc2lvbiIsIDEsIDAsICdWJyB9LA0KIAl7ICJuby10Y3AiLCAwLCAwLCAnVCcgfSwN
CiAJeyAibm8tdWRwIiwgMCwgMCwgJ1UnIH0sDQogCXsgInBvcnQiLCAxLCAwLCAnUCcgfSwNCkBA
IC0xMTksNyArMTIwLDcgQEAgbWFpbihpbnQgYXJnYywgY2hhciAqKmFyZ3YpDQogCXhsb2dfc3lz
bG9nKDApOw0KIAl4bG9nX3N0ZGVycigxKTsNCiANCi0Jd2hpbGUgKChjID0gZ2V0b3B0X2xvbmco
YXJnYywgYXJndiwgImRIOmhOOnA6UDpzVFUiLCBsb25nb3B0cywgTlVMTCkpICE9IEVPRikgew0K
Kwl3aGlsZSAoKGMgPSBnZXRvcHRfbG9uZyhhcmdjLCBhcmd2LCAiZEg6aE46VjpwOlA6c1RVIiwg
bG9uZ29wdHMsIE5VTEwpKSAhPSBFT0YpIHsNCiAJCXN3aXRjaChjKSB7DQogCQljYXNlICdkJzoN
CiAJCQl4bG9nX2NvbmZpZyhEX0FMTCwgMSk7DQpAQCAtMTc1LDYgKzE3NiwyNyBAQCBtYWluKGlu
dCBhcmdjLCBjaGFyICoqYXJndikNCiAJCQkJZXhpdCgxKTsNCiAJCQl9DQogCQkJYnJlYWs7DQor
CQljYXNlICdWJzoNCisJCQlzd2l0Y2goKGMgPSBzdHJ0b2wob3B0YXJnLCAmcCwgMCkpKSB7DQor
CQkJY2FzZSA0Og0KKwkJCQlpZiAoKnAgPT0gJy4nKSB7DQorCQkJCQlpbnQgaSA9IGF0b2kocCsx
KTsNCisJCQkJCWlmIChpICE9IDEpIHsNCisJCQkJCQlmcHJpbnRmKHN0ZGVyciwgIiVzOiB1bnN1
cHBvcnRlZCBtaW5vciB2ZXJzaW9uXG4iLCBvcHRhcmcpOw0KKwkJCQkJCWV4aXQoMSk7DQorCQkJ
CQl9DQorCQkJCQltaW5vcnZlcnM0MSA9IDE7DQorCQkJCQlicmVhazsNCisJCQkJfQ0KKwkJCWNh
c2UgMzoNCisJCQljYXNlIDI6DQorCQkJCU5GU0NUTF9WRVJTRVQodmVyc2JpdHMsIGMpOw0KKwkJ
CQlicmVhazsNCisJCQlkZWZhdWx0Og0KKwkJCQlmcHJpbnRmKHN0ZGVyciwgIiVzOiBVbnN1cHBv
cnRlZCB2ZXJzaW9uXG4iLCBvcHRhcmcpOw0KKwkJCQlleGl0KDEpOw0KKwkJCX0NCisJCQlicmVh
azsNCiAJCWNhc2UgJ3MnOg0KIAkJCXhsb2dfc3lzbG9nKDEpOw0KIAkJCXhsb2dfc3RkZXJyKDAp
Ow0KQEAgLTMxMiw3ICszMzQsNyBAQCBzdGF0aWMgdm9pZA0KIHVzYWdlKGNvbnN0IGNoYXIgKnBy
b2cpDQogew0KIAlmcHJpbnRmKHN0ZGVyciwgIlVzYWdlOlxuIg0KLQkJIiVzIFstZHwtLWRlYnVn
XSBbLUggaG9zdG5hbWVdIFstcHwtUHwtLXBvcnQgcG9ydF0gWy1OfC0tbm8tbmZzLXZlcnNpb24g
dmVyc2lvbiBdIFstc3wtLXN5c2xvZ10gWy1UfC0tbm8tdGNwXSBbLVV8LS1uby11ZHBdIG5yc2Vy
dnNcbiIsIA0KKwkJIiVzIFstZHwtLWRlYnVnXSBbLUggaG9zdG5hbWVdIFstcHwtUHwtLXBvcnQg
cG9ydF0gWy1OfC0tbm8tbmZzLXZlcnNpb24gdmVyc2lvbl0gWy1WfC0tbmZzLXZlcnNpb24gdmVy
c2lvbl0gWy1zfC0tc3lzbG9nXSBbLVR8LS1uby10Y3BdIFstVXwtLW5vLXVkcF0gbnJzZXJ2c1xu
IiwgDQogCQlwcm9nKTsNCiAJZXhpdCgyKTsNCiB9DQpkaWZmIC0tZ2l0IGEvdXRpbHMvbmZzZC9u
ZnNkLm1hbiBiL3V0aWxzL25mc2QvbmZzZC5tYW4NCmluZGV4IDFjZjkyOTYuLjdkZTA4NjcgMTAw
NjQ0DQotLS0gYS91dGlscy9uZnNkL25mc2QubWFuDQorKysgYi91dGlscy9uZnNkL25mc2QubWFu
DQpAQCAtNDcsNyArNDcsNyBAQCBUaGlzIG9wdGlvbiBjYW4gYmUgdXNlZCB0byByZXF1ZXN0IHRo
YXQNCiAuQiBycGMubmZzZA0KIGRvZXMgbm90IG9mZmVyIGNlcnRhaW4gdmVyc2lvbnMgb2YgTkZT
LiBUaGUgY3VycmVudCB2ZXJzaW9uIG9mDQogLkIgcnBjLm5mc2QNCi1jYW4gc3VwcG9ydCBib3Ro
IE5GUyB2ZXJzaW9uIDIsMyBhbmQgdGhlIG5ld2VyIHZlcnNpb24gNC4NCitjYW4gc3VwcG9ydCBO
RlMgdmVyc2lvbnMgMiwzLDQgYW5kIHRoZSBuZXdlciB2ZXJzaW9uIDQuMS4NCiAuVFANCiAuQiBc
LXMgIiBvciAiIFwtXC1zeXNsb2cNCiBCeSBkZWZhdWx0LA0KQEAgLTY3LDYgKzY3LDEzIEBAIERp
c2FibGUNCiAuQiBycGMubmZzZA0KIGZyb20gYWNjZXB0aW5nIFVEUCBjb25uZWN0aW9ucyBmcm9t
IGNsaWVudHMuDQogLlRQDQorLkIgXC1WICIgb3IgIiBcLVwtbmZzLXZlcnNpb24gdmVycw0KK1Ro
aXMgb3B0aW9uIGNhbiBiZSB1c2VkIHRvIHJlcXVlc3QgdGhhdCANCisuQiBycGMubmZzZA0KK29m
ZmVyIGNlcnRhaW4gdmVyc2lvbnMgb2YgTkZTLiBUaGUgY3VycmVudCB2ZXJzaW9uIG9mDQorLkIg
cnBjLm5mc2QNCitjYW4gc3VwcG9ydCBORlMgdmVyc2lvbnMgMiwzLDQgYW5kIHRoZSBuZXdlciB2
ZXJzaW9uIDQuMS4NCisuVFANCiAuSSBucHJvYw0KIHNwZWNpZnkgdGhlIG51bWJlciBvZiBORlMg
c2VydmVyIHRocmVhZHMuIEJ5IGRlZmF1bHQsIGp1c3Qgb25lDQogdGhyZWFkIGlzIHN0YXJ0ZWQu
IEhvd2V2ZXIsIGZvciBvcHRpbXVtIHBlcmZvcm1hbmNlIHNldmVyYWwgdGhyZWFkcw0KLS0gDQox
LjguMS40DQoNCg==

--_002_1363711037751544camelleiratrondhjemorg_--
