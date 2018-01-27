Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay-1.mailobj.net ([213.182.54.6]:48806 "EHLO
        relay-1.mailobj.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751559AbeA0AXN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Jan 2018 19:23:13 -0500
Received: from v-2c (unknown [192.168.90.162])
        by relay-1.mailobj.net (Postfix) with SMTP id 6CEE9136D
        for <linux-nfs@vger.kernel.org>; Sat, 27 Jan 2018 01:09:50 +0100 (CET)
Date: Sat, 27 Jan 2018 11:09:45 +1100
From: Riley Baird <riley@mailo.com>
To: linux-nfs@vger.kernel.org
Subject: rpcbind Installation Directory
Message-Id: <20180127110945.18b6771d4a74e1438d4e0a05@mailo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I was recently trying to install rpcbind from source, and I noticed
that the default installation directory was /usr. This surprised me,
since I always thought that software installed by a user should default
to being installed in /usr/local.

Is there a reason that rpcbind is installed into /usr? If not, I can
prepare a patch.

Yours thankfully,

Riley Baird

