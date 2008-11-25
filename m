From: Andrew Pollock <apollock@google.com>
Subject: Patch to prevent rpc.gssd spamming logs when Kerberos credentials are
	expired
Date: Tue, 25 Nov 2008 13:22:21 -0800
Message-ID: <39d46ab50811251322j73574e1cg19a1650c8f567463@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=000e0cd2e33e611772045c8a1b02
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:13764 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222AbYKYVWZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Nov 2008 16:22:25 -0500
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id mAPLMNTl026766
	for <linux-nfs@vger.kernel.org>; Tue, 25 Nov 2008 13:22:24 -0800
Received: from yx-out-2324.google.com (yxj3.prod.google.com [10.190.3.67])
	by spaceape7.eur.corp.google.com with ESMTP id mAPLMLBq026638
	for <linux-nfs@vger.kernel.org>; Tue, 25 Nov 2008 13:22:22 -0800
Received: by yx-out-2324.google.com with SMTP id 3so104427yxj.21
        for <linux-nfs@vger.kernel.org>; Tue, 25 Nov 2008 13:22:21 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--000e0cd2e33e611772045c8a1b02
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi,

We've seen excessive (disk filling) log spam from rpc.gssd where users
mount their home directory via Kerberised NFS, and their Kerberos TGT
expires. You get lots of noise like described at
https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/293705

Attached is the patch that we've been using to address this.

regards

Andrew

--
Andrew Pollock
Google Systems Administrator

--000e0cd2e33e611772045c8a1b02
Content-Type: text/x-diff; charset=US-ASCII; name="101-reduce-verbosity.diff"
Content-Disposition: attachment; filename="101-reduce-verbosity.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fnz1zw580

LS0tIG5mcy11dGlscy0xLjEuMi5vcmlnL3V0aWxzL2dzc2QvZ3NzZF9wcm9jLmMKKysrIG5mcy11
dGlscy0xLjEuMi91dGlscy9nc3NkL2dzc2RfcHJvYy5jCkBAIC00NTMsNyArNDUzLDcgQEAKIAl1
bnNpZ25lZCBpbnQgdGltZW91dCA9IDA7CiAJaW50CXplcm8gPSAwOwogCi0JcHJpbnRlcnIoMSwg
ImRvaW5nIGVycm9yIGRvd25jYWxsXG4iKTsKKwlwcmludGVycigyLCAiZG9pbmcgZXJyb3IgZG93
bmNhbGxcbiIpOwogCiAJaWYgKFdSSVRFX0JZVEVTKCZwLCBlbmQsIHVpZCkpIGdvdG8gb3V0X2Vy
cjsKIAlpZiAoV1JJVEVfQllURVMoJnAsIGVuZCwgdGltZW91dCkpIGdvdG8gb3V0X2VycjsKQEAg
LTY3Nyw3ICs2NzcsNyBAQAogCWNoYXIJCQkqKmNjbmFtZTsKIAlpbnQJCQljcmVhdGVfcmVzcCA9
IC0xOwogCi0JcHJpbnRlcnIoMSwgImhhbmRsaW5nIGtyYjUgdXBjYWxsXG4iKTsKKwlwcmludGVy
cigyLCAiaGFuZGxpbmcga3JiNSB1cGNhbGxcbiIpOwogCiAJdG9rZW4ubGVuZ3RoID0gMDsKIAl0
b2tlbi52YWx1ZSA9IE5VTEw7CkBAIC03NDMsNyArNzQzLDcgQEAKIAl9CiAKIAlpZiAoIWF1dGhn
c3NfZ2V0X3ByaXZhdGVfZGF0YShhdXRoLCAmcGQpKSB7Ci0JCXByaW50ZXJyKDAsICJXQVJOSU5H
OiBGYWlsZWQgdG8gb2J0YWluIGF1dGhlbnRpY2F0aW9uICIKKwkJcHJpbnRlcnIoMiwgIldBUk5J
Tkc6IEZhaWxlZCB0byBvYnRhaW4gYXV0aGVudGljYXRpb24gIgogCQkJICAgICJkYXRhIGZvciB1
c2VyIHdpdGggdWlkICVkIGZvciBzZXJ2ZXIgJXNcbiIsCiAJCQkgdWlkLCBjbHAtPnNlcnZlcm5h
bWUpOwogCQlnb3RvIG91dF9yZXR1cm5fZXJyb3I7Cm9ubHkgaW4gcGF0Y2gyOgp1bmNoYW5nZWQ6
Ci0tLSBuZnMtdXRpbHMtMS4xLjIub3JpZy91dGlscy9nc3NkL2dzc191dGlsLmMKKysrIG5mcy11
dGlscy0xLjEuMi91dGlscy9nc3NkL2dzc191dGlsLmMKQEAgLTEyMiw3ICsxMjIsNyBAQAogCQkJ
CSJnc3NfZGlzcGxheV9zdGF0dXMgY2FsbGVkIGZyb20gJXNcbiIsIG0pOwogCQkJYnJlYWs7CiAJ
CX0gZWxzZSB7Ci0JCQlwcmludGVycigwLCAiRVJST1I6IEdTUy1BUEk6ICglcykgZXJyb3IgaW4g
JXMoKTogJXNcbiIsCisJCQlwcmludGVycigyLCAiRVJST1I6IEdTUy1BUEk6ICglcykgZXJyb3Ig
aW4gJXMoKTogJXNcbiIsCiAJCQkgICAgdHlwZXN0ciwgbSwgKGNoYXIgKiltc2cudmFsdWUpOwog
CQl9CiAK
--000e0cd2e33e611772045c8a1b02--
