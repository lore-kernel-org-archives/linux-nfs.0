Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:60883 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285Ab1FICFf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2011 22:05:35 -0400
Date: Wed, 8 Jun 2011 22:05:33 -0400
From: Jim Rees <rees@umich.edu>
To: =?utf-8?B?5a6L5ZOy?= <songzhe@cintel.net.cn>
Cc: "SteveD@redhat.com" <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Re: does nfs-util have a api-manual?
Message-ID: <20110609020533.GA26285@merit.edu>
References: <777962.29188.qm@web15806.mail.cnb.yahoo.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <777962.29188.qm@web15806.mail.cnb.yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

宋哲 wrote:

  I have wrote a server application that record audio files to a nfs 
  directory, and I write to the directory just like it is a local disk.
  
  But when some error occurs with the nfs-connection, the "write" 
  operation is just hanged up and does not return any errors, so I want to 
  use nfs-utils, and I think I can handle the error above with the tools. 
  But I almost know nothing about nfs-utils. Can you help me?

I don't think you need nfs-utils.  The write() system call will hang
indefinitely if there is a problem with the mount.  If you want it to fail
when the server goes away, you need a soft mount, and adjust the timeo and
retrans mount options to suit.  See mount.nfs(8) and nfs(5).
