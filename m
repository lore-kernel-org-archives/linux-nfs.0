Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:55410 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751017Ab1LCN4e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Dec 2011 08:56:34 -0500
Date: Sat, 3 Dec 2011 08:56:25 -0500
From: Jim Rees <rees@umich.edu>
To: Harald Dunkel <harri@afaics.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 fsid=0 export still necessary?
Message-ID: <20111203135625.GA2931@umich.edu>
References: <4EDA0650.9080702@afaics.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EDA0650.9080702@afaics.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Harald Dunkel wrote:

  Question: Is the common root directory optional? Since NFSv3 doesn't
  support this name space feature, wouldn't it be more wise to omit
  the root directory?

The server root directory combined with SRV records to locate server roots
would give us a universal name space, something I've been advocating for
since the beginning of v4.  But today our universal names all seem to start
with "http:".
