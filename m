Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38834 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751021AbbEGNgh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 09:36:37 -0400
Message-ID: <554B6A61.5010504@RedHat.com>
Date: Thu, 07 May 2015 09:36:33 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Calvin Walton <calvin.walton@kepstin.ca>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: Substitute sbindir in systemd unit files.
References: <1429638029-13637-1-git-send-email-calvin.walton@kepstin.ca>	 <554A7982.50604@RedHat.com> <1430944751.32663.6.camel@kepstin.ca>
In-Reply-To: <1430944751.32663.6.camel@kepstin.ca>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/06/2015 04:39 PM, Calvin Walton wrote:
> I sent the same patch, regenerated with the -M option to git, visible 
> at:
> http://news.gmane.org/find-root.php?message_id=1429638223%2d13852%2d1%2dgit%2dsend%2demail%2dcalvin.walton%40kepstin.ca
> 
I saw this.. 
> This should be a bit more reviewable, because it shows the changes 
> made to each unit file following the file renames.
> 
> If you'd still prefer to have the patch split up, let me know.
If you would not mind... It actually a bit more difficult 
on my end applying a number of patches verses one, but
it does make it much easier to read... 

tia,

steved.
