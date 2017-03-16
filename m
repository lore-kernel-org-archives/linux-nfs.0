Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:35245 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751483AbdCPSBP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Mar 2017 14:01:15 -0400
Received: by mail-it0-f41.google.com with SMTP id m27so95506754iti.0
        for <linux-nfs@vger.kernel.org>; Thu, 16 Mar 2017 11:01:03 -0700 (PDT)
From: Chuck Lever <chucklever@gmail.com>
Content-Type: text/plain; charset=us-ascii
Subject: software error with bugzilla.linux-nfs.org
Date: Thu, 16 Mar 2017 13:59:39 -0400
Message-Id: <1BF99BE7-DE8A-436B-B5A7-9080D9E9AC93@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: webmaster@linux-nfs.org
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


When I tried to add a comment to bug 291, this resulted:

DBD::mysql::db do failed: Incorrect key file for table =
'./nfsv4_bugzilla/bugs_fulltext.MYI'; try to repair it [for Statement =
"UPDATE bugs_fulltext SET comments =3D ?, comments_noprivate =3D ?
               WHERE bug_id =3D ?"] at Bugzilla/Bug.pm line 938.
	Bugzilla::Bug::_sync_fulltext(Bugzilla::Bug=3DHASH(0x3a1a278)) =
called at Bugzilla/Bug.pm line 886
	Bugzilla::Bug::update(Bugzilla::Bug=3DHASH(0x3a1a278), =
"2017-03-16 10:58:16") called at =
/home/linux-nfs.org/nfsv4_bugzilla/process_bug.cgi line 547

Happened twice out of two attempts.


--
Chuck Lever
chucklever@gmail.com



