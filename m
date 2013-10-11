Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:44842 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756699Ab3JKVE0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Oct 2013 17:04:26 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: nfs4.1  pseudo filesystem
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20131011205836.GC22160@fieldses.org>
Date: Fri, 11 Oct 2013 17:04:09 -0400
Cc: Ming Lei <Ming.Lei@riverbed.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <0D65655C-7CC3-4003-A2D4-5D871F599701@oracle.com>
References: <loom.20131010T232229-437@post.gmane.org> <20131011163022.GA22214@fieldses.org> <2CE44BD3DBCF9541909CCB42F11CA3921C774298@sfo1exc-mbxp08.nbttech.com> <20131011182942.GA22160@fieldses.org> <20131011205836.GC22160@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 11, 2013, at 4:58 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Oct 11, 2013 at 02:29:42PM -0400, J. Bruce Fields wrote:
>> On Fri, Oct 11, 2013 at 04:51:29PM +0000, Ming Lei wrote:
>>> I want to cherry-pick a few subdirectories under say /root, but I don't want to specifies all these mount directories one by one just like NFSv2/3.
>> 
>> Well, you're kind of stuck enumerating them whether as exports or bind
>> mounts.
>> 
>>> Does pseudo filesystem in kernel v3.11 work well enough?
>> 
>> But it should work anyway, yes.
>> 
>> Oh, wait, I see the problem: it doesn't work well if you're exporting
>> subdirectories and not full filesystems.  Unless you do something
>> special at the export points  (e.g. mount --bind them over themselves),
>> knfsd doesn't know when you've crossed an export point.
> 
> I wonder if exportfs should be taught to mark export points as
> junctions.  That might fix this kind of problem?

A junction is always an unreadable directory.

We'd be better off with a generic "please upcall" bit for directories.  Then mountd could sort out what are junctions and what are legitimate exports, and the kernel would leave all the other directories in an export alone.

> It might mean creating junctions never get cleaned up, which is ugly
> though perhaps unlikely to be a serious problem in practice.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




