From: Georg Ritter <newsgr.2007@gamebox.net>
Subject: Re: sco 5(server) linux(client,
 FC4) cp stalls after a few ten KBs
Date: Wed, 13 Dec 2006 21:56:49 +0100
Message-ID: <45806911.1060401@gamebox.net>
References: <457F5AE6.90900@gamebox.net>
	<1165975115.5695.21.camel@lade.trondhjem.org>
Reply-To: nfs@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GuaG9-0001CL-Uc
	for nfs@lists.sourceforge.net; Wed, 13 Dec 2006 11:59:22 -0800
Received: from viefep15-int.chello.at ([213.46.255.20]
	helo=viefep17-int.chello.at)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GuaG9-00035H-DB
	for nfs@lists.sourceforge.net; Wed, 13 Dec 2006 11:59:23 -0800
Received: from [213.47.225.118] by viefep17-int.chello.at
	(InterMail vM.6.01.05.04 201-2131-123-105-20051025) with ESMTP
	id <20061213195914.BJNU27.viefep17-int.chello.at@[213.47.225.118]>
	for <nfs@lists.sourceforge.net>; Wed, 13 Dec 2006 20:59:14 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <1165975115.5695.21.camel@lade.trondhjem.org>
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

VGhhbmtzLCBUcm9uZCwKCmZvciB0aGUgaWRlYS4gSSBkdW1wZWQgdGhlIHRyYWZmaWMsIGRvZXMg
aXQgcmV2ZWFsIHF1aWNrbHkgd2hhdCBpcyB3cm9uZywgZm9yPyAKVW5mb3J0dW5hdGxleSwgScK0
bSBub3QgZmlybSBlbm91Z2ggdG8gZGVyaXZlIGFueXRoaW5nIGZyb20gdGhlIGR1bXAuCgpTbyBz
ZXR1cCBhZ2FpbjoKbGludXgoRkM0IGJveCwgMi42LjE3LTEuMjE0Ml9GQzRzbXApIGNsaWVudCAo
Y2FsbGVkIGdpZ2FieXRlKQogICBtb3VudGluZyBmcm9tIGFuCiJTQ08gT3BlblNlcnZlcihUTSkg
UmVsZWFzZSA1IiBhcyBzZXJ2ZXIgKGNhbGxlZCBncCkuCgoidGNwZHVtcCBob3N0IGdwIiAob24g
bGludXggY2xpZW50LCBnaWdhYnl0ZSkgb2YgdGhlIGZvbGxvd2luZyBjb21tYW5kcyBpc3N1ZWQ6
Cm1vdW50IC10bmZzIC1vdmVycz0yLHRjcCxub2xvY2sgZ3A6L3Vzci9oYSAvbW50L25mcy9ncC9o
YQpjcCAvbW50L25mcy9ncC9oYS8xTUIuZGF0IC90bXAvCmhhbmdzIGZvcmV2ZXIuCmNyZWF0ZXMg
YSAiMCAxMy4gRGV6IDE4OjQ1IDFNQi5kYXQiIGluIC90bXAvCgpzb3VyY2UgZmlsZSBAZ3AgaW4g
L3Vzci9oYSBpcyAiMTA0ODU3NiBEZXogMTMgMTY6NDAgMU1CLmRhdCIKSXQgbm9ybWFsbHkgYWxz
byBjb3BpZXMgc29tZSB0ZW4gS0JzIGFuZCBoYW5ncyBhZnRlciB0aGF0LgoKaGVyZSB0aGUgZW5k
IG9mIHRoZSBkdW1wCi4uLgoxOToxMzowNS42MDQwMTggSVAgZ2lnYWJ5dGUuMTAyMyA+IGdwLm5m
czogLiBhY2sgMTk5MjUzIHdpbiA2Mjc4MAoxOToxMzowNS42MDQ4OTIgSVAgZ3AubmZzID4gZ2ln
YWJ5dGUuMDogcmVwbHkgb2sgOTk2CjE5OjEzOjA1LjYwNDk4NiBJUCBncC5uZnMgPiBnaWdhYnl0
ZS4xMDIzOiAuIGFjayA3MjM3IHdpbiA0MzgwCjE5OjEzOjA1LjYwNjIxNyBJUCBncC5uZnMgPiBn
aWdhYnl0ZS4xOTY4NDk1MTU1OiByZXBseSBvayAxNDYwIHJlYWQgW3xuZnNdCjE5OjEzOjA1LjYw
NjIyNyBJUCBnaWdhYnl0ZS4xMDIzID4gZ3AubmZzOiAuIGFjayAyMDE3MDkgd2luIDYyNzgwCjE5
OjEzOjA1CgpmdWxsIGR1bXAgaGVyZTogaHR0cDovLzExMjIzMzQ0NTU0NC4yMG0uY29tL25mc2R1
bXAuaHRtbAoKVGh4LAoKCUdlb3JnCgo+IEhvdyBhYm91dCBzdGFydGluZyB3aXRoIGEgdGNwZHVt
cCBvZiB0aGUgY2xpZW50IGFuZCBzZXJ2ZXIgYmVoYXZpb3VyPwo+IEFsc28sIHdoZW4gZm9yY2lu
ZyB0Y3AgbW91bnRzLCB5b3UgY2FuIHVzZSAnbmV0c3RhdCAtdCcgdG8gbW9uaXRvciB0aGUKPiBU
Q1AgbGluay4KPiAKPiBUcm9uZAo+IAo+IAo+IAoKCgotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tClRha2UgU3Vy
dmV5cy4gRWFybiBDYXNoLiBJbmZsdWVuY2UgdGhlIEZ1dHVyZSBvZiBJVApKb2luIFNvdXJjZUZv
cmdlLm5ldCdzIFRlY2hzYXkgcGFuZWwgYW5kIHlvdSdsbCBnZXQgdGhlIGNoYW5jZSB0byBzaGFy
ZSB5b3VyCm9waW5pb25zIG9uIElUICYgYnVzaW5lc3MgdG9waWNzIHRocm91Z2ggYnJpZWYgc3Vy
dmV5cyAtIGFuZCBlYXJuIGNhc2gKaHR0cDovL3d3dy50ZWNoc2F5LmNvbS9kZWZhdWx0LnBocD9w
YWdlPWpvaW4ucGhwJnA9c291cmNlZm9yZ2UmQ0lEPURFVkRFVgpfX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fXwpORlMgbWFpbGxpc3QgIC0gIE5GU0BsaXN0cy5z
b3VyY2Vmb3JnZS5uZXQKaHR0cHM6Ly9saXN0cy5zb3VyY2Vmb3JnZS5uZXQvbGlzdHMvbGlzdGlu
Zm8vbmZzCg==
