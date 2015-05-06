Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:35243 "EHLO
	mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813AbbEFUjP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 May 2015 16:39:15 -0400
Received: by qkhg7 with SMTP id g7so14679912qkh.2
        for <linux-nfs@vger.kernel.org>; Wed, 06 May 2015 13:39:14 -0700 (PDT)
Message-ID: <1430944751.32663.6.camel@kepstin.ca>
Subject: Re: [PATCH] nfs-utils: Substitute sbindir in systemd unit files.
From: Calvin Walton <calvin.walton@kepstin.ca>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 06 May 2015 16:39:11 -0400
In-Reply-To: <554A7982.50604@RedHat.com>
References: <1429638029-13637-1-git-send-email-calvin.walton@kepstin.ca>
	 <554A7982.50604@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2015-05-06 at 16:28 -0400, Steve Dickson wrote:
> On 04/21/2015 01:40 PM, Calvin Walton wrote:
> > The systemd unit files now include the correct full paths to the
> > executables when nfs-utils is configured with an alternate value
> > for e.g. --prefix or --sbindir
> > 
> > Signed-off-by: Calvin Walton <calvin.walton@kepstin.ca>
> This kind of major change always makes me a bit nervous and
> unfortunately I'm not going to have the cycles to give
> it the testing I would like because I'm going on holiday 
> all next week...
> 
> I'll keep it on my TODO list because it sound like it makes
> sense... but probably will not get to it for a couple weeks.
> 
> Also, would you mind breaking the patch up to show what you
> are doing to each script? It would make it a lot easier 
> to review... 

I sent the same patch, regenerated with the -M option to git, visible 
at:
http://news.gmane.org/find-root.php?message_id=1429638223%2d13852%2d1%2dgit%2dsend%2demail%2dcalvin.walton%40kepstin.ca

This should be a bit more reviewable, because it shows the changes 
made to each unit file following the file renames.

If you'd still prefer to have the patch split up, let me know.

-- 
Calvin Walton <calvin.walton@kepstin.ca>
