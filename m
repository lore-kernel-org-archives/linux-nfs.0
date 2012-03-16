Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:58106 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1032236Ab2CPAQv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Mar 2012 20:16:51 -0400
Date: Thu, 15 Mar 2012 20:16:47 -0400
From: Jim Rees <rees@umich.edu>
To: Bruno Silva <bs@cin.ufpe.br>
Cc: linux-nfs@vger.kernel.org
Subject: Re: About pNFS installation process.
Message-ID: <20120316001647.GA25426@umich.edu>
References: <CAAJC9VbxAcE+DqjqaZ-9K4HKpAWKgg0_B9_QFk64b5V-QdotQA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAAJC9VbxAcE+DqjqaZ-9K4HKpAWKgg0_B9_QFk64b5V-QdotQA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruno Silva wrote:

  The steps 1, 2 and 3 i did to all machines (data servers, metadata
  server and client).

You only need blkmapd on the client.  Client setup instructions are at
http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup .  I added
a link to that page.
