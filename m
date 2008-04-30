From: Neil Brown <neilb@suse.de>
Subject: Re: reconnect_path() breaks NFS server causing occasional EACCES
Date: Thu, 1 May 2008 09:29:48 +1000
Message-ID: <18457.236.373637.131982@notabene.brown>
References: <20080404102449.GA10209@janus>
	<20080407184346.GF3305@fieldses.org>
	<20080409133639.GA9588@lst.de>
	<18454.45086.254692.412079@notabene.brown>
	<20080429163554.GE20420@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>,
	Frank van Maarseveen <frankvm@frankvm.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39394 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752167AbYD3X35 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2008 19:29:57 -0400
In-Reply-To: message from J. Bruce Fields on Tuesday April 29
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday April 29, bfields@fieldses.org wrote:
> 
> Just to make sure I understand--you're not claiming that there's an
> actual threat of corrupting the on-disk filesystem or in-core data
> structures, right? 

Correct.  I'm not claiming that.

NeilBrown
