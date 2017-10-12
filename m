Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37570 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753574AbdJLVoz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 12 Oct 2017 17:44:55 -0400
Date: Thu, 12 Oct 2017 17:44:54 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Thomas Haynes <loghyr@primarydata.com>
Cc: Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
Subject: Re: pynfs replay cache test SEQ9f
Message-ID: <20171012214454.GA19598@fieldses.org>
References: <1507740502-5151-1-git-send-email-Thomas.Haynes@primarydata.com>
 <E0161195-9F4A-4B36-A71D-6A924498C893@primarydata.com>
 <20171012194946.GC5233@fieldses.org>
 <6F78E570-F9B0-41A9-B224-3F2313AA8D4F@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <6F78E570-F9B0-41A9-B224-3F2313AA8D4F@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Your mailer's not quoting right, it's a little hard for me to find your
replies.  Wading in:

On Thu, Oct 12, 2017 at 09:39:04PM +0000, Thomas Haynes wrote:
> On Oct 12, 2017, at 12:49 PM, J. Bruce Fields <bfields@fieldses.org<mailto:bfields@fieldses.org>> wrote:
> > So I *think* the only correct options OK or FALSE_RETRY?
> 
> It can’t be OK if the parameters to SEQUENCE differ.

I'm getting that from: "When the replier detects a false retry, it is
permitted (but not always obligated) to return NFS4ERR_FALSE_RETRY in
response to the Sequence operation when it detects a false retry."

If i understand the following language, we're required to return
FALSE_RETRY in the case the rpc credentials of the caller map to
different principals, but not otherwise.

--b
