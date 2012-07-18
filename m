Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rhebok.le.ac.uk ([143.210.16.38]:59271 "EHLO rhebok.le.ac.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751168Ab2GRVqc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Jul 2012 17:46:32 -0400
Received: from host86-157-246-96.range86-157.btcentralplus.com ([86.157.246.96]:54409 helo=[192.168.1.3])
	by rhebok.le.ac.uk with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	(envelope-from <liam.gretton@leicester.ac.uk>)
	id 1Src4k-0007Qr-8e
	for linux-nfs@vger.kernel.org; Wed, 18 Jul 2012 22:46:31 +0100
Message-ID: <50072EB7.9030402@leicester.ac.uk>
Date: Wed, 18 Jul 2012 22:46:31 +0100
From: Liam Gretton <liam.gretton@leicester.ac.uk>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs4-acl-tools (spaces in principal names)
References: <50072D57.4060903@leicester.ac.uk>
In-Reply-To: <50072D57.4060903@leicester.ac.uk>
Content-Type: multipart/mixed;
 boundary="------------090402020306030403070208"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090402020306030403070208
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Attached is a patch which changes the behaviour of nfs4_setfacl slightly 
to allow it to add, remove and modify ACLs which act on principals 
containing space characters.

The rationale behind this is to allow us to use nfs4_setfacl on a file
system which is shared via CIFS to Windows clients and NFSv4. Though
very rare in a Unix environment, Windows commonly uses user names (and
hence principals derived from them) which contain spaces. A particularly 
common one is 'Domain Admins', the handling of which prompted me to look 
at modifying the nfs4_setfacl command.

As of 0.3.3 of nfs4-acl-tools, nfs4_setfacl fails to handle ACLs
containing a space character no matter what attempts to quote the ACE or 
escape the space character:

# nfs4_setfacl -a "A:fdg:Domain Admins@dom.org:R" file
Scanning ACE string 'A:fdg:Domain' failed.
Failed while inserting ACE(s) (at index 1).

(exit status 1.)

# nfs4_setfacl -a A:fdg:Domain\ Admins@dom.org:R file
Scanning ACE string 'A:fdg:Domain' failed.
Failed while inserting ACE(s) (at index 1).

(exit status 1.)

The attached patch modifies the parsing of the command line and
disallows space as an ACE delimiter. The patched version completes
successfully:

# nfs4_setfacl -a "A:fdg:Domain Admins@dom.org:R" file
# nfs4_getfacl file
A:fdg:Domain Admins@le.ac.uk:rtncy

ACEs can be chained with commas, but no longer with spaces. With the -A, 
-X, -S or -e options which expect a file containing ACLs, ACEs can be 
separated with tabs, newlines and/or carriage returns as before.

As there's a slight change in behaviour, the patch also modifies one of
the examples given in the EXAMPLES section of nfs4_setfacl(1) and the
text of the 'ACL FORMAT' section of nfs4_acl.

The patches don't modify any version numbers or dates.

Regards,

Liam

-- 
Liam Gretton                                    liam.gretton@le.ac.uk
HPC Architect                                http://www.le.ac.uk/its/
IT Services                                   Tel: +44 (0)116 2522254
University Of Leicester, University Road
Leicestershire LE1 7RH, United Kingdom



--------------090402020306030403070208
Content-Type: text/plain; charset=windows-1252;
 name="nfs4-acl-tools.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="nfs4-acl-tools.patch"

ZGlmZiAtcnVwIGJfbmZzNC1hY2wtdG9vbHMvbGlibmZzNGFjbC9uZnM0X2luc2VydF9zdHJp
bmdfYWNlcy5jIGFfbmZzNC1hY2wtdG9vbHMvbGlibmZzNGFjbC9uZnM0X2luc2VydF9zdHJp
bmdfYWNlcy5jCi0tLSBiX25mczQtYWNsLXRvb2xzL2xpYm5mczRhY2wvbmZzNF9pbnNlcnRf
c3RyaW5nX2FjZXMuYyAgICAgICAyMDEyLTA3LTE4IDIxOjE0OjQ3LjAwMDAwMDAwMCArMDEw
MAorKysgYV9uZnM0LWFjbC10b29scy9saWJuZnM0YWNsL25mczRfaW5zZXJ0X3N0cmluZ19h
Y2VzLmMgICAgICAgMjAxMi0wNy0xOCAxMTo1MTo0My4wMDAwMDAwMDAgKzAxMDAKQEAgLTQ1
LDcgKzQ1LDcgQEAgaW50IG5mczRfaW5zZXJ0X3N0cmluZ19hY2VzKHN0cnVjdCBuZnM0Xwog
ICAgICAgIGlmICgocyA9IHNwID0gc3RyZHVwKGFjbF9zcGVjKSkgPT0gTlVMTCkKICAgICAg
ICAgICAgICAgIGdvdG8gb3V0X2ZhaWxlZDsKCi0gICAgICAgd2hpbGUgKChzc3AgPSBzdHJz
ZXAoJnNwLCAiICxcdFxuXHIiKSkgIT0gTlVMTCkgeworICAgICAgIHdoaWxlICgoc3NwID0g
c3Ryc2VwKCZzcCwgIixcdFxuXHIiKSkgIT0gTlVMTCkgewogICAgICAgICAgICAgICAgaWYg
KCFzdHJsZW4oc3NwKSkKICAgICAgICAgICAgICAgICAgICAgICAgY29udGludWU7CgpkaWZm
IC1ydXAgYl9uZnM0LWFjbC10b29scy9tYW4vbWFuMS9uZnM0X3NldGZhY2wuMSBhX25mczQt
YWNsLXRvb2xzL21hbi9tYW4xL25mczRfc2V0ZmFjbC4xCi0tLSBiX25mczQtYWNsLXRvb2xz
L21hbi9tYW4xL25mczRfc2V0ZmFjbC4xICAgIDIwMTItMDctMTggMjE6MTQ6NDcuMDAwMDAw
MDAwICswMTAwCisrKyBhX25mczQtYWNsLXRvb2xzL21hbi9tYW4xL25mczRfc2V0ZmFjbC4x
ICAgIDIwMTItMDctMTggMjE6MTM6MDIuMDAwMDAwMDAwICswMTAwCkBAIC0yMDQsNyArMjA0
LDcgQEAgZGVsZXRlIHRoZSBmaXJzdCBBQ0UsIGJ1dCBvbmx5IHByaW50IHRoZQogLklQIC0g
MgogZGVsZXRlIHRoZSBsYXN0IHR3byBBQ0VzIGFib3ZlOgogLmJyCi0gICAgICAgJCBuZnM0
X3NldGZhY2wgLXggIkE6OkVWRVJZT05FQHJ0bmN5LCBEOjpFVkVSWU9ORUA6d2F4VEMiIGZv
bworICAgICAgICQgbmZzNF9zZXRmYWNsIC14IEE6OkVWRVJZT05FQHJ0bmN5LEQ6OkVWRVJZ
T05FQDp3YXhUQyBmb28KIC5JUCAtIDIKIG1vZGlmeSAoaW4tcGxhY2UpIHRoZSBzZWNvbmQg
QUNFIGFib3ZlOgogLmJyCmRpZmYgLXJ1cCBiX25mczQtYWNsLXRvb2xzL21hbi9tYW41L25m
czRfYWNsLjUgYV9uZnM0LWFjbC10b29scy9tYW4vbWFuNS9uZnM0X2FjbC41Ci0tLSBiX25m
czQtYWNsLXRvb2xzL21hbi9tYW41L25mczRfYWNsLjUgICAgICAgIDIwMTItMDctMTggMjE6
MTQ6NDcuMDAwMDAwMDAwICswMTAwCisrKyBhX25mczQtYWNsLXRvb2xzL21hbi9tYW41L25m
czRfYWNsLjUgICAgICAgIDIwMTItMDctMTggMjE6MTE6MTEuMDAwMDAwMDAwICswMTAwCkBA
IC01Niw3ICs1Niw3IEBAIG1vcmUgcGVybWlzc2l2ZSB0aGFuIHRoZSBvbmVzIHlvdSBzZXQu
CiAuU0ggQUNMIEZPUk1BVAogQW4gTkZTdjQgQUNMIGlzIHdyaXR0ZW4gYXMgYW4KIC5JUiBh
Y2xfc3BlYyAsCi13aGljaCBpcyBhIGNvbW1hLSBvciB3aGl0ZXNwYWNlLWRlbGltaXRlZCBz
dHJpbmcgY29uc2lzdGluZyBvZiBvbmUgb3IgbW9yZQord2hpY2ggaXMgYSBjb21tYS0gb3Ig
dGFiLWRlbGltaXRlZCBzdHJpbmcgY29uc2lzdGluZyBvZiBvbmUgb3IgbW9yZQogLklSIGFj
ZV9zcGVjcyAuCiBBIHNpbmdsZSBORlN2NCBBQ0UgaXMgd3JpdHRlbiBhcyBhbgogLklSIGFj
ZV9zcGVjICw=
--------------090402020306030403070208--
