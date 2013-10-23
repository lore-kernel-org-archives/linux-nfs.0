Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44146 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751412Ab3JWRg3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Oct 2013 13:36:29 -0400
Message-ID: <52680917.4010509@redhat.com>
Date: Wed, 23 Oct 2013 12:36:23 -0500
From: Tony Asleson <tasleson@redhat.com>
Reply-To: tasleson@redhat.com
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org, Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] exportfs: Return non-zero exit value on error
References: <1380756584-13335-1-git-send-email-tasleson@redhat.com> <20131022092519.4f4683a8@notabene.brown> <52669862.6030409@redhat.com> <20131023124444.65ace6e3@notabene.brown>
In-Reply-To: <20131023124444.65ace6e3@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/22/2013 08:44 PM, NeilBrown wrote:
> On Tue, 22 Oct 2013 10:23:14 -0500 Tony Asleson <tasleson@redhat.com> wrote:
>> The reason I chose to return values was to make sure requested operation
>> actually completed requested operation.  Unexporting a non-existent
>> export is not considered an error and returns no indication you did
>> absolutely nothing.
> 
> Hi,
>  thanks makes sense - I had missed that (even though you explained it in the
>  patch description :-( )
> 
>  With your patch, if asked to unexport something that wasn't exported it
>  would not report any error, but would exit with an error status.  Is that
>  correct?  I think I would rather have a message printed if there is an error.

Correct, I only made changes for the exit status.  I was trying to make
changes that would be mostly invisible to end users.  I have no concerns
adding a printed error output too, but others may.

Changing the behavior of any command line tool is potentially
problematic when scripted.

>  So would something like this (on top of my patch) address you need, or was
>  there something else I missed?

Yes, this should work for the unexport fs case.

However, the reason my patch was a little more invasive was to ensure
that both the export and unexport paths were covered.

For example, if the strdup call fails in function client_init, we fail
the operation and return exit value of 0.  Unlikely, but just the first
example I stumbled across.

Thanks,
Tony

