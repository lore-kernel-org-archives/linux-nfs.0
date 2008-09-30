From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 10/10] svcrdma: Documentation update for the FastReg
	memory model
Date: Tue, 30 Sep 2008 14:57:29 -0400
Message-ID: <20080930185729.GE12268@fieldses.org>
References: <1221564879-85046-8-git-send-email-tom@opengridcomputing.com> <1221564879-85046-9-git-send-email-tom@opengridcomputing.com> <1221564879-85046-10-git-send-email-tom@opengridcomputing.com> <1221564879-85046-11-git-send-email-tom@opengridcomputing.com> <20080924212102.GD10841@fieldses.org> <48DB939E.4090503@opengridcomputing.com> <20080926234006.GA9889@fieldses.org> <48E197ED.6080409@opengridcomputing.com> <20080930184433.GC12268@fieldses.org> <48E27631.4090202@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Tom Talpey <Thomas.Talpey@netapp.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:54836 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752061AbYI3S5b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Sep 2008 14:57:31 -0400
In-Reply-To: <48E27631.4090202@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 30, 2008 at 01:55:45PM -0500, Tom Tucker wrote:
> J. Bruce Fields wrote:
>> On Mon, Sep 29, 2008 at 10:07:25PM -0500, Tom Tucker wrote:
>>> What's your perspective on the lifetime of bounce buffers, memory   
>>> windows, and the other strategies in client?
>>
>> I'm ignorant.  Pointer to something else I should read?
>>
>> I assume there are similar issues on the client?
>>
>
> Sorry, that was a question for Tom Talpey.

Phew!

> It's a client specific issue  since the server only implements
> ALLPHYSICAL and FAST REG.

OK.--b.
