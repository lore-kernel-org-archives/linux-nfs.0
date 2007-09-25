From: Jonas Jonsson <jonas@websystem.se>
Subject: Re: Problem with NFS4,
	Error: state recovery failed on NFSv4	 server 192.168.0.1 with
	error 121
Date: Tue, 25 Sep 2007 14:14:53 +0200
Message-ID: <1190722493.3935.3.camel@fry.u7.se>
References: <358c6ad3a55609518d1dfa15ef1f2bd2@imap.u7.se>
	<1190048861.6700.105.camel@heimdal.trondhjem.org>
	<1190049122.6700.108.camel@heimdal.trondhjem.org>
	<1190056357.5541.12.camel@fry.u7.se>
	<1190059068.6700.125.camel@heimdal.trondhjem.org>
	<1190060733.5541.14.camel@fry.u7.se>
	<1190396486.6690.4.camel@heimdal.trondhjem.org>
	<20070922185227.GD403@fieldses.org> <1190668767.3958.9.camel@fry.u7.se>
	<20070924220247.GO26387@fieldses.org>
	<20070924222026.GP26387@fieldses.org>
Reply-To: jonas@websystem.se
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ia9LE-0006kv-Nx
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 05:16:40 -0700
Received: from gonzzor.campus.luth.se ([130.240.199.196] helo=bender.u7.se)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ia9LJ-0000mR-En
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 05:16:45 -0700
In-Reply-To: <20070924222026.GP26387@fieldses.org>
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

bcOlbiAyMDA3LTA5LTI0IGtsb2NrYW4gMTg6MjAgLTA0MDAgc2tyZXYgSi4gQnJ1Y2UgRmllbGRz
Ogo+IE9uIE1vbiwgU2VwIDI0LCAyMDA3IGF0IDA2OjAyOjQ3UE0gLTA0MDAsIGJmaWVsZHMgd3Jv
dGU6Cj4gPiBPSywgdGhhbmtzISAgTG9va3MgbGlrZSBpdCBzdGFydHMgb3V0IGZhaXJseSBub3Jt
YWxseSwgdGhlbiBhdCBwYWNrZXQKPiA+IDgyNCBpdCBnZXRzIGludG8gdGhpcyBTRVRDTElFTlRJ
RC0+TkZTNEVSUl9SRVNPVVJDRSBsb29wLiAgSSdtIG5vdCBzdXJlCj4gPiBob3cgdGhhdCBoYXBw
ZW5lZC4KPiA+IAo+ID4gSSdtIGEgbGl0dGxlIHVuY2xlYXIgd2hldGhlciBSRVNPVVJDRSBpcyBz
dXBwb3NlZCB0byBiZSBhIHRlbXBvcmFyeQo+ID4gZXJyb3Igb3Igbm90LCBidXQgaW4gZWl0aGVy
IGNhc2UgcmV0cnlpbmcgaXQgaW5kZWZpbml0ZWx5IHdpdGggbm8gZGVsYXkKPiA+IGlzIHByb2Jh
Ymx5IGEgYmFkIGlkZWEuICBCdXQgSSBndWVzcyB0aGF0J3Mgbm90IHRoZSBidWcuICBPSywgSSds
bCB0cnkKPiA+IHRvIGZpZ3VyZSBvdXQgd2hhdCBsZWFkIHVwIHRvIHRoYXQuLi4uCj4gCj4gT2gs
IGdvb2QgZ3JpZWYsIHdlJ3JlIGxhbWUuICBDb3VsZCB5b3UgY2hlY2sgeW91ciAuY29uZmlnLS1p
cyBpdAo+IHBvc3NpYmxlIHlvdSBoYXZlIENPTkZJR19DUllQVE9fTUQ1IHR1cm5lZCBvZmY/ICBJ
ZiBzbywgY291bGQgeW91IHZlcmlmeQo+IHRoYXQgdHVybmluZyBpdCBvbiBmaXhlcyB0aGUgcHJv
YmxlbT8KPiAKPiBUaGUgcmVjb3ZlcnkgY29kZSBpcyBiZWluZyBzaWxseSBhbmQgcmV0dXJuaW5n
IFJFU09VUkNFIGlmIGl0IGNhbid0IGxvYWQKPiB0aGF0IGNyeXB0byBtb2R1bGUuICBDdXJyZW50
IHVwc3RyZWFtIGRvZXNuJ3QgYWxsb3cgYnVpbGRpbmcgdjQgd2l0aG91dAo+IE1ENSwgc28geW91
IHByb2JhYmx5IHdvbid0IGJlIGFibGUgdG8gcmVwcm9kdWNlIHRoZSBwcm9ibGVtIG9uIHRoZQo+
IGxhdGVzdCBrZXJuZWwuCgpZZXMsIHRoaXMgc29sdmVkIHRoZSBwcm9ibGVtLiBJIGhhZCB0aGUg
TUQ1IGNvbXBpbGVkIGFzIGEgbW9kdWxlLCBidXQgaXQKd2Fzbid0IGxvYWRlZCB3aGVuIGxvYWRp
bmcgbmZzIG1vZHVsZS4gVGhpcyBtaWdodCBiZSBmaXhlZCBpbiBsYXRlcgp2ZXJzaW9ucyBvZiB0
aGUga2VybmVsLgoKSG93ZXZlciwgb25lIHRoaW5nIGlzIHN0cmFuZ2UsIHdoeSBkaWQgbHMgd29y
ayB3aGVuIHN0YW5kaW5nIG91dHNpZGUgdGhlCk5GUyBtb3VudGVkIGZpbGVzeXN0ZW0gb24gdGhl
IGNsaWVudC4gQnV0IHdoZW4gSSB3YXMgc3RhbmRpbmcgaW4gdGhlCm1vdW50ZWQgZmlsZXN5c3Rl
bSwgbHMgaGFuZ2VkLgoKVGhhbmtzLgoKL0pvbmFzCj4gCj4gLS1iLgoKCi0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0KVGhpcyBTRi5uZXQgZW1haWwgaXMgc3BvbnNvcmVkIGJ5OiBNaWNyb3NvZnQKRGVmeSBhbGwg
Y2hhbGxlbmdlcy4gTWljcm9zb2Z0KFIpIFZpc3VhbCBTdHVkaW8gMjAwNS4KaHR0cDovL2Nsay5h
dGRtdC5jb20vTVJUL2dvL3ZzZTAxMjAwMDAwNzBtcnQvZGlyZWN0LzAxLwpfX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpORlMgbWFpbGxpc3QgIC0gIE5GU0Bs
aXN0cy5zb3VyY2Vmb3JnZS5uZXQKaHR0cHM6Ly9saXN0cy5zb3VyY2Vmb3JnZS5uZXQvbGlzdHMv
bGlzdGluZm8vbmZzCg==
