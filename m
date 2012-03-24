Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([134.215.213.37]:2894 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754270Ab2CXQk0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 24 Mar 2012 12:40:26 -0400
Date: Sat, 24 Mar 2012 12:34:46 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Boaz Harrosh <bharrosh@panasas.com>
Message-ID: <1886390911.6.1332606886333.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <209745840.4.1332606289405.JavaMail.root@thunderbeast.private.linuxbox.com>
Subject: unlink within an open directory stream
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Folks testing linux nfs + Ganesha with bonnie++ have noticed the issue described here (but I didn't see traffic on this list):

http://bugs.centos.org/view.php?id=5496
https://bugzilla.redhat.com/show_bug.cgi?id=789452

Ie, an application which unlinks on an open (nfs) directory stream, and continues to read and unlink progressively, will generally not see all the entries originally in the stream.  Reopening the stream ives the "correct" result.  So, apparently older clients were more forgiving, as mentioned in the links.  Is the current behavior one the client is intending?

Thanks,

Matt

-- 
Matt Benjamin
The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel. 734-761-4689
fax. 734-769-8938
cel. 734-216-5309
