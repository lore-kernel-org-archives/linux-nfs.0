Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:33484 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755083AbcFTPqQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2016 11:46:16 -0400
Subject: Re: NFS/d_splice_alias breakage
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <d56d898b-0d6b-2d1a-9395-f95930325a32@Netapp.com>
Date: Mon, 20 Jun 2016 11:45:50 -0400
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>, <linux-nfs@vger.kernel.org>,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>
Message-Id: <69B23CC3-E14B-44BA-9067-6AEC124F6461@linuxhacker.ru>
References: <CF78E59B-F311-437B-9D1C-1F3FF6C22126@linuxhacker.ru> <20160603033750.GL14480@ZenIV.linux.org.uk> <0C971585-6BFC-4665-832B-9B262F733BFC@linuxhacker.ru> <20160603042648.GN14480@ZenIV.linux.org.uk> <51139F5D-8CC8-4448-B3AB-5EF1B67E2D6C@linuxhacker.ru> <20160603055655.GQ14480@ZenIV.linux.org.uk> <D500FB60-CE33-4655-9995-70332B5945D2@linuxhacker.ru> <20160620140858.GJ14480@ZenIV.linux.org.uk> <d56d898b-0d6b-2d1a-9395-f95930325a32@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 20, 2016, at 11:43 AM, Anna Schumaker wrote:

> Hi,
> 
> On 06/20/2016 10:08 AM, Al Viro wrote:
>> On Mon, Jun 20, 2016 at 09:25:12AM -0400, Oleg Drokin wrote:
>>> It looks like this patch was totally forgotten?
>>> I don't see it in neither vfs nor nfs trees and yet it fixes a very easy to cause
>>> crash in nfs code. And I think it's unrelated to the other parallel case too.
>> 
>> I assumed it would go through NFS tree, seeing that it's NFS-specific and
>> has nothing to do with any of the recent VFS changes (oops is triggerable
>> starting from 3.11); I can certainly put it through vfs.git, and there
>> will be changes nearby, but this one should go into -stable as a separate
>> patch.
> 
> I was going to put together an nfs bugfixes pull request for 4.7 this week, so I can include the patch there if this is easy to hit.

Yes, it is very easy to hit.

