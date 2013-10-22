Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1168 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752613Ab3JVPXR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 11:23:17 -0400
Message-ID: <52669862.6030409@redhat.com>
Date: Tue, 22 Oct 2013 10:23:14 -0500
From: Tony Asleson <tasleson@redhat.com>
Reply-To: tasleson@redhat.com
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org, Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] exportfs: Return non-zero exit value on error
References: <1380756584-13335-1-git-send-email-tasleson@redhat.com> <20131022092519.4f4683a8@notabene.brown>
In-Reply-To: <20131022092519.4f4683a8@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/21/2013 05:25 PM, NeilBrown wrote:
> On Wed,  2 Oct 2013 18:29:44 -0500 Tony Asleson <tasleson@redhat.com> wrote:
> 
>> To improve error handling when scripting exportfs it's useful
>> to have non-zero exit codes when the requested operation did not
>> succeed.
>>
>> This patch also returns a non-zero exit code if you request to
>> unexport a non-existant share.
>>
>> Signed-off-by: Tony Asleson <tasleson@redhat.com>
> 
> This seems the have been forgotten, so maybe by replying to it someone will
> notice (hi Steve).
> 
> Though I agree with the need for the patch, I don't much like it's shape.
> 
> Why change exportfs and unexportfs to return a status?  The status is only
> used to set export_errno, and they sometimes set export_errno anyway, so why
> not leave them returning  void and just setting export_errno as needed?

The reason I chose to return values was to make sure requested operation
actually completed requested operation.  Unexporting a non-existent
export is not considered an error and returns no indication you did
absolutely nothing.

When scripting exportfs from another program I wanted to know that the
operation I requested actually did what I asked so that I could catch
bad calls to it.

Regards,
Tony
