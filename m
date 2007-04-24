From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Tue, 24 Apr 2007 16:26:58 -0400
Message-ID: <462E6812.6040401@RedHat.com>
References: <17958.48121.280256.493824@notabene.brown>
	<462CB496.6000308@RedHat.com>
	<17965.15503.703515.820793@notabene.brown>
	<200704240908.39672.olaf.kirch@oracle.com>
	<20070424161027.GA30213@infradead.org>
	<462E38B9.5020808@RedHat.com> <20070424171708.GA7936@infradead.org>
	<462E43CC.6040806@RedHat.com>
	<Pine.LNX.4.64.0704242053510.32688@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: nfs@lists.sourceforge.net
To: =?UTF-8?B?UGV0ZXIgw4VzdHJhbmQ=?= <astrand@cendio.se>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgRbH-00066g-N2
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 13:27:00 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgRbJ-0000V0-QA
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 13:27:02 -0700
In-Reply-To: <Pine.LNX.4.64.0704242053510.32688@maggie.lkpg.cendio.se>
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

CgpQZXRlciDDhXN0cmFuZCB3cm90ZToKPiBPbmUgdGhpbmcgdGhhdCBib3RoZXJzIG1lIGlzIHRo
YXQgdGhlIGN1cnJlbnQgbGlidGlycGNbKl0gaXMgZGlmZmVyZW50IAo+IGZyb20gb3RoZXIgVEkt
UlBDIHZlcnNpb25zLiBUaGUgY3VycmVudCB2ZXJzaW9uIChhcyBmYXIgYXMgSSB1bmRlcnN0YW5k
KSAKPiBpcyBiYXNlZCBvbiBhIHNuYXBzaG90IGZyb20gRnJlZUJTRCwgd2hpY2ggaXMgdHVybiBp
cyBiYXNlZCBvbiBTdW5zIFRJUlBDIAo+IDIuMy4gVGhpcyBjb2RlIGlzICpub3QqIHVwIHRvIGRh
dGUgd2l0aCBUSS1SUEMgMi45IChha2EgdGlycGNzcmNfOTkpIGFuZCAKPiBjZXJ0YWlubHkgbm90
IHdpdGggdGhlIGxhdGVzdCBPcGVuU29sYXJpcyB2ZXJzaW9uLgpobW0uLi4gV2VyZSBkb2VzIG9u
ZSBnbyB0byBmaW5kIG91dCBob3cgdG8gYmUgY29tZSB0aXJwY3NyY185OQpjb21wbGlhbnQgYW5k
IHdoeSBpcyB0aGlzIGltcG9ydGFudD8gRG9lcyB0aGUgVEktUlBDIDIuOQp1c2UgYSBkaWZmZXJl
bnQgb3Zlci10aGUtd2lyZSBwcm90b2NvbD8gSSBzdXJlbHkgaG9wZSBub3QuLi4gOi1cCgo+IAo+
IEFub3RoZXIgcHJvYmxlbSB3aXRoIFRJLVJQQyBpcyB0aGF0IGEgV2luZG93cyBwb3J0IHNlZW1z
IHRvIGJlIGhhcmQuIAo+IFRoYXQncyBvbmUgcmVhc29uIHdoeSBJJ20gbm90IHBvcnRpbmcgdW5m
czMgdG8gVEktUlBDLiAKV293Li4uIEkgZGlkbid0IGV2ZW4ga25vdyBXaW5kb3dzIGhhZCBSUEMg
c3VwcG9ydC4uLiBidXQKSSBraW5kYSBkb3VidCB3ZSdsbCBiZSBwb3J0IG5mcy11dGlscyB0byBX
aW5kb3dzIGFueXRpbWUKc29vbi4uIDotKQoKPiAKPiBHZXR0aW5nIExpbnV4IGRpc3RyaWJ1dGlv
bnMgdG8gc2hpcCAodGhlIHNhbWUpIHZlcnNpb24gb2YgVEktUlBDIGlzIGEgCj4gd29ydGh3aGls
ZSBnb2FsLCBidXQgaWRlYWxseSwgd2Ugc2hvdWxkIGhhdmUgYW4gdXBzdHJlYW0gcHJvamVjdCB0
aGF0IAo+IGNvdmVycyBub3Qgb25seSBMaW51eCwgYnV0IGFsc28sICpCU0QsIE9wZW5Tb2xhcmlz
IGV0Yy4gSSBrbm93IGl0J3Mgbm90IAo+IGdvaW5nIHRvIGJlIGVhc3ksIGJ1dCBJIHRoaW5rIGl0
J3Mgd29ydGggYSB0cnkuCldlbGwgaWYgd2UgaGF2aW5nIHN1cHBvcnQgdGhhdHMgbmVlZGVkIGFu
ZC9vciB3YW50ZWQgaXQgc2hvdWxkIG5vdApiZSB0b28gZGlmZmljdWx0IHRvIGdldCBwZW9wbGUg
dG8gbW92ZSBvdmVyLi4uCgpzdGV2ZWQuCgoKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQpUaGlzIFNGLm5ldCBl
bWFpbCBpcyBzcG9uc29yZWQgYnkgREIyIEV4cHJlc3MKRG93bmxvYWQgREIyIEV4cHJlc3MgQyAt
IHRoZSBGUkVFIHZlcnNpb24gb2YgREIyIGV4cHJlc3MgYW5kIHRha2UKY29udHJvbCBvZiB5b3Vy
IFhNTC4gTm8gbGltaXRzLiBKdXN0IGRhdGEuIENsaWNrIHRvIGdldCBpdCBub3cuCmh0dHA6Ly9z
b3VyY2Vmb3JnZS5uZXQvcG93ZXJiYXIvZGIyLwpfX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fXwpORlMgbWFpbGxpc3QgIC0gIE5GU0BsaXN0cy5zb3VyY2Vmb3Jn
ZS5uZXQKaHR0cHM6Ly9saXN0cy5zb3VyY2Vmb3JnZS5uZXQvbGlzdHMvbGlzdGluZm8vbmZzCg==
