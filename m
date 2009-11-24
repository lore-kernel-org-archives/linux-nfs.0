Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:48770 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757361AbZKXTzB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2009 14:55:01 -0500
Received: from list by lo.gmane.org with local (Exim 4.50)
	id 1ND1Td-0000au-Mw
	for linux-nfs@vger.kernel.org; Tue, 24 Nov 2009 20:55:05 +0100
Received: from 143.166.197.6 ([143.166.197.6])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2009 20:55:05 +0100
Received: from charles by 143.166.197.6 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2009 20:55:05 +0100
To: linux-nfs@vger.kernel.org
From: Charles Duffy <charles@dyfis.net>
Subject: Apparent race condition w/ NFSv3 mktemp+write+rename
Date: Tue, 24 Nov 2009 13:26:44 -0600
Message-ID: <hehc8g$k8f$1@ger.gmane.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Howdy. With a very heavily loaded (CentOS 5 - Linux 2.6.18-128.el5) 
NFSv3 client and server, I've experienced the following sporadic issue:

function atomic_write() {
     local filename="$1"
     local tempfile
     tempfile="$(mktemp "${filename}.XXXXXX")"
     cat >"${tempfile}" && mv "${tempfile}" "${filename}"
}

$ atomic_write /mnt/foobar <<<"baz"
mv: cannot move `/mnt/foobar.gO1881' to `/mnt/foobar': No such file or 
directory

Are my assumptions regarding available semantics fair and reasonable?

