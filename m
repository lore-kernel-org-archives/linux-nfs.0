Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:52763 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751831Ab2BTS1O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Feb 2012 13:27:14 -0500
Date: Mon, 20 Feb 2012 13:27:09 -0500
From: Jim Rees <rees@umich.edu>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Chris Rankin <rankincj@yahoo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [OOPS] NFS dereferenced NULL pointer with 3.2.6 kernel.
Message-ID: <20120220182709.GA22899@umich.edu>
References: <4F4194C4.40104@yahoo.com>
 <1329760844.2834.1.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1329760844.2834.1.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond wrote:

  It's a known bug. There is a fix at
  
  http://git.linux-nfs.org/?p=trondmy/nfs-2.6.git;a=commit;h=331818f1c468a24e581aedcbe52af799366a9dfe

Shouldn't this be in stable by now?  You sent it Feb 3, and there have been
two stable releases since then.
