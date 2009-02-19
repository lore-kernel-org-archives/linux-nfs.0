From: Richard Reid <richardareid@gmail.com>
Subject: nfs/xio.c - xflock()
Date: Thu, 19 Feb 2009 15:37:43 -0500
Message-ID: <7bff90c90902191237x1faff82bhe75a5dbe25e4327f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:5326 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192AbZBSUho (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Feb 2009 15:37:44 -0500
Received: by qw-out-2122.google.com with SMTP id 5so353880qwi.37
        for <linux-nfs@vger.kernel.org>; Thu, 19 Feb 2009 12:37:43 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In xflock() if the file cannot be opened for reading an error (-1) is
returned however if the file CAN be opened for reading (or read/write)
but the 'lock' fails then a 0 is returned which is not treated as an
error by the nfs-utils code.  Either I am missing something or this is
a bug.  Could someone more knowledgeable enlighten me on this?

Richard Reid
Overland Storage
