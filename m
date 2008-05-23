From: "Alexander Borghgraef" <alexander.borghgraef.rma@gmail.com>
Subject: Re: Nfs filesystem corruption(?) after kmail crash
Date: Fri, 23 May 2008 16:44:11 +0200
Message-ID: <9e8c52a20805230744m2f7488e5q2867674f2987444@mail.gmail.com>
References: <9e8c52a20805140532w2bcfeff3n896fa5a9b0e82b5@mail.gmail.com>
	 <20080519144806.GB7622@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:12031 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752360AbYEWOoP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2008 10:44:15 -0400
Received: by nf-out-0910.google.com with SMTP id d3so310891nfc.21
        for <linux-nfs@vger.kernel.org>; Fri, 23 May 2008 07:44:11 -0700 (PDT)
In-Reply-To: <20080519144806.GB7622@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 19, 2008 at 4:48 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

> Out of curiosity--what's the filesystem on the server?  (I just wonder
> if this could be due to poor time resolution, so if e.g. switching from
> ext3 to xfs would work around the problem.)

 Is ext3 known for time resolution issues? Switching to a different fs
could prove problematic, but I could always ask the sysadmin to move
my home dir to my client machine, there should be enough space so that
would rule out any synchronization problems.

 The main thing here is that I'd like to understand why this is
happening? What does it mean when ls returns something like:

d????????? ? ?        ?          ?                ? cur

Why is this triggered by an app like kmail? Why does the problem
disappear when I cd into the oddly behaving directory, but not when
kmail checks its availability? Why doesn't this always work? Things
like that.

-- 
Alex Borghgraef
