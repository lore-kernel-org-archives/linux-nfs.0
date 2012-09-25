Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31227 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753499Ab2IYKbr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Sep 2012 06:31:47 -0400
Date: Tue, 25 Sep 2012 12:31:42 +0200
From: Karel Zak <kzak@redhat.com>
To: chenditang <chendt.fnst@cn.fujitsu.com>
Cc: util-linux@vger.kernel.org, linux-nfs@vger.kernel.org,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [QUESTION]about libmount library performance problems
Message-ID: <20120925103142.GC22639@x2.net.home>
References: <505FBE77.8030802@cn.fujitsu.com>
 <5061076C.2080707@cn.fujitsu.com>
 <506110BB.2070408@cn.fujitsu.com>
 <20120925101031.GB22639@x2.net.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120925101031.GB22639@x2.net.home>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 25, 2012 at 12:10:31PM +0200, Karel Zak wrote:
> On Tue, Sep 25, 2012 at 10:02:35AM +0800, chenditang wrote:
> >   Question)*:* merg the tow file are necessary for umount a dir?

 Ah, do you mean -- why we need to merge all the entries when we want
 to work with only one mountpoint? That's good question ;-) I'll try
 to improve the code...

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com
