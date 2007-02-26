From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [PATCH] Fix reference error when writing fsloc data to
	cache
Date: Mon, 26 Feb 2007 14:17:06 -0500
Message-ID: <4d569c330702261117l4b5ece0eqcd0a62365a804070@mail.gmail.com>
References: <20070226183709.4060.68393.stgit@rock.citi.umich.edu>
	<20070226183747.4060.29293.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_98906_7269252.1172517426666"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLlLO-0000yv-RU
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 11:17:06 -0800
Received: from wr-out-0506.google.com ([64.233.184.229])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLlLQ-0006D5-IQ
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 11:17:08 -0800
Received: by wr-out-0506.google.com with SMTP id 68so1808165wri
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 11:17:08 -0800 (PST)
In-Reply-To: <20070226183747.4060.29293.stgit@rock.citi.umich.edu>
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

------=_Part_98906_7269252.1172517426666
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

The attached patch should fix fslocations in nfs-utils-1.0.11 and
allow it to work with or without the uuid kernel patches.

Patch from Steve Dickson still required.

------=_Part_98906_7269252.1172517426666
Content-Type: text/x-patch; name=fix_fslocations.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_eynaj468
Content-Disposition: attachment; filename="fix_fslocations.patch"

Rml4IHJlZmVyZW5jZSBlcnJvciB3aGVuIHdyaXRpbmcgZnNsb2MgZGF0YSB0byBjYWNoZQoKRnJv
bTogS2V2aW4gQ29mZm1hbiA8a3djQGNpdGkudW1pY2guZWR1PgoKVXNlIHRoZSBjb3JyZWN0IHBv
aW50ZXIgd2hlbiB3cml0aW5nIGZzbG9jYXRpb25zIGRhdGEgdG8gdGhlIGNhY2hlLgpBbHNvIHdy
aXRlIHRoZSBmc2xvYyBzdHVmZiBiZWZvcmUgdGhlIHV1aWQgc3R1ZmYgc28gdXNlcmxhbmQgY29k
ZQp3aWxsIHdvcmsgd2l0aCBvciB3aXRob3V0IHRoZSB1dWlkIGtlcm5lbCBwYXRjaGVzLgotLS0K
CiB1dGlscy9tb3VudGQvY2FjaGUuYyB8ICAgIDIgKy0KIDEgZmlsZXMgY2hhbmdlZCwgMSBpbnNl
cnRpb25zKCspLCAxIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL3V0aWxzL21vdW50ZC9jYWNo
ZS5jIGIvdXRpbHMvbW91bnRkL2NhY2hlLmMKaW5kZXggYTE0ZjRmMi4uNWYwZDEyYSAxMDA2NDQK
LS0tIGEvdXRpbHMvbW91bnRkL2NhY2hlLmMKKysrIGIvdXRpbHMvbW91bnRkL2NhY2hlLmMKQEAg
LTQ1NSw2ICs0NTUsNyBAQCBzdGF0aWMgaW50IGR1bXBfdG9fY2FjaGUoRklMRSAqZiwgY2hhciAq
CiAJCXF3b3JkX3ByaW50aW50KGYsIGV4cC0+ZV9hbm9udWlkKTsKIAkJcXdvcmRfcHJpbnRpbnQo
ZiwgZXhwLT5lX2Fub25naWQpOwogCQlxd29yZF9wcmludGludChmLCBleHAtPmVfZnNpZCk7CisJ
CXdyaXRlX2ZzbG9jKGYsIGV4cCwgcGF0aCk7CiAgCQlpZiAoZXhwLT5lX3V1aWQgPT0gTlVMTCkg
ewogIAkJCWNoYXIgdVsxNl07CiAgCQkJaWYgKGdldF91dWlkKGV4cC0+ZV9wYXRoLCBOVUxMLCAx
NiwgdSkpIHsKQEAgLTQ2NSw3ICs0NjYsNiBAQCBzdGF0aWMgaW50IGR1bXBfdG9fY2FjaGUoRklM
RSAqZiwgY2hhciAqCiAgCQkJcXdvcmRfcHJpbnQoZiwgInV1aWQiKTsKICAJCQlxd29yZF9wcmlu
dGhleChmLCBleHAtPmVfdXVpZCwgMTYpOwogIAkJfQotCQl3cml0ZV9mc2xvYyhmLCAmZXhwLCBw
YXRoKTsKIAl9CiAJcmV0dXJuIHF3b3JkX2VvbChmKTsKIH0K
------=_Part_98906_7269252.1172517426666
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
------=_Part_98906_7269252.1172517426666
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

------=_Part_98906_7269252.1172517426666--
