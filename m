Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:34253 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbbEHAXX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2015 20:23:23 -0400
Received: by pdbqa5 with SMTP id qa5so55242322pdb.1
        for <linux-nfs@vger.kernel.org>; Thu, 07 May 2015 17:23:23 -0700 (PDT)
Message-ID: <554C01F4.2060003@gmail.com>
Date: Fri, 08 May 2015 08:23:16 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Eino Juhani Oltedal <e.j.oltedal@fys.uio.no>, kinglongmee@gmail.com
Subject: Re: [PATCH 3/3] osd_login: add --disable-osdlogin for configure osd_login
References: <552E8FE8.1070601@gmail.com> <554B73D8.40007@RedHat.com> <554B7DED.2000403@gmail.com> <554B834A.5030405@RedHat.com>
In-Reply-To: <554B834A.5030405@RedHat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 5/7/2015 11:22 PM, Steve Dickson wrote:
> Hello,
> 
> On 05/07/2015 10:59 AM, Kinglong Mee wrote:
>> Miss updating of utils/Makefile.am in your tree.
>>
>> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=commitdiff;h=3e28fe73af023bf42e0d654146bfb9314b4d8438
> Are you saying something is missing??

Yes,
the old patch also update utils/Makefile.am, 
otherwise adding --enable-osdlogin is useless.


diff --git a/utils/Makefile.am b/utils/Makefile.am
index b892dc8..6dd4a57 100644
--- a/utils/Makefile.am
+++ b/utils/Makefile.am
@@ -25,6 +25,10 @@ if CONFIG_NFSDCLTRACK
 OPTDIRS += nfsdcltrack
 endif
 
+if CONFIG_OSD_LOGIN
+OPTDIRS += osd_login
+endif
+
 SUBDIRS = \
 	exportfs \
 	mountd \
@@ -32,7 +36,6 @@ SUBDIRS = \
 	nfsstat \
 	showmount \
 	statd \
-	osd_login \
 	$(OPTDIRS)
 
 MAINTAINERCLEANFILES = Makefile.in
-- 2.3.5 
