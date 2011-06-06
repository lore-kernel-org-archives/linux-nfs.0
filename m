Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251]:36375 "EHLO
	moving-picture.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754416Ab1FFMON (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jun 2011 08:14:13 -0400
Message-ID: <4DECC493.7070107@moving-picture.com>
Date: Mon, 06 Jun 2011 13:14:11 +0100
From: James Pearson <james-p@moving-picture.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: How to control the order of different export options for different
 client formats?
References: <4DD2A084.1040905@moving-picture.com> <20110518080106.1159c5b8@notabene.brown> <4DD39D39.7010805@moving-picture.com> <20110518162050.GB16835@fieldses.org> <4DD66EC6.7090706@moving-picture.com> <20110520164147.GA11176@fieldses.org> <4DE79236.1080808@moving-picture.com> <20110604182011.GB23099@fieldses.org>
In-Reply-To: <20110604182011.GB23099@fieldses.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:
> Looks good to me, thanks.
> 
> My one quibble is with the statement that "single host" "is the most
> common format".  (I don't think we know that.)
> 
> Fix that, and just resend with a brief changelog comment and a
> 
> 	Signed-off-by: James Pearson <etc...>
> 
> and steved should get around to applying it eventually....

The "This is the most common format" statement is in the existing 
exports man page - i.e. nothing to do with my patch ...

However, I'll remove that statement as well and submit the patch

James Pearson
