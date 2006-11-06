From: Phillip Lougher <phillip@lougher.org.uk>
Subject: Re: Exporting fs from a looped squashfs in linux
Date: Mon, 6 Nov 2006 03:32:33 +0000 (UTC)
Message-ID: <loom.20061106T042305-497@post.gmane.org>
References: <454D10E0.5020301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GgvGP-0008CB-Aj
	for nfs@lists.sourceforge.net; Sun, 05 Nov 2006 19:35:09 -0800
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GgvGQ-0006Q9-7v
	for nfs@lists.sourceforge.net; Sun, 05 Nov 2006 19:35:10 -0800
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1GgvGI-0005ns-5n
	for nfs@lists.sourceforge.net; Mon, 06 Nov 2006 04:35:02 +0100
Received: from lougher.demon.co.uk ([80.177.127.218])
	by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Mon, 06 Nov 2006 04:35:02 +0100
Received: from phillip by lougher.demon.co.uk with local (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Mon, 06 Nov 2006 04:35:02 +0100
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

TGx1w61zIEJhdGxsZSBpIFJvc3NlbGwgPHZpcmlrZXRvIDxhdD4gZ21haWwuY29tPiB3cml0ZXM6
Cgo+IAo+IEhpLAo+IAo+IEknbSB0cnlpbmcgdG8gc2VydmUgYSBtb3VudGVkIGxvb3AtZmlsZXN5
c3RlbSAoc3F1YXNoZnMpIGZyb20gYSBsaW51eAo+IGJveCB0byBvdGhlciB1bml4ZXMuIEFuZCBp
dCBkb2Vzbid0IHdvcmsgZHVlIHRvIChJIHRoaW5rKSBzb21ldGhpbmcKPiByZWxhdGVkIHRvIC9w
cm9jL2ZzL25mcy9maWxlaGFuZGxlLgo+IAo+IFNvIHlvdSBjYW4gc2VlIHRoZSAiRVBFUk0iIHJl
bGF0ZWQgdG8gdGhlICdmaWxlaGFuZGxlJyBwcm9jIGZpbGUuIFdoYXQncwo+IGhhcHBlbmluZyBo
ZXJlPyBBbSBJIHVuYWJsZSB0byBleHBvcnQgYSBsb29wIHNxdWFzaGZzPwo+IAoKVGhlIHJlbGVh
c2VkIHZlcnNpb25zIG9mIFNxdWFzaGZzIGRvbid0IHN1cHBvcnQgTkZTIGV4cG9ydHMuICBJIGhh
dmUgYmVlbgp3b3JraW5nIG9uIGFkZGluZyBORlMgc3VwcG9ydCB0byBTcXVhc2hmcywgYW5kIEkg
aGF2ZSBqdXN0IGNvbW1pdHRlZCB0byBTcXVhc2hmcwpDVlMgYW4gYWxwaGEgdmVyc2lvbiBvZiBT
cXVhc2hmcyAzLjIgdGhhdCBzdXBwb3J0cyBORlMuICBQbGVhc2UgZm9sbG93Cmh0dHA6Ly9zcXVh
c2hmcy5zb3VyY2Vmb3JnZS5uZXQgZm9yIGluZm9ybWF0aW9uIG9uIGFjY2Vzc2luZyBDVlMuICBX
aXRoIHRoZSBuZXcKcmVsZWFzZSB5b3UgaGF2ZSB0byBzcGVjaWZ5IC1leHBvcnRhYmxlIG9uIHRo
ZSBNa3NxdWFzaGZzIGNvbW1hbmQgbGluZSB0byBtYWtlCnRoZSBnZW5lcmF0ZWQgZmlsZXN5c3Rl
bSBORlMgZXhwb3J0YWJlLgoKUGhpbGxpcCBMb3VnaGVyCgoKCi0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KVXNp
bmcgVG9tY2F0IGJ1dCBuZWVkIHRvIGRvIG1vcmU/IE5lZWQgdG8gc3VwcG9ydCB3ZWIgc2Vydmlj
ZXMsIHNlY3VyaXR5PwpHZXQgc3R1ZmYgZG9uZSBxdWlja2x5IHdpdGggcHJlLWludGVncmF0ZWQg
dGVjaG5vbG9neSB0byBtYWtlIHlvdXIgam9iIGVhc2llcgpEb3dubG9hZCBJQk0gV2ViU3BoZXJl
IEFwcGxpY2F0aW9uIFNlcnZlciB2LjEuMC4xIGJhc2VkIG9uIEFwYWNoZSBHZXJvbmltbwpodHRw
Oi8vc2VsLmFzLXVzLmZhbGthZy5uZXQvc2VsP2NtZD1sbmsma2lkPTEyMDcwOSZiaWQ9MjYzMDU3
JmRhdD0xMjE2NDIKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X18KTkZTIG1haWxsaXN0ICAtICBORlNAbGlzdHMuc291cmNlZm9yZ2UubmV0Cmh0dHBzOi8vbGlz
dHMuc291cmNlZm9yZ2UubmV0L2xpc3RzL2xpc3RpbmZvL25mcwo=
