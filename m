Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:56922 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752569AbcFTOyp convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jun 2016 10:54:45 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Viro Alexander <viro@zeniv.linux.org.uk>
CC: Oleg Drokin <green@linuxhacker.ru>, Fields Bruce <bfields@redhat.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>
Subject: Re: NFS/d_splice_alias breakage
Date: Mon, 20 Jun 2016 14:54:36 +0000
Message-ID: <78AC8FB0-86F3-4ABB-B2A9-2252CBFB4BC5@primarydata.com>
References: <CF78E59B-F311-437B-9D1C-1F3FF6C22126@linuxhacker.ru>
 <20160603033750.GL14480@ZenIV.linux.org.uk>
 <0C971585-6BFC-4665-832B-9B262F733BFC@linuxhacker.ru>
 <20160603042648.GN14480@ZenIV.linux.org.uk>
 <51139F5D-8CC8-4448-B3AB-5EF1B67E2D6C@linuxhacker.ru>
 <20160603055655.GQ14480@ZenIV.linux.org.uk>
 <D500FB60-CE33-4655-9995-70332B5945D2@linuxhacker.ru>
 <20160620140858.GJ14480@ZenIV.linux.org.uk>
In-Reply-To: <20160620140858.GJ14480@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 20, 2016, at 10:08, Al Viro <viro@zeniv.linux.org.uk> wrote:
> 
> On Mon, Jun 20, 2016 at 09:25:12AM -0400, Oleg Drokin wrote:
>> It looks like this patch was totally forgotten?
>> I don't see it in neither vfs nor nfs trees and yet it fixes a very easy to cause
>> crash in nfs code. And I think it's unrelated to the other parallel case too.
> 
> I assumed it would go through NFS tree, seeing that it's NFS-specific and
> has nothing to do with any of the recent VFS changes (oops is triggerable
> starting from 3.11); I can certainly put it through vfs.git, and there
> will be changes nearby, but this one should go into -stable as a separate
> patch.
> 

I’ll take it through the NFS tree.

Cheers
  Trond

