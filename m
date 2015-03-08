Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:44258 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487AbbCHNJB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Mar 2015 09:09:01 -0400
Received: by pdjz10 with SMTP id z10so37173965pdj.11
        for <linux-nfs@vger.kernel.org>; Sun, 08 Mar 2015 06:09:00 -0700 (PDT)
References: <20150303221033.GB19439@fieldses.org> <20150303224456.GV4251@dastard> <20150304020826.GD19439@fieldses.org> <20150304044141.GQ18360@dastard> <20150305131901.GB16235@lst.de>
Mime-Version: 1.0 (1.0)
In-Reply-To: <20150305131901.GB16235@lst.de>
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <07736642-EBA0-4F6B-B6BD-C7C5725A2DC6@primarydata.com>
Cc: Dave Chinner <david@fromorbit.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "xfs@oss.sgi.com" <xfs@oss.sgi.com>
From: Tom Haynes <thomas.haynes@primarydata.com>
Subject: Re: panic on 4.20 server exporting xfs filesystem
Date: Sun, 8 Mar 2015 06:08:57 -0700
To: Christoph Hellwig <hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




> On Mar 5, 2015, at 5:19 AM, Christoph Hellwig <hch@lst.de> wrote:
> 
>> On Wed, Mar 04, 2015 at 03:41:41PM +1100, Dave Chinner wrote:
>> As I understand it, nothing will prevent this - if you don't change
>> the UUID on the filesystem when you clone it, then the UUID will
>> still match and writes can be directed to any block deice with a
>> matching offset/UUID pair.
> 
> Unfortunately that's the case indeed.  The whole discovery part of
> the block layout protocol is fundamentally flawed, as is the recall
> part.  This is my attempt to fix it, but I have no idea how to proceed
> from posting my draft to the IETF to actually making it a standard:
> 
> http://tools.ietf.org/html/draft-hellwig-nfsv4-scsi-layout-00

Let's be sure to talk about this at LSF...
