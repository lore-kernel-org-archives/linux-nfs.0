From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.5-rc3 xprt_connect changes?
Date: Thu, 01 Apr 2004 16:18:49 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1080854329.2682.36.camel@lade.trondhjem.org>
References: <20040401144740.GH20772@suse.de>
	 <1080853027.2682.22.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-k95DA6G0J9pdom2K5ASv"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B99aQ-0001DI-EF
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 13:18:54 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B99aQ-000207-0a
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 13:18:54 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <1080853027.2682.22.camel@lade.trondhjem.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--=-k95DA6G0J9pdom2K5ASv
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2004-04-01 at 15:57, Trond Myklebust wrote:

> How about if we simply move the call for xprt_disconnect() out of
> xprt_close()?

IOW, something like the appended patch. (Note the change to ensure that
we *do* wake up all pending tasks if the current attempt at reconnecting
actually fails.)

Cheers,
  Trond



--=-k95DA6G0J9pdom2K5ASv
Content-Description: 
Content-Disposition: inline; filename=linux-2.6.5-34-rpc_connect.dif
Content-Transfer-Encoding: base64
Content-Type: text/plain; charset=iso-8859-1

IHhwcnQuYyB8ICAgIDYgKysrKy0tDQogMSBmaWxlcyBjaGFuZ2VkLCA0IGluc2VydGlvbnMoKyks
IDIgZGVsZXRpb25zKC0pDQoNCmRpZmYgLXUgLS1yZWN1cnNpdmUgLS1zaG93LWMtZnVuY3Rpb24g
bGludXgtMi42LjUtMzMtcnBjX3F1ZXVlX2xvY2svbmV0L3N1bnJwYy94cHJ0LmMgbGludXgtMi42
LjUtMzQtcnBjX2Nvbm5lY3QvbmV0L3N1bnJwYy94cHJ0LmMNCi0tLSBsaW51eC0yLjYuNS0zMy1y
cGNfcXVldWVfbG9jay9uZXQvc3VucnBjL3hwcnQuYwkyMDA0LTAzLTMxIDIxOjQ4OjQ0LjAwMDAw
MDAwMCAtMDUwMA0KKysrIGxpbnV4LTIuNi41LTM0LXJwY19jb25uZWN0L25ldC9zdW5ycGMveHBy
dC5jCTIwMDQtMDQtMDEgMTY6MDM6MzMuMDAwMDAwMDAwIC0wNTAwDQpAQCAtNDA1LDcgKzQwNSw2
IEBAIHhwcnRfY2xvc2Uoc3RydWN0IHJwY194cHJ0ICp4cHJ0KQ0KIAlzay0+c2tfd3JpdGVfc3Bh
Y2UgID0geHBydC0+b2xkX3dyaXRlX3NwYWNlOw0KIAl3cml0ZV91bmxvY2tfYmgoJnNrLT5za19j
YWxsYmFja19sb2NrKTsNCiANCi0JeHBydF9kaXNjb25uZWN0KHhwcnQpOw0KIAlzay0+c2tfbm9f
Y2hlY2sJID0gMDsNCiANCiAJc29ja19yZWxlYXNlKHNvY2spOw0KQEAgLTQxNiw2ICs0MTUsNyBA
QCB4cHJ0X3NvY2tldF9hdXRvY2xvc2Uodm9pZCAqYXJncykNCiB7DQogCXN0cnVjdCBycGNfeHBy
dCAqeHBydCA9IChzdHJ1Y3QgcnBjX3hwcnQgKilhcmdzOw0KIA0KKwl4cHJ0X2Rpc2Nvbm5lY3Qo
eHBydCk7DQogCXhwcnRfY2xvc2UoeHBydCk7DQogCXhwcnRfcmVsZWFzZV93cml0ZSh4cHJ0LCBO
VUxMKTsNCiB9DQpAQCAtNTExLDcgKzUxMSw4IEBAIG91dF9lcnI6DQogCWlmICh4cHJ0LT5zbmRf
dGFzaykgew0KIAkJeHBydC0+c25kX3Rhc2stPnRrX3N0YXR1cyA9IHN0YXR1czsNCiAJCXJwY193
YWtlX3VwX3Rhc2soeHBydC0+c25kX3Rhc2spOw0KLQl9DQorCX0gZWxzZQ0KKwkJcnBjX3dha2Vf
dXBfc3RhdHVzKCZ4cHJ0LT5wZW5kaW5nLCAtRU5PVENPTk4pOw0KIAlzcGluX3VubG9ja19iaCgm
eHBydC0+c29ja19sb2NrKTsNCiB9DQogDQpAQCAtMTY0Miw2ICsxNjQzLDcgQEAgeHBydF9kZXN0
cm95KHN0cnVjdCBycGNfeHBydCAqeHBydCkNCiB7DQogCWRwcmludGsoIlJQQzogICAgICBkZXN0
cm95aW5nIHRyYW5zcG9ydCAlcFxuIiwgeHBydCk7DQogCXhwcnRfc2h1dGRvd24oeHBydCk7DQor
CXhwcnRfZGlzY29ubmVjdCh4cHJ0KTsNCiAJeHBydF9jbG9zZSh4cHJ0KTsNCiAJa2ZyZWUoeHBy
dC0+c2xvdCk7DQogCWtmcmVlKHhwcnQpOw0K

--=-k95DA6G0J9pdom2K5ASv--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
