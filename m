From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NLM: Revert parts of commit 24e36663
Date: Fri, 26 Sep 2008 19:30:56 -0400
Message-ID: <20080926233056.GM7138@fieldses.org>
References: <20080925213831.GF14349@fieldses.org> <AED0D581-07B0-4EC6-90AB-2F61B6F3C76B@oracle.com> <20080926184554.GA1492@fieldses.org> <1222454975.10150.8.camel@localhost> <EF58CFE4-3F4B-4985-9DEA-E61CC0DFC8EA@oracle.com> <1222456290.10150.10.camel@localhost> <20080926194421.GD1492@fieldses.org> <87089E47-10AE-4D41-B5BE-CCEE034C526B@oracle.com> <1222459067.10150.16.camel@localhost> <215DBAD9-1E4B-4E23-9F54-AAF6518D24DA@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58522 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752821AbYIZXbK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 19:31:10 -0400
In-Reply-To: <215DBAD9-1E4B-4E23-9F54-AAF6518D24DA@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 26, 2008 at 05:11:25PM -0400, Chuck Lever wrote:
> On Sep 26, 2008, at Sep 26, 2008, 3:57 PM, Trond Myklebust wrote:
>> On Fri, 2008-09-26 at 15:54 -0400, Chuck Lever wrote:
>>> The whole system makes it absolutely impossible to plan features and
>>> bug fixes.
>>
>> The only thing it makes impossible is planning features for a
>> _particular_ kernel revision.
>
> I find it impossible to plan for a particular _year_ (or even two).
>
> The problem is _you_, the subsystem maintainer, have a merge window too.  
> I find it challenging to align my patch submissions with two sliding 
> merge windows that open and close at arbitrary times without any warning 
> whatever.  And now I have to worry about Bruce's merge window as well....

Please just send them in whenever they're ready--I mean to take patches
at any time, and then decide separately whether they should be queued up
for the current version, the next one, and/or the previous (stable)
version.  There are inevitably delays (especially with vacations and
such), but normally I'll try to at least respond with an estimate if
it's going to take longer than a couple days.

> Plus, the submission guidelines keep changing.  FreeBSD has an amazing  
> guide to kernel development rules and conventions posted on the web.  I 
> wish Linux had the same.

Do you have a pointer to it, and/or suggestions how it could be used to
improve existing linux documentation?

There's Documentation/SubmittingPatches and stuff.  My main gripe with
Documentation/ is that people contribute to it, but there's no
maintainer to say "no" or to keep things organized, so it tends to get
large and messy over time.

In any case lkml would be a better forum for this.

> If I know in advance when you (and Bruce) are taking new features or bug 
> fixes for each kernel release, that would be helpful.

I'd like to say the answer is "any time", barring occasional
interruptions.

Or if the problem is that you've got stuff that you're basically done
with, but that you know you *might* get the chance to take one more look
at if you had another week--I think it'd be better if people just sent
stuff in when they think it's good enough, and if we later find a
problem we'll fix it.

--b.
