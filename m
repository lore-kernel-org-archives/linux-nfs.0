From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] NFS mount: fix a mount problem when the user
	specifies	proto=udp
Date: Wed, 01 Nov 2006 16:09:54 -0500
Message-ID: <1162415394.6233.33.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-YaV9gpQZoF+GNUzQcIA6"
Cc: Olaf Kirch <okir@suse.de>, LaMont Jones <lamont@debian.org>,
	Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GfNLc-0006Nv-1X
	for nfs@lists.sourceforge.net; Wed, 01 Nov 2006 13:10:08 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GfNLc-0002H2-0z
	for nfs@lists.sourceforge.net; Wed, 01 Nov 2006 13:10:09 -0800
To: nfs@lists.sourceforge.net
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


--=-YaV9gpQZoF+GNUzQcIA6
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

The following fix to the NFSv4-patched util-linux package addresses a
problem when the user specifies the NFS mount options "proto=udp",
"notcp" or "udp". 

Instead of defaulting to using UDP when talking to the NFSv2/v3 mountd
on the server, the current behaviour will be to always probe for TCP
support. The following patch ensures that "proto=udp" overrides this
default behaviour, so that the client will actually use UDP to talk to
both mountd and the nfs server.

Cheers,
  Trond

--=-YaV9gpQZoF+GNUzQcIA6
Content-Disposition: inline; filename=30nfsmount_fix.dpatch
Content-Type: application/x-shellscript; name=30nfsmount_fix.dpatch
Content-Transfer-Encoding: base64

IyEgL2Jpbi9zaCAvdXNyL3NoYXJlL2RwYXRjaC9kcGF0Y2gtcnVuCiMjIDMwbmZzbW91bnRfZml4
LmRwYXRjaCBieSAgPFRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tPgojIwojIyBBbGwgbGluZXMg
YmVnaW5uaW5nIHdpdGggYCMjIERQOicgYXJlIGEgZGVzY3JpcHRpb24gb2YgdGhlIHBhdGNoLgoj
IyBEUDogRW5zdXJlIHRoYXQgaWYgdGhlIHVzZXIgc3BlY2lmaWVzIHRoZSAidWRwIiBvciAidGNw
IiBtb3VudCBvcHRpb24sCiMjIERQOiB3ZSBzaG91bGQgdXNlIHRoZSBjb3JyZWN0IHByb3RvY29s
IGZvciB0aGUgTU9VTlQgcnBjIGNhbGxzLgoKQERQQVRDSEAKZGlmZiAtdXJOYWQgdXRpbC1saW51
eC0yLjEycn4vbW91bnQvbmZzbW91bnQuYyB1dGlsLWxpbnV4LTIuMTJyL21vdW50L25mc21vdW50
LmMKLS0tIHV0aWwtbGludXgtMi4xMnJ+L21vdW50L25mc21vdW50LmMJMjAwNi0xMS0wMSAxNToy
Mjo0Ni4wMDAwMDAwMDAgLTA1MDAKKysrIHV0aWwtbGludXgtMi4xMnIvbW91bnQvbmZzbW91bnQu
YwkyMDA2LTExLTAxIDE1OjI2OjQ1LjAwMDAwMDAwMCAtMDUwMApAQCAtNjMyLDExICs2MzIsMTMg
QEAKIAkJCWlmICghc3RyY21wKG9wdCwgInByb3RvIikpIHsKIAkJCQlpZiAoIXN0cmNtcChvcHRl
cSsxLCAidWRwIikpIHsKIAkJCQkJbmZzX3BtYXAtPnBtX3Byb3QgPSBJUFBST1RPX1VEUDsKKwkJ
CQkJbW50X3BtYXAtPnBtX3Byb3QgPSBJUFBST1RPX1VEUDsKICNpZiBORlNfTU9VTlRfVkVSU0lP
TiA+PSAyCiAJCQkJCWRhdGEtPmZsYWdzICY9IH5ORlNfTU9VTlRfVENQOwogCQkJCX0gZWxzZSBp
ZiAoIXN0cmNtcChvcHRlcSsxLCAidGNwIikgJiYKIAkJCQkJICAgbmZzX21vdW50X3ZlcnNpb24g
PiAyKSB7CiAJCQkJCW5mc19wbWFwLT5wbV9wcm90ID0gSVBQUk9UT19UQ1A7CisJCQkJCW1udF9w
bWFwLT5wbV9wcm90ID0gSVBQUk9UT19UQ1A7CiAJCQkJCWRhdGEtPmZsYWdzIHw9IE5GU19NT1VO
VF9UQ1A7CiAjZW5kaWYKIAkJCQl9IGVsc2UgaWYgKCFzbG9wcHkpCkBAIC03MzEsMTggKzczMywy
NCBAQAogCQkJCQlpZiAobmZzX21vdW50X3ZlcnNpb24gPCAyKQogCQkJCQkJZ290byBiYWRfb3B0
aW9uOwogCQkJCQluZnNfcG1hcC0+cG1fcHJvdCA9IElQUFJPVE9fVENQOworCQkJCQltbnRfcG1h
cC0+cG1fcHJvdCA9IElQUFJPVE9fVENQOwogCQkJCQlkYXRhLT5mbGFncyB8PSBORlNfTU9VTlRf
VENQOwotCQkJCX0gZWxzZQorCQkJCX0gZWxzZSB7CiAJCQkJCW5mc19wbWFwLT5wbV9wcm90ID0g
SVBQUk9UT19VRFA7CisJCQkJCW1udF9wbWFwLT5wbV9wcm90ID0gSVBQUk9UT19VRFA7CisJCQkJ
fQogCQkJfSBlbHNlIGlmICghc3RyY21wKG9wdCwgInVkcCIpKSB7CiAJCQkJZGF0YS0+ZmxhZ3Mg
Jj0gfk5GU19NT1VOVF9UQ1A7CiAJCQkJaWYgKCF2YWwpIHsKIAkJCQkJaWYgKG5mc19tb3VudF92
ZXJzaW9uIDwgMikKIAkJCQkJCWdvdG8gYmFkX29wdGlvbjsKIAkJCQkJbmZzX3BtYXAtPnBtX3By
b3QgPSBJUFBST1RPX1RDUDsKKwkJCQkJbW50X3BtYXAtPnBtX3Byb3QgPSBJUFBST1RPX1RDUDsK
IAkJCQkJZGF0YS0+ZmxhZ3MgfD0gTkZTX01PVU5UX1RDUDsKLQkJCQl9IGVsc2UKKwkJCQl9IGVs
c2UgewogCQkJCQluZnNfcG1hcC0+cG1fcHJvdCA9IElQUFJPVE9fVURQOworCQkJCQltbnRfcG1h
cC0+cG1fcHJvdCA9IElQUFJPVE9fVURQOworCQkJCX0KICNlbmRpZgogI2lmIE5GU19NT1VOVF9W
RVJTSU9OID49IDMKIAkJCX0gZWxzZSBpZiAoIXN0cmNtcChvcHQsICJsb2NrIikpIHsK


--=-YaV9gpQZoF+GNUzQcIA6
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--=-YaV9gpQZoF+GNUzQcIA6
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-YaV9gpQZoF+GNUzQcIA6--
