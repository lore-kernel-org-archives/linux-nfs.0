From: Martin Vogt <martin.vogt@itwm.fraunhofer.de>
Subject: Re: permission denied with >= ~2.6.25
Date: Thu, 20 May 2010 11:28:41 +0200
Message-ID: <4BF500C9.2010904@itwm.fraunhofer.de>
References: <4BE7ED5D.90801@itwm.fraunhofer.de> <4BE93940.5070804@itwm.fraunhofer.de> <4BED1E44.4020708@itwm.fraunhofer.de> <20100516175213.GA9225@lts032.itwm.fhg.de> <4BF25109.40300@itwm.fraunhofer.de> <4BF3C7A4.8030906@itwm.fraunhofer.de> <20100519171347.GB8137@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050209020008040105090807"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:39242 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454Ab0ETJ2o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 May 2010 05:28:44 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-5+lenny1) with ESMTP id o4K9SguI000617
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 20 May 2010 11:28:42 +0200
Received: from mail1.itwm.fhg.de ([131.246.191.78]:51605)
	by itwm2.itwm.fhg.de with esmtps (TLSv1:DES-CBC3-SHA:168)
	(/C=DE/ST=Rheinland-Pfalz/L=Kaiserslautern/O=Fraunhofer ITWM/OU=SLG/CN=mail1.itwm.fhg.de)(verified=1)
	 (Exim 4.66 #1)
	id 1OF23W-0004Tg-Ln
	for linux-nfs@vger.kernel.org; Thu, 20 May 2010 11:28:42 +0200
In-Reply-To: <20100519171347.GB8137@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050209020008040105090807
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> On Wed, May 19, 2010 at 01:12:36PM +0200, Martin Vogt wrote:
>> Martin Vogt wrote:
>>> Hello,
>>>
>>>
>>> today I tried 2.6.34 on server/client with standard
>>> hardware. After around the 69th checkout I had an
>>> "Invalid cross-device link" Error.
>>> (Before that it was EIO/EPERM)
>>>
>>> Test ran for around 9 hours before it failed.
>>>
>>>> svn: In directory 'Kernel-pxe3-69.EZvgHTmbzv/include/asm-sparc'
>>>> svn: Can't move
>>> 'Kernel-pxe3-69.EZvgHTmbzv/include/asm-sparc/resource.h.tmp'
>>>> to 'Kernel-pxe3-69.EZvgHTmbzv/include/asm-sparc/resource.h': Invalid
>>>> cross-device link
>>>> Mon May 17 23:46:32 CEST 2010,1
>>>> runcounter: 69
>> Ok.
>> RTFM: no_subtree_check :-(
>>
>> This option made the checkouts reliable.
> 
> Erp.  Should have thought of that.  It's no longer the default in recent
> nfs-utils, for this sort of reason.
> 
> (But, note: for anyone exporting directories that aren't mountpoints,
> that may expose more of their filesystem than intended.)
> 

Hello,

the report for the latest kernel was done with "no_subtree_check"

-9 hours client/server both 2.6.34 before "Invalid cross-device link"

2.6.34 still shows some svn problem with "no_subtree_check" on.
But only after 9 hours (vs 10 minutes, with subtree_check)

It was done with:

>log:Assuming default behaviour ('no_subtree_check').
exports:
>/var/tmp/nfs_export
>192.168.9.0/255.255.255.0(rw,async,wdelay,acl,no_root_squash,fsid=6666)

Using "no_subtree_check" made it only "much more" stable
than before, but not "stable".

Server was 4 core (2 sockets) Xeon 5148@2.33GHz,
8GB mem.
Exported fs was ext3 from a Standard Sata drive,
and the client was a dual core E8400.

Mount client:
mount -o rw,nosuid,nodev,rsize=8192,wsize=8192,vers=3 -t nfs
pxe2:/var/tmp/nfs_export  /home/local


I'm attaching my test script. The script needs to be run two times
in parallel on the machine. (In screen for example).
If someone wants to reproduce this.A single checkout on
the machine would even takes longer to reproduce the problem.

I imported a normal kernel tree into a svn repository
on a dedicated server only for this and started svnserve -d
as normal user.


regards,

Martin


--------------050209020008040105090807
Content-Type: application/x-shellscript;
 name="svn_run.sh"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="svn_run.sh"

IyEvYmluL3NoCgpTRVJWRVI9InlvdXJzdm5zZXJ2ZXIiCgpIT1NUPWBob3N0bmFtZSAtc2AK
ST0wCkFCT1JUX09OX0ZBSUw9InRydWUiCkxPR0RJUj0iL3RtcC9uZnMvIgppZiBbICEgLWQg
JExPR0RJUiBdIDsgdGhlbgogICBta2RpciAtcCAkTE9HRElSCmZpICAgCndoaWxlIFsgJEkg
LWx0IDEwMDAgXTsgZG8KCUk9JFsgJEkgKyAxIF0KICAgICAgICBUTVBESVI9YG1rdGVtcCAt
ZCBLZXJuZWwtJEhPU1QtJEkuWFhYWFhYWFhYWGAKICAgICAgICBMT0dGSUxFPSIke0xPR0RJ
Un0vJHtUTVBESVJ9LmxvZyIKCWlmIFsgISAtZCAiJFRNUERJUiIgXSA7ICB0aGVuICAKCSAg
IGVjaG8gImNyZWF0aW5nIFRNUERJUjokVE1QRElSIGZhaWxlZCIgPiRMT0dGSUxFCgkgICBl
eGl0IDEKCSAgZWxzZSAKICAJICAgZWNobyAiY3JlYXRpbmcgVE1QRElSOiRUTVBESVIgc3Vj
Y2VzcyIgPiRMT0dGSUxFICAgCSAgCglmaQoJZWNobyAicnVuICRJIHN2biBjbyBzdm46Ly8k
e1NFUlZFUn0vc3J2L21lZGlhL3RtcC9zdm5fa2VybmVsL2tlcm5lbCAiJFRNUERJUiIgPj4g
JExPR0ZJTEUgMj4mMSIKICAgICAgICBlY2hvICJzdGFydCBydW5jb3VudGVyOiAkSSIgPj4g
JExPR0ZJTEUJCglzdm4gY28gc3ZuOi8vJHtTRVJWRVJ9L3Nydi90bXAvc3ZuX2tlcm5lbC9r
ZXJuZWwgIiRUTVBESVIiID4gJExPR0ZJTEUgMj4mMQoJUkVTVUxUPSQ/CgllY2hvIGBkYXRl
YCwkUkVTVUxUCQoJaWYgWyAkUkVTVUxUICE9IDAgXSA7IHRoZW4KCSAgIGVjaG8gYGRhdGVg
LCRSRVNVTFQgPj4gJExPR0ZJTEUKCSAgIGVjaG8gInJ1bmNvdW50ZXI6ICRJIiA+PiAkTE9H
RklMRQoJICAgaWYgWyAieCR7QUJPUlRfT05fRkFJTH0iID09ICJ4dHJ1ZSIgXSA7IHRoZW4K
CSAgICAgICMga2lsbCByZW1haW5pbmcgdGVzdCBydW5zCgkgICAgICBlY2hvICJzdG9wIGFs
bCBwcm9jZXNzaW5nIHdpdGg6IGtpbGxhbGwiCgkgICAgICBlY2hvICJzdG9wIHByb2Nlc3Np
bmcgd2l0aDoga2lsbGFsbCAtOSBzdm5fcnVuLnNoIiA+PiRMT0dGSUxFCgkgICAgICBsb2dn
ZXIgIkVuZCBvZiBydW4uIGtpbGxpbmcgY2hlY2tvdXRzIgoJICAgICAga2lsbGFsbCAtOSBz
dm5fcnVuLnNoCgkgICAgICBleGl0IDEKCSAgIGZpCglmaSAgIAoJZWNobyAiZXhpdDogJFJF
U1VMVCBvbiBydW46ICRJIiA+PiAkTE9HRklMRQoJcm0gLXJmIC0tICIkVE1QRElSIgpkb25l
Cg==
--------------050209020008040105090807--
