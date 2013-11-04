Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56346 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957Ab3KDV4r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Nov 2013 16:56:47 -0500
Received: by mail-bk0-f46.google.com with SMTP id e11so875119bkh.5
        for <linux-nfs@vger.kernel.org>; Mon, 04 Nov 2013 13:56:46 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1816\))
Subject: Re: [PATCH 4/4] NFSD: Implement SEEK
From: Thomas Haynes <loghyr@gmail.com>
In-Reply-To: <20131104164658.GA4427@fieldses.org>
Date: Mon, 4 Nov 2013 13:56:39 -0800
Cc: Christoph Hellwig <hch@infradead.org>,
        Bryan Schumaker <bjschuma@netapp.com>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Message-Id: <5BAB86A3-045A-4CA9-A08F-7B0E38DBAC7D@excfb.com>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com> <1382972247-1108-5-git-send-email-bjschuma@netapp.com> <20131029073558.GA10889@infradead.org> <526FB180.1060003@netapp.com> <20131029130721.GA32094@infradead.org> <20131029133006.GB29606@fieldses.org> <20131102134837.GA18961@infradead.org> <20131102143729.GA26983@fieldses.org> <20131102144107.GA28743@infradead.org> <20131104164658.GA4427@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 4, 2013, at 8:46 AM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Sat, Nov 02, 2013 at 07:41:07AM -0700, Christoph Hellwig wrote:
>> On Sat, Nov 02, 2013 at 10:37:29AM -0400, J. Bruce Fields wrote:
>>> On Sat, Nov 02, 2013 at 06:48:37AM -0700, Christoph Hellwig wrote:
>>>> On Tue, Oct 29, 2013 at 09:30:06AM -0400, J. Bruce Fields wrote:
>>>>> I haven't read these parts of the spec yet at all....
>>>> 
>>>> Btw, is there a way do to something like a git blame for the spec?  I'd
>>>> really love to confront people personally with some of the odd bits they
>>>> came up with.
>>> 
>>> It *is* in git, so you can literally run git blame:
>>> 
>>> 	https://github.com/loghyr/NFSv4.2
>>> 
>>> But it'll probably credit almost everything to Tom and he's typically
>>> just the messenger....
>> 
>> Indeed, a quick try attributes everything to him.  No good way to figure
>> out who is to blame for the whole WRITE PLUS idiocy.
> 
> Imagine it was me, if it helps.
> 

Nah, most likely me, no imagination needed.

We were also looking at bringing larger WRITEs during 4.3 and I wanted
to have WRITE_PLUS already in place for that.


> The important thing is that we understand what should be fixed.
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

