From: "Andrew Bell" <andrew.bell.ia@gmail.com>
Subject: Performance Diagnosis
Date: Tue, 15 Jul 2008 10:34:48 -0500
Message-ID: <e80abd30807150834m47a1b86cle39885150f1d5bfd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:7906 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761828AbYGOPey (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2008 11:34:54 -0400
Received: by qw-out-2122.google.com with SMTP id 3so163304qwe.37
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2008 08:34:53 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I have a RHEL 5 system that exhibits less than wonderful performance
when copying large files from/to an NFS filesystem.  When the copy is
taking place, other access to the filesystem is painfully slow.  I
would like to have the filesystem react well to small requests while a
large request is taking place.

A couple of questions:

Is this a reasonable expectation?

Is this perhaps an I/O scheduling issue that isn't specific to NFS,
but shows up there because of the latency of my NFS setup?

Is this most likely a client issue, a server issue or a combination?

Do you have recomendations on the best way to determine what is
happening?  Are there existing tools to monitor active IO/NFS
requests/responses and any relevant queues?


Thanks for any info/ideas before I get in too deep :)

-- 
Andrew Bell
andrew.bell.ia@gmail.com
